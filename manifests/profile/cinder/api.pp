# The profile for installing the Cinder API
class openstack::profile::cinder::api {

  openstack::resources::database { 'cinder': }
  openstack::resources::firewall { 'Cinder API': port => '8776', }

  class { '::cinder::keystone::auth':
    password          => $::openstack::config::cinder_password,
    public_address    => $::openstack::config::controller_address_api,
    admin_address     => $::openstack::config::controller_address_management,
    internal_address  => $::openstack::config::controller_address_management,
    public_protocol   => 'https',
    admin_protocol    => 'https',
    internal_protocol => 'https',
    region            => $::openstack::config::region,
  }

  include ::openstack::common::cinder

  class { '::cinder::api':
    keystone_password => $::openstack::config::cinder_password,
    auth_uri          => "http://${::openstack::config::controller_address_management}:5000/",
    identity_uri      => "http://${::openstack::config::controller_address_management}:35357/",
    enabled           => true,
    bind_host         => $::openstack::common::cinder::cinder_host,
  }

  class { '::cinder::scheduler':
    scheduler_driver => 'cinder.scheduler.filter_scheduler.FilterScheduler',
    enabled          => true,
  }
}
