# Common class for cinder installation
# Private, and should not be used on its own
class openstack::common::cinder {

  $management_address  = $::openstack::config::controller_address_management
  $user                = $::openstack::config::mysql_user_cinder
  $pass                = $::openstack::config::mysql_pass_cinder
  $database_connection = "mysql://${user}:${pass}@${management_address}/cinder"

  class { '::cinder':
    database_connection => $database_connection,
    rabbit_host         => $::openstack::config::controller_address_management,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    debug               => $::openstack::config::debug,
    verbose             => $::openstack::config::verbose,
    mysql_module        => '2.2',
  }->
  file { "/etc/cinder/cinder.conf":
    ensure => present,
    owner  => 'root',
    group  => 'cinder',
    mode   => 0640,
  }->
  file { "/etc/cinder/api-paste.ini":
    ensure => present,
    owner  => 'root',
    group  => 'cinder',
    mode   => 0640,
  }->
  file { "/etc/cinder/policy.json":
    ensure => present,
    owner  => 'root',
    group  => 'cinder',
    mode   => 0640,
  }->
  file { "/etc/cinder/rootwrap.conf":
    ensure => present,
    owner  => 'root',
    group  => 'cinder',
    mode   => 0640,
  }  

  $storage_server = $::openstack::config::storage_address_api
  $glance_api_server = "${storage_server}:9292"

  class { '::cinder::glance':
    glance_api_servers => [ $glance_api_server ],
  }
}
