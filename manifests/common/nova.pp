# Common class for nova installation
# Private, and should not be used on its own
# usage: include from controller, declare from worker
# This is to handle dependency
# depends on openstack::profile::base having been added to a node
class openstack::common::nova {

  $storage_management_address = $::openstack::config::storage_address_management
  $controller_management_address = $::openstack::config::controller_address_management

  if ($::openstack::config::ha) {
    $nova_api_host      = $::openstack::profile::base::management_address
    $management_address = $::openstack::profile::base::management_address
    $memcached_servers  = $::openstack::profile::base::controller_management_addresses.map |$x| { "${x}:11211" }
  } else {
    $nova_api_host      = '0.0.0.0'
    $management_address = $::openstack::config::controller_address_management
    $memcached_servers  = ["${controller_management_address}:11211"]
  }

  $user                = $::openstack::config::mysql_user_nova
  $pass                = $::openstack::config::mysql_pass_nova
  $database_connection = "mysql://${user}:${pass}@${management_address}/nova"

  class { '::nova':
    database_connection => $database_connection,
    glance_api_servers  => join($::openstack::config::glance_api_servers, ','),
    memcached_servers   => $memcached_servers,
    rabbit_hosts        => $::openstack::config::rabbitmq_hosts,
    rabbit_userid       => $::openstack::config::rabbitmq_user,
    rabbit_password     => $::openstack::config::rabbitmq_password,
    debug               => $::openstack::config::debug,
    verbose             => $::openstack::config::verbose,
  }-> 
  file { "/etc/nova/api-paste.ini":
    ensure => present,
    owner  => 'root',
    group  => 'nova',
    mode   => '0640',
  }->
  file { "/etc/nova/policy.json":
    ensure => present,
    owner  => 'root',
    group  => 'nova',
    mode   => '0640',
  }->
  file { "/etc/nova/rootwrap.conf":
    ensure => present,
    owner  => 'root',
    group  => 'nova',
    mode   => '0640',
  }

  File<| title == '/etc/nova/nova.conf' |> {
    ensure => present,
    owner  => 'root',
    group  => 'nova',
    mode   => '0640',
  }

  # Play better with Windows instances when doing a guest shutdown
  nova_config { 'DEFAULT/shutdown_timeout': value => '300'; }
  
  class { '::nova::network::neutron':
    neutron_admin_password => $::openstack::config::neutron_password,
    neutron_region_name    => $::openstack::config::region,
    neutron_admin_auth_url => "http://${controller_management_address}:35357/v2.0",
    neutron_url            => "http://${controller_management_address}:9696",
    vif_plugging_is_fatal  => false,
    vif_plugging_timeout   => '0',
  }
}
