define intigua::managementservice (
  $intigua_version,
  $intigua_config,
  $ensure = 'present',
) {
  include stdlib

  validate_string($intigua_version)
  validate_string($intigua_config)

  if ! defined(Class['intigua']) {
    fail('You must include the intigua base class before using any intigua defined resources')
  }

  if ! $::intigua::connected {
    fail('Intigua node must be connected for management services to work')
  }

  # create a vagent reseource
  managementservice { $title:
      ensure        => $ensure,
      version       => $intigua_version,
      config        => $intigua_config,
      coreserverurl => $::intigua::api_endpoint,
      user          => $::intigua::api_user,
      apikey        => $::intigua::api_key,
  }

}
