class openstack::profile::keepalived::controller {
  class { '::keepalived': }

  $api_device = device_for_network($::openstack::config::controller_address_api)

  if ($::openstack::profile::base::is_primary_controller) {
    $state = 'MASTER'
    $priority = 101
  } else {
    $state = 'BACKUP'
    $priority = 100
  }

  keepalived::vrrp::instance { 'VI_api':
    interface         => $api_device,
    state             => $state,
    virtual_router_id => $::::openstack::config::controller_keepalived_router_id,
    priority          => $priority,
    auth_type         => 'PASS',
    auth_pass         => $::openstack::config::controller_keepalived_pass,
    virtual_ipaddress => [$::openstack::config::controller_address_api],
    track_interface   => [$api_device], 
    track_script      => 'check_haproxy',
  }

  keepalived::vrrp::script { 'check_haproxy':
    script => '/usr/bin/pkill -0 haproxy',
  }
}
