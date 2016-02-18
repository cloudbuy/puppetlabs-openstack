# The profile to install the Keystone service
class openstack::profile::keystone {

  openstack::resources::database { 'keystone': }
  openstack::resources::firewall { 'Keystone API': port => '5000', }
  openstack::resources::firewall { 'Keystone Admin API': port => '35357', }

  include ::openstack::common::keystone

  class { '::keystone::roles::admin':
    email        => $::openstack::config::keystone_admin_email,
    password     => $::openstack::config::keystone_admin_password,
    admin_tenant => 'admin',
  }

  class { 'keystone::endpoint':
    public_url   => "http://${::openstack::config::controller_address_api}:5000/",
    admin_url    => "http://${::openstack::config::controller_address_management}:35357/",
    internal_url => "http://${::openstack::config::controller_address_management}:5000/",
    region       => $::openstack::config::region,
    version      => '',
  }

  if $::openstack::config::keystone_use_httpd == true {
    class { '::keystone::wsgi::apache':
      ssl => false,
    }
  }

  $tenants = $::openstack::config::keystone_tenants
  $users   = $::openstack::config::keystone_users
  create_resources('openstack::resources::tenant', $tenants)
  create_resources('openstack::resources::user', $users)
  
  # Limit the request size
  keystone_config {
    'oslo_middleware/max_request_body_size': value => 114688,
  }

  # Remove admin_auth_token from the pipeline
  # Taken from upstream commit 80ae141
  Ini_subsetting {
    require => Class['keystone::roles::admin'],
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
