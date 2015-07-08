# The profile to install a local instance of memcache
class openstack::profile::memcache {

  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  class { 'memcached':
    listen_ip => $management_address,
    tcp_port  => '11211',
    udp_port  => '11211',
  }
}
