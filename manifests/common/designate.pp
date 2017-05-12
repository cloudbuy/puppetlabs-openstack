class openstack::common::designate {
  if ($::openstack::config::ha and $::openstack::profile::base::is_controller) {
    $management_address = $::openstack::profile::base::management_address
  } else {
    $management_address = $::openstack::config::controller_address_management
  }
  $user = $::openstack::config::designate::mysql_user
  $pass = $::openstack::config::designate::mysql_pass
  $database_connection = "mysql://${user}:${pass}@${management_address}/designate"

  class { '::designate':
    default_transport_url => $::openstack::profile::base::transport_url,
    rabbit_ha_queues      => $::openstack::config::ha,
    rabbit_use_ssl        => $::openstack::config::ssl,
    kombu_ssl_version     => $::openstack::profile::base::ssl_version,
    debug                 => $::openstack::config::debug,
    purge_config          => $::openstack::config::purge_config,
  }

  class { '::designate::keystone::authtoken':
    password          => $::openstack::config::designate::password,
    auth_uri          => "${scheme}://${::openstack::config::controller_address_api}:5000/",
    auth_url          => "${scheme}://${::openstack::config::controller_address_management}:35357/",
    memcached_servers => $::openstack::profile::base::memcached_servers,
  }

  class { '::designate::db':
    database_connection => $database_connection,
  }
}
