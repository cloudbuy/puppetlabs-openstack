class openstack::common::keystone {
  if $::openstack::profile::base::is_controller {
    if $::openstack::config::keystone_use_httpd == true {
      $service_name = 'httpd'
    } else {
      $service_name = undef
    }
    if ($::openstack::config::ha == true) {
      $admin_bind_host    = $::openstack::profile::base::management_address
      $public_bind_host   = $::openstack::profile::base::management_address
      $management_address = $::openstack::profile::base::management_address
    } else {
      $admin_bind_host    = '0.0.0.0'
      $public_bind_host   = '0.0.0.0'
      $management_address = $::openstack::config::controller_address_management
    }
  } else {
    $admin_bind_host    = $::openstack::config::controller_address_management
    $management_address = $::openstack::config::controller_address_management
    $service_name       = undef
  }

  $user                = $::openstack::config::mysql_user_keystone
  $pass                = $::openstack::config::mysql_pass_keystone
  $database_connection = "mysql://${user}:${pass}@${management_address}/keystone"

  if ($::openstack::config::ssl) {
    file { '/etc/keystone/ssl':
      ensure => directory,
      owner  => 'root',
      group  => 'keystone',
      mode   => '0750',
    }->
    file { '/etc/keystone/ssl/ca.pem':
      source => $::openstack::config::ssl_cacert,
      owner  => 'root',
      group  => 'keystone',
      mode   => '0640',
    }->
    file { '/etc/keystone/ssl/cert.pem':
      source => $::openstack::config::ssl_cert,
      owner  => 'root',
      group  => 'keystone',
      mode   => '0640',
    }->
    file { '/etc/keystone/ssl/key.pem':
      source => $::openstack::config::ssl_key,
      owner  => 'root',
      group  => 'keystone',
      mode   => '0640',
    }

    $cert_file = '/etc/keystone/ssl/cert.pem'
    $key_file = '/etc/keystone/ssl/key.pem'
  } else {
    $cert_file = undef
    $key_file = undef
  }
  
  class { '::keystone':
    admin_token         => $::openstack::config::keystone_admin_token,
    database_connection => $database_connection,
    debug               => $::openstack::config::debug,
    enabled             => ($::openstack::profile::base::is_controller and $::openstack::config::keystone_use_httpd),
    admin_bind_host     => $admin_bind_host,
    admin_endpoint      => $::openstack::profile::base::auth_url,
    public_bind_host    => $public_bind_host,
    service_name        => $service_name,
    enable_ssl          => $::openstack::config::ssl,
    ssl_certfile        => $cert_file,
    ssl_keyfile         => $key_file,
    purge_config        => $::openstack::config::purge_config,
  }
}
