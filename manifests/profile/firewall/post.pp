# post-firewall rules to reject remaining traffic
class openstack::profile::firewall::post {
  firewall { '88999 - Accept all management network traffic':
    proto  => 'all',
    state  => ['NEW'],
    action => 'accept',
    alias  => '8999 - Accept all management network traffic',
    source => $::openstack::config::network_management,
  } ->
  firewall { '89100 - Accept all vm network traffic':
    proto  => 'all',
    state  => ['NEW'],
    action => 'accept',
    source => $::openstack::config::network_data,
  } ->
  firewall { '89999 - Reject remaining traffic':
    proto  => 'all',
    action => 'reject',
    reject => 'icmp-host-prohibited',
    source => '0.0.0.0/0',
  }
}
