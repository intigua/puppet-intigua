#$LOAD_PATH << './lib'

require 'facter'
require 'uri'
require 'puppet/provider/intiguabase'
require 'date'
require 'tempfile'
require 'fileutils'

Puppet::Type.type(:managementservice).provide(:intiguamanagementservice, :parent => Puppet::Provider::IntiguaBase) do
  @doc = "Send a public key to GitHub."

  # defaultfor :operatingsystem => :ubuntu

  def exists?
      notice("Testing management service existance")
    not managementservice.nil?
  end

  def create
      response = POST(server["vagentsUrl"], {"name" => @resource[:name], "version" => @resource[:version], "configpackage" => @resource[:config]})
      task = JSON.parse(response.body)
      wait_task task
  end


  def destroy
      response = DELETE(managementservice["url"])
      task = JSON.parse(response.body)
      wait_task task
  end

end
