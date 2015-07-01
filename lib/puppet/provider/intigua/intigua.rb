#$LOAD_PATH << './lib'

require 'facter'
require 'puppet/provider/intiguabase'
require 'digest/sha1'
require "tmpdir"

Puppet::Type.type(:intigua).provide(:connector, :parent => Puppet::Provider::IntiguaBase) do
  @doc = "Send a public key to GitHub."

  confine :feature => :digest

  # defaultfor :operatingsystem => :ubuntu

  def exists?
      notice("Testing server existance")
      # find us in intigua.
      server != nil
  end

  def create
      should_connect = @resource.should(:connected)
      if server == nil
        if should_connect
          self.connected = true
        else
          # if not found, add us as physical machine
          os = Facter.value('operatingsystem') + " " +  Facter.value('operatingsystemrelease') +  "(" + Facter.value('kernel')  + ") " + Facter.value('architecture')
          server_data = {"name" => Facter.value('hostname'), "ip" => Facter.value('ipaddress'), "dnsname" =>  Facter.value('fqdn'), "os" => os, "osFullName" => os }
          server_data_string = server_data.map{|k,v| "#{k} = \"#{v}\""}.join(';')
          notice("Creating server with #{server_data_string}")
          POST(services["servers"], server_data)
        end
      end

      self.connected = @resource.should(:connected)

  end

  def destroy
    if server["machineType"] == "PHYSICAL"
      TASK(DELETE(server["url"]))
    end
  end

  def connected
      if server == nil
        return false
      end

      response = GET(server["connectorUrl"])
      respcode = response.code
      if respcode == "404"
              return false
      elsif respcode != "200"
        raise "Unknown connector state (#{respcode})"
      end
      return true
  end

  def connected=(value)
        # apply or remove connector according to value.
        if value == false && self.connected == true
          TASK(DELETE(server["connectorUrl"]))
        elsif value == true && self.connected == false
          download_and_install_connector
          # TASK(POST(server["connectorUrl"]))
        end
  end

  def download_and_install_connector

          os = Facter.value('kernel')
          # get the connector list
          uri = URI.join(@resource[:coreserverurl], "/connectors/")

          # find the connector:
          connector_plat = ""
          if os == "Linux"
            connector_plat = "linux"
          elsif os == "windows"
            connector_plat = "win"
          else
            raise "Unknown os architecture #{os}"
          end

          connectors = JSON_GET(uri)
          connectors = connectors.select{ |v| v["name"].include? "vlink"}
          connectors = connectors.select{ |v| v["name"].include? connector_plat}
          connector = connectors.max{|a,b| DateTime.parse(a["mtime"]) <=> DateTime.parse(b["mtime"])}

          # download it from the intigua server and install it:
          info "planning to install #{connector['name']}"
          # not sure why to_s is needed. but it doesn't work without it
          connector_uri = URI.join(uri.to_s, connector['name'])

          # stream request as installer maybe  large
          request = Net::HTTP::Get.new(connector_uri.request_uri)

          # can't use temp file on windows as it is not binary
          tmppath = Dir::Tmpname.create(["vlink",".exe"]) { |path| puts path }
          file = File.open(tmppath, 'wb')
          begin
            sha1 = Digest::SHA1.new
            connection.request request do |response|
              response.read_body do |segment|
                file.write(segment)
                sha1 << segment
              end
            end
            file.close

            info "Installer downloaded to #{file.path} sha1: #{sha1.hexdigest}"
            install_connector file.path

          ensure
             file.close
             file.unlink   # deletes the temp file
          end

  end

  def install_connector(installer)
    coreid = ""
    if server != nil
      coreid = "-coreid=#{server['coreid']}"
    end

    coreserverurl  = URI.join(@resource[:coreserverurl], "/vmanage-server/").to_s

    FileUtils.chmod(0755, installer)
    args = [installer, "#{coreid}", "-coreserverurl=#{coreserverurl}"]

    info "running command "  + (args * " ")

    retVal = system(*args)
    if retVal != true
      raise "Installing connector failed ret val = #{retVal} msg = #{$?}"
    end
  end
end
