# The profile for installing the heat API
class openstack::profile::heat::api {

  openstack::resources::database { 'heat': }
  openstack::resources::firewall { 'Heat API': port     => '8004', }
  openstack::resources::firewall { 'Heat CFN API': port => '8000', }


  if ($::openstack::config::ha) {
    $heat_api_host      = $::openstack::profile::base::management_address
    $management_address = $::openstack::profile::base::management_address
  } else {
    $heat_api_host      = $::openstack::config::controller_address_api
    $management_address = $::openstack::config::controller_address_management
  }

  $user                          = $::openstack::config::mysql_user_heat
  $pass                          = $::openstack::config::mysql_pass_heat
  $database_connection           = "mysql://${user}:${pass}@${management_address}/heat"

  class { '::heat::keystone::auth':
    password         => $::openstack::config::heat_password,
    public_address   => $::openstack::config::controller_address_api,
    admin_address    => $::openstack::config::controller_address_management,
    internal_address => $::openstack::config::controller_address_management,
    region           => $::openstack::config::region,
  }

  class { '::heat::keystone::auth_cfn':
    password         => $::openstack::config::heat_password,
    public_address   => $::openstack::config::controller_address_api,
    admin_address    => $::openstack::config::controller_address_management,
    internal_address => $::openstack::config::controller_address_management,
    region           => $::openstack::config::region,
  }

  class { '::heat':
    database_connection => $database_connection,
    rabbit_host         => $::openstack::config::controller_address_management,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    rabbit_ha_queues    => $::openstack::config::ha,
    rabbit_use_ssl      => $::openstack::config::ssl,
    debug               => $::openstack::config::debug,
    verbose             => $::openstack::config::verbose,
    keystone_host       => $::openstack::config::controller_address_management,
    keystone_password   => $::openstack::config::heat_password,
  }

  class { '::heat::api':
    bind_host => $heat_api_host,
  }

  class { '::heat::api_cfn':
    bind_host => $heat_api_host,
  }

  class { '::heat::engine':
    auth_encryption_key => $::openstack::config::heat_encryption_key,
  }

  heat_config { 'DEFAULT/rabbit_password': ensure => absent }
  heat_config { 'DEFAULT/rabbit_userid': ensure => absent }
  heat_config { 'DEFAULT/rabbit_virtual_host': ensure => absent }
  heat_config { 'DEFAULT/rabbit_use_ssl': ensure => absent }
  heat_config { 'DEFAULT/rabbit_host': ensure => absent }
  heat_config { 'DEFAULT/rabbit_port': ensure => absent }
  heat_config { 'DEFAULT/rabbit_hosts': ensure => absent }
  heat_config { 'DEFAULT/rabbit_ha_queues': ensure => absent }

}
