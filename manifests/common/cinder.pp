# Common class for cinder installation
# Private, and should not be used on its own
class openstack::common::cinder {

  if ($::openstack::config::ha and $::openstack::profile::base::is_controller) {
    $cinder_host        = $::openstack::profile::base::management_address
    $management_address = $::openstack::profile::base::management_address
  } else {
    $cinder_host = '0.0.0.0'
    $management_address  = $::openstack::config::controller_address_management
  }

  $user                = $::openstack::config::mysql_user_cinder
  $pass                = $::openstack::config::mysql_pass_cinder
  $database_connection = "mysql://${user}:${pass}@${management_address}/cinder"

  class { '::cinder':
    database_connection => $database_connection,
    rabbit_hosts        => $::openstack::config::rabbitmq_hosts,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
#    rabbit_ha_queues    => $::openstack::config::ha, # FIXME: Mitaka adds the parameter
    rabbit_use_ssl      => $::openstack::config::ssl,
    debug               => $::openstack::config::debug,
    verbose             => $::openstack::config::verbose,
  }->
  file { "/etc/cinder/cinder.conf":
    ensure => present,
    owner  => 'root',
    group  => 'cinder',
    mode   => '0640',
  }->
  file { "/etc/cinder/api-paste.ini":
    ensure => present,
    owner  => 'root',
    group  => 'cinder',
    mode   => '0640',
  }->
  file { "/etc/cinder/policy.json":
    ensure => present,
    owner  => 'root',
    group  => 'cinder',
    mode   => '0640',
  }->
  file { "/etc/cinder/rootwrap.conf":
    ensure => present,
    owner  => 'root',
    group  => 'cinder',
    mode   => '0640',
  }  

  $storage_server = $::openstack::config::storage_address_api
  $glance_api_server = "${storage_server}:9292"

  class { '::cinder::glance':
    glance_api_servers => [ $glance_api_server ],
  }

  cinder_config { 'DEFAULT/rabbit_password': ensure => absent }
  cinder_config { 'DEFAULT/rabbit_userid': ensure => absent }
  cinder_config { 'DEFAULT/rabbit_virtual_host': ensure => absent }
  cinder_config { 'DEFAULT/rabbit_use_ssl': ensure => absent }
  cinder_config { 'DEFAULT/rabbit_host': ensure => absent }
  cinder_config { 'DEFAULT/rabbit_port': ensure => absent }
  cinder_config { 'DEFAULT/rabbit_hosts': ensure => absent }
  cinder_config { 'DEFAULT/rabbit_ha_queues': ensure => absent }
}
