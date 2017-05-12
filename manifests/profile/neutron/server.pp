# The profile to set up the neutron server
class openstack::profile::neutron::server {

  openstack::resources::database { 'neutron': }
  openstack::resources::firewall { 'Neutron API': port => '9696', }

  include ::openstack::common::neutron

  $tenant_network_type           = $::openstack::config::neutron_tenant_network_type # ['gre']
  $type_drivers                  = $::openstack::config::neutron_type_drivers # ['gre']
  $mechanism_drivers             = $::openstack::config::neutron_mechanism_drivers # ['openvswitch']
  $tunnel_id_ranges              = $::openstack::config::neutron_tunnel_id_ranges # ['1:1000']
  $controller_api_address        = $::openstack::config::controller_address_api
  $controller_management_address = $::openstack::config::controller_address_management

  class  { '::neutron::plugins::ml2':
    type_drivers         => $type_drivers,
    tenant_network_types => $tenant_network_type,
    mechanism_drivers    => $mechanism_drivers,
    tunnel_id_ranges     => $tunnel_id_ranges,
    extension_drivers    => 'port_security',
    purge_config         => $::openstack::config::purge_config,
  }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

neutron_config { 'DEFAULT/allow_automatic_lbaas_agent_failover': value => true; }

  anchor { 'neutron_common_first': } ->
  class { '::neutron::server::notifications':
    auth_url    => "${scheme}://${controller_management_address}:35357/",
    password    => $::openstack::config::nova_password,
    region_name => $::openstack::config::region,
  } ->
  anchor { 'neutron_common_last': }

  class { '::neutron::services::fwaas':
    enabled       => true,
    driver        => 'neutron.services.firewall.drivers.linux.iptables_fwaas.IptablesFwaasDriver',
    agent_version => 'v2'
  }

  package { 'python-neutron-taas':
    ensure => installed,
  }

  Class['::neutron::db::mysql'] -> Exec['neutron-db-sync']
}
