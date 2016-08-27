# The profile for installing the Cinder API
class openstack::profile::cinder::api {

  openstack::resources::database { 'cinder': }
  openstack::resources::firewall { 'Cinder API': port => '8776', }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  $api_v1_url = "${scheme}://${::openstack::config::controller_address_api}:8776/v1/%(tenant_id)s"
  $internal_v1_url = "${scheme}://${::openstack::config::controller_address_management}:8776/v1/%(tenant_id)s"
  $api_v2_url = "${scheme}://${::openstack::config::controller_address_api}:8776/v2/%(tenant_id)s"
  $internal_v2_url = "${scheme}://${::openstack::config::controller_address_management}:8776/v2/%(tenant_id)s"
  $api_v3_url = "${scheme}://${::openstack::config::controller_address_api}:8776/v3/%(tenant_id)s"
  $internal_v3_url = "${scheme}://${::openstack::config::controller_address_management}:8776/v3/%(tenant_id)s"

  class { '::cinder::keystone::auth':
    password        => $::openstack::config::cinder_password,
    public_url      => $api_v1_url,
    internal_url    => $internal_v1_url,
    admin_url       => $internal_v1_url,
    public_url_v2   => $api_v2_url,
    internal_url_v2 => $internal_v2_url,
    admin_url_v2    => $internal_v2_url,
    public_url_v3   => $api_v3_url,
    internal_url_v3 => $internal_v3_url,
    admin_url_v3    => $internal_v3_url,
    region          => $::openstack::config::region,
  }

  include ::openstack::common::cinder

  class { '::cinder::api':
    keystone_password => $::openstack::config::cinder_password,
    auth_uri          => $::openstack::profile::base::auth_uri,
    identity_uri      => $::openstack::profile::base::auth_url,
    enabled           => true,
    bind_host         => $::openstack::common::cinder::cinder_host,
  }

  class { '::cinder::scheduler':
    scheduler_driver => 'cinder.scheduler.filter_scheduler.FilterScheduler',
    enabled          => true,
  }
}
