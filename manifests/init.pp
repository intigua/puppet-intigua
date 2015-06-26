# == Class: vagent
#
# Full description of class vagent here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'vagent':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#

#TODO: set the title to a constant thing
class intigua  (
  $connected = true,
  $api_endpoint,
  $api_user,
  $api_key,
  ) {

  package { 'net-http-digest_auth':
      ensure   => 'installed',
      provider => 'gem',
  } ->
  intigua { 'node':
    ensure        => present,
    connected     => $connected,
    coreserverurl => $api_endpoint,
    user          => $api_user,
    apikey        => $api_key,
  }

}

# to test:
# puppet module build /tmp/m/vagent/
# puppet module install /tmp/m/vagent/pkg/intigua-vagent-0.1.0.tar.gz
# puppet apply -e 'class {'vagent': vagent_name => "dummy", vagent_version => "0.0.1", vagent_config => "yuval", api_endpoint => "https://192.168.1.134/vmanage-server/rest/rest-api", api_user => "admin", api_key => "D2EA7069-C14B-41B3-9E19-47AF05057C75"}'
