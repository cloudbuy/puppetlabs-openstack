# Common class for neutron installation
# Private, and should not be used on its own
# Sets up configuration common to all neutron nodes.
# Flags install individual services as needed
# This follows the suggest deployment from the neutron Administrator Guide.
class openstack::common::neutron {
  $is_controller = $::openstack::profile::base::is_controller

  if ($::openstack::config::ha) and ($is_controller) {
    $neutron_bind_api              = $::openstack::profile::base::management_address
    $controller_management_address = $::openstack::profile::base::management_address
  } else {
    $neutron_bind_api              = '0.0.0.0'
    $controller_management_address = $::openstack::config::controller_address_management
  }

  $data_network = $::openstack::config::network_data
  $data_address = ip_for_network($data_network)

  # neutron auth depends upon a keystone configuration
  include ::openstack::common::keystone

  $user                = $::openstack::config::mysql_user_neutron
  $pass                = $::openstack::config::mysql_pass_neutron
  $database_connection = "mysql://${user}:${pass}@${controller_management_address}/neutron"

  if ($::openstack::config::ssl) {
    file { '/etc/neutron/ssl':
      ensure => directory,
      owner  => 'root',
      group  => 'neutron',
      mode   => '0750',
    }->
    file { '/etc/neutron/ssl/ca.pem':
      source => $::openstack::config::ssl_cacert,
      owner  => 'root',
      group  => 'neutron',
      mode   => '0640',
    }->
    file { '/etc/neutron/ssl/cert.pem':
      source => $::openstack::config::ssl_cert,
      owner  => 'root',
      group  => 'neutron',
      mode   => '0640',
    }->
    file { '/etc/neutron/ssl/key.pem':
      source => $::openstack::config::ssl_key,
      owner  => 'root',
      group  => 'neutron',
      mode   => '0640',
    }

    $cert_file = '/etc/neutron/ssl/cert.pem'
    $key_file = '/etc/neutron/ssl/key.pem'
    $scheme = 'https'
  } else {
    $cert_file = undef
    $key_file = undef
    $scheme = 'http'
  }

  $advertise_mtu = $::openstack::config::neutron_instance_mtu ? {
    undef   => false,
    default => true,
  }

  class { '::neutron':
    rabbit_host           => $controller_management_address,
    core_plugin           => $::openstack::config::neutron_core_plugin,
    allow_overlapping_ips => true,
    advertise_mtu         => $advertise_mtu,
    network_device_mtu    => $::openstack::config::neutron_instance_mtu,
    bind_host             => $neutron_bind_api,
    rabbit_user           => $::openstack::config::rabbitmq_user,
    rabbit_password       => $::openstack::config::rabbitmq_password,
    rabbit_hosts          => $::openstack::config::rabbitmq_hosts,
    rabbit_use_ssl        => $::openstack::config::ssl,
    kombu_ssl_version     => 'TLSv1_2',
    debug                 => $::openstack::config::debug,
    verbose               => $::openstack::config::verbose,
    service_plugins       => $::openstack::config::neutron_service_plugins,
    use_ssl               => $::openstack::config::ssl,
    cert_file             => $cert_file,
    key_file              => $key_file,
  }->
  file { "/etc/neutron/neutron.conf":
    ensure => present,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640',
  }->
  file { "/etc/neutron/api-paste.ini":
    ensure => present,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640',
  }->
  file { "/etc/neutron/policy.json":
    ensure => present,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640',
  }->
  file { "/etc/neutron/rootwrap.conf":
    ensure => present,
    owner  => 'root',
    group  => 'neutron',
    mode   => '0640',
  }
  neutron_config { 'DEFAULT/veth_mtu': value => $::openstack::config::neutron_instance_mtu }

  class { '::neutron::keystone::auth':
    password     => $::openstack::config::neutron_password,
    public_url   => "${scheme}://${::openstack::config::controller_address_api}:9696",
    admin_url    => "${scheme}://${::openstack::config::controller_address_management}:9696",
    internal_url => "${scheme}://${::openstack::config::controller_address_management}:9696",
    region       => $::openstack::config::region,
  }

  class { '::neutron::server':
    auth_uri                         => $::openstack::profile::base::auth_uri,
    identity_uri                     => $::openstack::profile::base::auth_url,
    auth_password                    => $::openstack::config::neutron_password,
    database_connection              => $database_connection,
    enabled                          => false,
    sync_db                          => $is_controller,
    allow_automatic_l3agent_failover => true
  }

  if $::osfamily == 'redhat' {
    package { 'iproute':
        ensure => latest,
        before => Class['::neutron']
    }
  }

  # Disable the old RabbitMQ configuration in Neutron
  neutron_config { 'DEFAULT/rabbit_hosts': ensure => absent }
  neutron_config { 'DEFAULT/rabbit_use_ssl': ensure => absent }
  neutron_config { 'DEFAULT/rabbit_userid': ensure => absent }
  neutron_config { 'DEFAULT/rabbit_password': ensure => absent }
  neutron_config { 'DEFAULT/rabbit_virtual_host': ensure => absent }
  neutron_config { 'DEFAULT/rabbit_ha_queues': ensure => absent }
}
