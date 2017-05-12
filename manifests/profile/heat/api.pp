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

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  class { '::heat::keystone::auth':
    password     => $::openstack::config::heat_password,
    public_url   => "${scheme}://${::openstack::config::controller_address_api}:8004/v1/%(tenant_id)s",
    admin_url    => "${scheme}://${::openstack::config::controller_address_management}:8004/v1/%(tenant_id)s",
    internal_url => "${scheme}://${::openstack::config::controller_address_management}:8004/v1/%(tenant_id)s",
    region       => $::openstack::config::region,
  }

  class { '::heat::keystone::auth_cfn':
    password     => $::openstack::config::heat_password,
    public_url   => "${scheme}://${::openstack::config::controller_address_api}:8000/v1",
    admin_url    => "${scheme}://${::openstack::config::controller_address_management}:8000/v1",
    internal_url => "${scheme}://${::openstack::config::controller_address_management}:8000/v1",
    region       => $::openstack::config::region,
  }

  class { '::heat::keystone::authtoken':
		password => $::openstack::config::heat_password,
    auth_uri => $::openstack::profile::base::auth_uri,
    auth_url => $::openstack::profile::base::auth_url,
  }

  class { '::heat':
    database_connection => $database_connection,
    rabbit_host         => $::openstack::config::controller_address_management,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    rabbit_ha_queues    => $::openstack::config::ha,
    rabbit_use_ssl      => $::openstack::config::ssl,
    kombu_ssl_version   => $::openstack::config::ssl ? {
      true    => 'TLSv1_2',
      default => undef,
    },
    debug               => $::openstack::config::debug,
    purge_config        => $::openstack::config::purge_config,
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
