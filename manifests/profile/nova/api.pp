# The profile to set up the Nova controller (several services)
class openstack::profile::nova::api {

  $controller_management_address = $::openstack::config::controller_address_management

  openstack::resources::database { 'nova': }
  openstack::resources::firewall { 'Nova API': port => '8774', }
  openstack::resources::firewall { 'Nova Metadata': port => '8775', }
  openstack::resources::firewall { 'Nova EC2': port => '8773', }
  openstack::resources::firewall { 'Nova S3': port => '3333', }
  openstack::resources::firewall { 'Nova novnc': port => '6080', }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  $public_url = "${scheme}://${::openstack::config::controller_address_api}:8774"
  $admin_url = "${scheme}://${::openstack::config::controller_address_management}:8774"
  $internal_url = "${scheme}://${::openstack::config::controller_address_management}:8774"

  class { '::nova::keystone::auth':
    password        => $::openstack::config::nova_password,
    public_url      => "${public_url}/v2/%(tenant_id)s",
    admin_url       => "${admin_url}/v2/%(tenant_id)s",
    internal_url    => "${internal_url}/v2/%(tenant_id)s",
    public_url_v3   => "${public_url}/v3",
    admin_url_v3    => "${admin_url}/v3",
    internal_url_v3 => "${internal_url}/v3",
    region          => $::openstack::config::region,
  }

  include ::openstack::common::nova

  class { '::nova::api':
    admin_password                       => $::openstack::config::nova_password,
    auth_uri                             => "${scheme}://${::openstack::config::controller_address_management}:5000/",
    identity_uri                         => "${scheme}://${::openstack::config::controller_address_management}:35357/",
    neutron_metadata_proxy_shared_secret => $::openstack::config::neutron_shared_secret,
    enabled                              => true,
    api_bind_address                     => $::openstack::common::nova::nova_api_host,
    metadata_listen                      => $::openstack::common::nova::nova_api_host,
  }

  class { '::nova::compute::neutron': }

  class { '::nova::vncproxy':
    host              => $::openstack::common::nova::nova_api_host,
    vncproxy_protocol => $scheme,
    enabled           => true,
  }

  class { '::nova::objectstore':
    bind_address => $::openstack::common::nova::nova_api_host,
    enabled      => true,
  }

  class { [
    'nova::scheduler',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor'
  ]:
    enabled => true
  }
}
