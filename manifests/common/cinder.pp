# Common class for cinder installation
# Private, and should not be used on its own
class openstack::common::cinder {

  if ($::openstack::config::ha and $::openstack::profile::base::is_controller) {
    $management_address = $::openstack::profile::base::management_address
  } else {
    $management_address  = $::openstack::config::controller_address_management
  }

  $user                = $::openstack::config::mysql_user_cinder
  $pass                = $::openstack::config::mysql_pass_cinder
  $database_connection = "mysql://${user}:${pass}@${management_address}/cinder"


  if ($::openstack::config::ssl) {
    file { '/etc/cinder/ssl':
      ensure => directory,
      owner  => 'root',
      group  => 'cinder',
      mode   => '0750',
    }->
    file { '/etc/cinder/ssl/ca.pem':
      source => $::openstack::config::ssl_cacert,
      owner  => 'root',
      group  => 'cinder',
      mode   => '0640',
    }->
    file { '/etc/cinder/ssl/cert.pem':
      source => $::openstack::config::ssl_cert,
      owner  => 'root',
      group  => 'cinder',
      mode   => '0640',
    }->
    file { '/etc/cinder/ssl/key.pem':
      source => $::openstack::config::ssl_key,
      owner  => 'root',
      group  => 'cinder',
      mode   => '0640',
    }

    $cert_file = '/etc/cinder/ssl/cert.pem'
    $key_file = '/etc/cinder/ssl/key.pem'
  }

  class { '::cinder':
    database_connection => $database_connection,
    rabbit_hosts        => $::openstack::config::rabbitmq_hosts,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    rabbit_ha_queues    => $::openstack::config::ha,
    rabbit_use_ssl      => $::openstack::config::ssl,
    kombu_ssl_version   => $::openstack::profile::base::ssl_version,
    debug               => $::openstack::config::debug,
    use_ssl             => $::openstack::config::ssl,
    cert_file           => $cert_file,
    key_file            => $key_file,
    purge_config        => $::openstack::config::purge_config,
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
