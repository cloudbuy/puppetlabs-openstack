class openstack::profile::ceilometer::agent {
  $controller_management_address = $::openstack::config::controller_address_management
  include ::openstack::common::ceilometer
  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }
  class { '::ceilometer::agent::auth':
    auth_url      => "${scheme}://${controller_management_address}:5000/v2.0",
    auth_password => $::openstack::config::ceilometer_password,
    auth_region   => $::openstack::config::region,
  }
  class { '::ceilometer::agent::compute': }
}
