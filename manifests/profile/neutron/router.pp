# The profile to set up a neutron ovs network router
class openstack::profile::neutron::router {
  ::sysctl::value { 'net.ipv4.ip_forward':
    value     => '1',
  }

  $controller_management_address = $::openstack::config::controller_address_management

  include ::openstack::common::neutron
  include ::openstack::common::ml2::ovs


  ### Router service installation
  class { '::neutron::agents::l3':
    debug                   => $::openstack::config::debug,
    external_network_bridge => 'brex',
    enabled                 => true,
  }

  class { '::neutron::agents::dhcp':
    debug   => $::openstack::config::debug,
    enabled => true,
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

  if ($::openstack::config::network_external) {
    $external_bridge = $::openstack::config::network_external_bridge

    if ($::openstack::config::network_external_device) {
      $external_device = $::openstack::config::network_external_device
    } else {
      $external_network = $::openstack::config::network_external
      $external_device = device_for_network($external_network)
    }

    vs_bridge { $external_bridge:
      ensure => present,
    }
    if $external_device != $external_bridge {
      vs_port { $external_device:
        ensure => present,
        bridge => $external_bridge
      }
    } else {
      # External bridge already has the external device's IP, thus the external
      # device has already been linked
    }
  }
}
