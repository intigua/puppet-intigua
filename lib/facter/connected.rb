
Facter.add(:intigua_connected) do
  confine :kernel => 'Linux'
  setcode do
    File.exists? '/usr/local/intigua/vAgentManager/'
  end
end

Facter.add(:intigua_connected) do
  confine :kernel => 'windows'
  setcode do
    require 'win32/registry'
    begin
      Win32::Registry::HKEY_LOCAL_MACHINE.open("SYSTEM\\CurrentControlSet\\services\\vAgentManager", ::Win32::Registry::KEY_READ)
      return true
    rescue
      return false
    end
  end
end



Facter.add(:intigua_coreid) do
  confine :intigua_connected => true
  confine :kernel => 'Linux'
  setcode do
    path = `cat /etc/intigua/location.conf`.strip
    file_name = "#{path}/components/csclient.cfg"

    contents = File.read(file_name)
    return contents.match('vlinkCoreId: "(.+?)"').captures[0]

  end
end

Facter.add(:intigua_coreid) do
  confine :intigua_connected => true
  confine :kernel => 'windows'
  setcode do

    require 'win32/registry'
    path = ""
    begin
      Win32::Registry::HKEY_LOCAL_MACHINE.open("VMI\\setup", ::Win32::Registry::KEY_READ) do |reg|
        path = reg["IntiguaRootDir"]
      end
    rescue
      return nil
    end

    file_name = "#{path}\\components\\csclient.cfg"

    contents = File.read(file_name)
    return contents.match('vlinkCoreId: "(.+?)"').captures[0]
  end
end
