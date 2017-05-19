class openstack::profile::ceilometer::agent {
  include ::openstack::common::ceilometer
  class { '::ceilometer::agent::auth':
    auth_url      => $::openstack::profile::base::auth_uri,
    auth_password => $::openstack::config::ceilometer_password,
    auth_region   => $::openstack::config::region,
  }
  class { '::ceilometer::agent::compute': }
}
