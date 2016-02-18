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

  class { '::keystone':
    admin_token         => $::openstack::config::keystone_admin_token,
    database_connection => $database_connection,
    verbose             => $::openstack::config::verbose,
    debug               => $::openstack::config::debug,
    enabled             => $::openstack::profile::base::is_controller,
    admin_bind_host     => $admin_bind_host,
    public_bind_host    => $public_bind_host,
    service_name        => $service_name,
  }
  
  # Limit the request size
  keystone_config {
    'oslo_middleware/max_request_body_size': value => 114688,
  }

  # Remove admin_auth_token from the pipeline
	# Taken from upstream commit 80ae141
  Ini_subsetting {
    require => Class['keystone::roles::admin'],
  }

  if $::keystone::manage_service and $::keystone::enabled {
    Ini_subsetting {
      notify => Exec['restart_keystone'],
    }
  }

  ini_subsetting { 'public_api/admin_token_auth':
    ensure     => absent,
    path       => '/etc/keystone/keystone-paste.ini',
    section    => 'pipeline:public_api',
    setting    => 'pipeline',
    subsetting => 'admin_token_auth',
  }
  ini_subsetting { 'admin_api/admin_token_auth':
    ensure     => absent,
    path       => '/etc/keystone/keystone-paste.ini',
    section    => 'pipeline:admin_api',
    setting    => 'pipeline',
    subsetting => 'admin_token_auth',
  }
  ini_subsetting { 'api_v3/admin_token_auth':
    ensure     => absent,
    path       => '/etc/keystone/keystone-paste.ini',
    section    => 'pipeline:api_v3',
    setting    => 'pipeline',
    subsetting => 'admin_token_auth',
  }
}
