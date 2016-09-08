# The profile to set up the neutron server
class openstack::profile::neutron::server {

  openstack::resources::database { 'neutron': }
  openstack::resources::firewall { 'Neutron API': port => '9696', }

  include ::openstack::common::neutron

  $tenant_network_type           = $::openstack::config::neutron_tenant_network_type # ['gre']
  $type_drivers                  = $::openstack::config::neutron_type_drivers # ['gre']
  $mechanism_drivers             = $::openstack::config::neutron_mechanism_drivers # ['openvswitch']
  $tunnel_id_ranges              = $::openstack::config::neutron_tunnel_id_ranges # ['1:1000']
  $controller_management_address = $::openstack::config::controller_address_management

  class  { '::neutron::plugins::ml2':
    type_drivers         => $type_drivers,
    tenant_network_types => $tenant_network_type,
    mechanism_drivers    => $mechanism_drivers,
    tunnel_id_ranges     => $tunnel_id_ranges
  }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  if ($::openstack::config::ssl) {
    File['/etc/neutron/ssl/key.pem']->
    ::Openstacklib::Wsgi::Apache['neutron_wsgi']
    $ssl_cert_file = '/etc/neutron/ssl/cert.pem'
    $ssl_key_file = '/etc/neutron/ssl/key.pem'
  } else {
    $ssl_cert_file = undef
    $ssl_key_file = undef
  }

  file { '/usr/lib/cgi-bin/neutron':
    ensure  => directory,
    owner   => 'neutron',
    group   => 'neutron',
    mode    => '0755',
    require => Package['httpd'],
  }->
  ::openstacklib::wsgi::apache { 'neutron_wsgi':
    bind_host           => $::openstack::profile::base::management_address,
    bind_port           => 9696,
    group               => 'neutron',
    path                => '/',
    priority            => '10',
    servername          => $::openstack::config::controller_address_api,
    ssl                 => $::openstack::config::ssl,
    ssl_cert            => $ssl_cert_file,
    ssl_key             => $ssl_key_file,
    threads             => $::processorcount,
    user                => 'neutron',
    workers             => 1,
    wsgi_daemon_process => 'neutron-server',
    wsgi_process_group  => 'neutron-server',
    wsgi_script_dir     => '/usr/lib/cgi-bin/neutron',
    wsgi_script_file    => 'neutron-server',
    wsgi_script_source  => '/usr/bin/neutron-wsgi'
  }

  anchor { 'neutron_common_first': } ->
  class { '::neutron::server::notifications':
    auth_url    => "${scheme}://${controller_management_address}:35357/",
    nova_url    => "${scheme}://${controller_management_address}:8774/v2/",
    password    => $::openstack::config::nova_password,
    region_name => $::openstack::config::region,
  } ->
  anchor { 'neutron_common_last': }

  Class['::neutron::db::mysql'] -> Exec['neutron-db-sync']
}
