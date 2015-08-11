# Private class
# Set up the OVS agent
class openstack::common::ml2::ovs {
  $data_network        = $::openstack::config::network_data
  $data_address        = ip_for_network($data_network)
  $enable_tunneling    = $::openstack::config::neutron_tunneling # true
  $tunnel_types        = $::openstack::config::neutron_tunnel_types #['gre']

  # Load the module required for tracking state in the GRE protocol
  kmod::load { 'nf_conntrack_proto_gre': }

  class { '::neutron::agents::ml2::ovs':
    enable_tunneling => $enable_tunneling,
    local_ip         => $data_address,
    enabled          => true,
    tunnel_types     => $tunnel_types,
  }
}
