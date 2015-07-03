# The profile to install an OpenStack specific MongoDB server
class openstack::profile::mongodb {
  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  class { '::mongodb::globals':
    manage_package_repo => true,
  }

  class { '::mongodb::server':
    bind_ip => ['127.0.0.1', $management_address],
  }

  class { '::mongodb::client': }
}
