class openstack::profile::designate::api {

  openstack::resources::database { 'designate': }

  $scheme = $::openstack::profile::base::url_scheme

  class { '::designate::keystone::auth':
    password     => $::openstack::config::designate::password,
    public_url   => "${scheme}://${::openstack::config::controller_address_api}:9001",
    admin_url    => "${scheme}://${::openstack::config::controller_address_management}:9001",
    internal_url => "${scheme}://${::openstack::config::controller_address_management}:9001",
    region       => $::openstack::config::region,
  }

  include ::openstack::common::designate

  class { '::designate::api': }
  class { '::designate::central': }

}
