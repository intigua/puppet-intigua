require 'puppet/type'

Puppet::Type.newtype :tag do
    @doc = "Add a tag to this node"

  newparam :name, :namevar => true do
      desc "Tag name."
  end

  newparam :coreserverurl do
    desc "REST API entry point"
  end

  newparam :user do
    desc "User name for api access."
  end

  newparam :apikey do
    desc "API key for the user."
  end

  ensurable do
    defaultvalues
    defaultto :present
  end

end
