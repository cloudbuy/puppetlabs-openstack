# The profile to set up a neutron ovs network router
class openstack::profile::neutron::router {
  ::sysctl::value { 'net.ipv4.ip_forward':
    value     => '1',
  }

  $controller_management_address = $::openstack::config::controller_address_management

  $dnsmasq_config_file = $::openstack::config::neutron_instance_mtu ? {
    undef   => undef,
    default => '/etc/neutron/dnsmasq-neutron.conf'
  }

  include ::openstack::common::neutron
  include ::openstack::common::ml2::ovs


  ### Router service installation
  class { '::neutron::agents::l3':
    debug                   => $::openstack::config::debug,
    external_network_bridge => '',
    enabled                 => true,
  }

  class { '::neutron::agents::dhcp':
    debug               => $::openstack::config::debug,
    dnsmasq_config_file => $dnsmasq_config_file,
    enabled             => true,
  }

  if ($dnsmasq_config_file) {
    file { '/etc/neutron/dnsmasq-neutron.conf':
      content => "dhcp-option-force=26,${::openstack::config::neutron_instance_mtu}\n",
      owner   => 'root',
      group   => 0,
      mode    => '0644',
    }
    File['/etc/neutron/dnsmasq-neutron.conf'] ~> Service['neutron-dhcp-service']
  }

  class { '::neutron::agents::metadata':
    auth_password => $::openstack::config::neutron_password,
    shared_secret => $::openstack::config::neutron_shared_secret,
    auth_url      => "http://${controller_management_address}:35357/v2.0",
    debug         => $::openstack::config::debug,
    auth_region   => $::openstack::config::region,
    metadata_ip   => $controller_management_address,
    enabled       => true,
  }

  class { '::neutron::agents::lbaas':
    debug   => $::openstack::config::debug,
    enabled => true,
  }

#  class { '::neutron::agents::vpnaas':
#    enabled => true,
#  }

  class { '::neutron::agents::metering':
    enabled => true,
  }

  class { '::neutron::services::fwaas':
    enabled              => true,
  }
}
