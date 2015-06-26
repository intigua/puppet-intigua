require 'puppet/type'

Puppet::Type.newtype :managementservice do
    @doc = "Deploy a Management service using intigua."

  newparam :name, :namevar => true do
      desc "Management service name."
  end

  newparam :version do
      desc "Management service version."
  end

  newparam :config do
      desc "Config package name."
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
