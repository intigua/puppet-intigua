define intigua::tag (
  $ensure = 'present',
) {

  if ! defined(Class['intigua']) {
    fail('You must include the intigua base class before using any intigua defined resources')
  }

  # create a vagent reseource
  tag { $title:
      ensure        => $ensure,
      coreserverurl => $::intigua::api_endpoint,
      user          => $::intigua::api_user,
      apikey        => $::intigua::api_key,
  }

}
