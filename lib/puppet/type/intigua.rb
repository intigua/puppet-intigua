require 'puppet/type'

Puppet::Type.newtype :intigua do
    @doc = "A represents intigua node. This resources allows you to deploy the intigua connector."

  newparam :name, :namevar => true do
      desc "intigua node name."
  end

  newproperty(:connected) do
    desc "Is it connected to intigua."
    #newvalue(:true)
    #newvalue(:false)
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
