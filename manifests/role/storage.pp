class openstack::role::storage(
  Boolean $enable_firewall      = false,
  Boolean $enable_glance_api    = true,
  Boolean $enable_cinder_volume = true
) inherits ::openstack::role {

  if ($enable_firewall) {
    class { '::openstack::profile::firewall': }
  }

  if ($enable_glance_api) {
    class { '::openstack::profile::glance::api': }
  }

  if ($enable_cinder_volume) {
    class { '::openstack::profile::cinder::volume': }
  }
}
