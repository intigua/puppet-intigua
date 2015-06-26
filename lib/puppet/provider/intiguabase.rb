#$LOAD_PATH << './lib'
require 'base64'
require 'json'
require 'net/http'
require 'net/https'
require 'openssl'
require 'digest/sha2'
require 'cgi'
require 'uri'
require 'facter'


#require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.features.rubygems?
require 'net/http/digest_auth' if Puppet.features.digest?

class Puppet::Provider::IntiguaBase < Puppet::Provider

    def wait_task(task)
        while task["state"] == "inprogress"
            task = JSON_GET(task["url"])
            sleep 1
        end
        if task["state"] != "completed"
                raise "Task failed: \"#{task['errorData']}\""
        end
        task
    end

    def connection
      return @connection if defined?(@connection)
      coreUri = URI.join(@resource[:coreserverurl])
      # fixme use a new connection per request - this uses githun
      @connection = Net::HTTP.new(coreUri.host, coreUri.port)

      # @connection.set_debug_output($stdout)

      @connection.use_ssl = true
      @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      @connection
    end

    def services
      return @services if defined?(@services)
      notice("Retreiving available services")

      @services = JSON_GET('')
      @services
    end

    def refresh_server
      s = server
      if s == nil
        return nil
      end
      @server = JSON_GET(s["url"])
    end

    def server
          return @server if defined?(@server)
          coreid    = Facter.value('intigua_coreid')
          ipaddress = Facter.value('ipaddress')
          notice("Retreiving server info - ip #{ipaddress} coreid #{coreid}")

          allServersList = JSON_GET(services["servers"])
          # filter sub IPs
          serverList = allServersList.find_all {|s| s['coreid'] == coreid}
          if serverList.length == 0
            info("Server not found by coreid; trying by IP")
            serverList = allServersList.find_all {|s| s['ips'].include? ipaddress }
          end
          if serverList.length == 0
            info("Server not found by coreid and by IP")
            return nil
          end
          if serverList.length != 1
                  raise "Server list had more than one server: #{serverList.length}"
          end
          serverUrl = serverList[0]["url"]
          @server = JSON_GET(serverUrl)
          notice("Got server info - url: " + @server["url"])
          @server
    end

    def managementservice
        if server.nil?
          raise "Server not found, seems to be a configuration issue."
        end
        # don't cache managementservice list, query lastest info
        managementservices = JSON_GET(server["vagentsUrl"])

        managementservice = managementservices.detect{|vag|vag["name"] == @resource["name"] and vag["version"] == @resource["version"] }
        managementservice
    end


    def JSON_GET(path, queryParams = nil)
        JSON.parse(GET(path, queryParams).body)
    end

    def encodeparas(params)
        res = ""
        params.each do |key, value|
            if res != ""
                res += "&"
            end
            res = CGI::escape(key) + "=" + CGI::escape(value)
        end
        res
    end

    def POST(path, data=nil)
      resp = method_with_data(Net::HTTP::Post, path, data)
      resp.value
      resp
    end

    def PUT(path, data=nil)
      method_with_data(Net::HTTP::Put, path, data)
    end

    def DELETE(path)
      method_with_data(Net::HTTP::Delete, path, nil)
    end

    def TASK(response)
      task = JSON.parse(response.body)
      wait_task task
    end

    def GET(path, queryParams = nil)
      if not queryParams.nil?
          params = encodeparas queryParams
          path = path + "?" +  params
      end

      method_with_data(Net::HTTP::Get, path, nil)
    end

    def method_with_data(requestclass, path, data=nil)
      # do not change the original
      path = path.dup
      uri = URI.join(@resource[:coreserverurl], path)
      # no auth info here
      uriToPrint = uri.dup
      # now set the auth info
      uri.user     = @resource[:user]
      uri.password = @resource[:apikey]

      request = requestclass.new(uri.request_uri)
      if data.nil?
          request.body = ""
      else
          request.body = JSON.generate(data)
          request["Content-Type"] = "text/json"
      end

      info("Doing #{request.method} request for #{uriToPrint}")
      res = connection.request(request)
      if res.code  == '401'
        digest_auth = Net::HTTP::DigestAuth.new
        auth = digest_auth.auth_header uri, res['www-authenticate'], request.method
        # create a new request with the Authorization header
        request.add_field 'Authorization', auth

        # re-issue request with Authorization
        res = connection.request request
      end
      info "Request result: #{res.code}"

      res
    end

end
