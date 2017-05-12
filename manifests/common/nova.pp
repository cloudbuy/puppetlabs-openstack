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
  } else {
    $nova_api_host      = '0.0.0.0'
    $management_address = $::openstack::config::controller_address_management
  }

  $user                = $::openstack::config::mysql_user_nova
  $pass                = $::openstack::config::mysql_pass_nova
  $database_connection = "mysql://${user}:${pass}@${management_address}/nova"
  $user_api                = $::openstack::config::mysql_user_nova_api
  $pass_api                = $::openstack::config::mysql_pass_nova_api
  $api_database_connection = "mysql://${user_api}:${pass_api}@${management_address}/nova_api"

  if ($::openstack::config::ssl) {
    Package['nova-common']->
    file { '/etc/nova/ssl':
      ensure => directory,
      owner  => 'root',
      group  => 'nova',
      mode   => '0750',
    }->
    file { '/etc/nova/ssl/ca.pem':
      source => $::openstack::config::ssl_cacert,
      owner  => 'root',
      group  => 'nova',
      mode   => '0640',
    }->
    file { '/etc/nova/ssl/cert.pem':
      source => $::openstack::config::ssl_cert,
      owner  => 'root',
      group  => 'nova',
      mode   => '0640',
    }->
    file { '/etc/nova/ssl/key.pem':
      source => $::openstack::config::ssl_key,
      owner  => 'root',
      group  => 'nova',
      mode   => '0640',
    }

    $cert_file = '/etc/nova/ssl/cert.pem'
    $key_file = '/etc/nova/ssl/key.pem'
    $scheme = 'https'
    $transport_url = "rabbit://${::openstack::config::rabbitmq_hosts}:5671"
  } else {
    $cert_file = undef
    $key_file = undef
    $scheme = 'http'
    $transport_url = "rabbit://${::openstack::config::rabbitmq_hosts}:5672"
  }

  class { '::nova':
    database_connection     => $database_connection,
    default_transport_url   => 'rabbit:///',
    api_database_connection => $api_database_connection,
    glance_api_servers      => join($::openstack::config::glance_api_servers, ','),
    rabbit_hosts            => $::openstack::config::rabbitmq_hosts,
    rabbit_userid           => $::openstack::config::rabbitmq_user,
    rabbit_password         => $::openstack::config::rabbitmq_password,
    rabbit_ha_queues        => $::openstack::config::ha,
    rabbit_use_ssl          => $::openstack::config::ssl,
    kombu_ssl_version       => $::openstack::config::ssl ? {
      true    => 'TLSv1_2',
      default => undef,
    },
    use_ssl                 => $::openstack::config::ssl,
    cert_file               => $cert_file,
    key_file                => $key_file,
    debug                   => $::openstack::config::debug,
    purge_config            => $::openstack::config::purge_config,
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
    neutron_admin_auth_url => "${scheme}://${controller_management_address}:35357/v3",
    neutron_url            => "${scheme}://${controller_management_address}:9696",
    vif_plugging_is_fatal  => false,
    vif_plugging_timeout   => '0',
  }
}
