# The profile to set up the endpoints, auth, and database for Glance
# Because of the include, api must come before auth if colocated
class openstack::profile::glance::auth {

  openstack::resources::database { 'glance': }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  class  { '::glance::keystone::auth':
    password     => $::openstack::config::glance_password,
    public_url   => "${scheme}://${::openstack::config::storage_address_api}:9292",
    admin_url    => "${scheme}://${::openstack::config::storage_address_management}:9292",
    internal_url => "${scheme}://${::openstack::config::storage_address_management}:9292",
    region       => $::openstack::config::region,
  }

}
