#$LOAD_PATH << './lib'
require 'puppet/provider/intiguabase'

Puppet::Type.type(:tag).provide(:intiguatag, :parent => Puppet::Provider::IntiguaBase) do
  @doc = "Send a public key to GitHub."

  # defaultfor :operatingsystem => :ubuntu

  def exists?
    refresh_server
    tags_in_server = server["tags"].map { |tag|  tag["name"] }

    tags_in_server.include?  @resource[:name]
  end

  def create

    create_if_needed

    refresh_server
    tags_in_server = server["tags"]
    tags_in_server.push({ 'name' => @resource[:name]})
    PUT(server["url"], {'tags' => tags_in_server} )

  end

  def destroy
    refresh_server
    tags_in_server = server["tags"]
    tags_in_server.delete_if{ |x| x['name'] == @resource[:name] }
    PUT(server["url"], {'tags' => tags_in_server} )
  end

  def create_if_needed
    tagsUri = url_join_ruby_workaround(@resource[:coreserverurl], "tags")
    tags = JSON_GET(tagsUri)

    if tags.index{ |x| x['name'] == @resource[:name] } == nil
      POST(tagsUri, { 'name' => @resource[:name]})
    end
  end

end
