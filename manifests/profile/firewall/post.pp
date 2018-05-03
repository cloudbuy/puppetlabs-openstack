# post-firewall rules to reject remaining traffic
class openstack::profile::firewall::post {
  firewall { '8599 - Accept all management network traffic':
    proto  => 'all',
    state  => ['NEW'],
    action => 'accept',
    source => $::openstack::config::network_management,
  } ->
  firewall { '8799 - Accept all vm network traffic':
    proto  => 'all',
    state  => ['NEW'],
    action => 'accept',
    source => $::openstack::config::network_data,
  } ->
  firewall { '8999 - Reject remaining traffic':
    proto  => 'all',
    action => 'reject',
    reject => 'icmp-host-prohibited',
    source => '0.0.0.0/0',
  }
}
