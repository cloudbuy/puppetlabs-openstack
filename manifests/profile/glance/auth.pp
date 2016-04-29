# The profile to set up the endpoints, auth, and database for Glance
# Because of the include, api must come before auth if colocated
class openstack::profile::glance::auth {

  openstack::resources::database { 'glance': }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  class  { '::glance::keystone::auth':
    password          => $::openstack::config::glance_password,
    public_address    => $::openstack::config::storage_address_api,
    admin_address     => $::openstack::config::storage_address_management,
    internal_address  => $::openstack::config::storage_address_management,
    public_protocol   => $scheme,
    admin_protocol    => $scheme,
    internal_protocol => $scheme,
    region            => $::openstack::config::region,
  }

}
