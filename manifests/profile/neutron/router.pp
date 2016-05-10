# The profile to set up a neutron ovs network router
class openstack::profile::neutron::router {
  ::sysctl::value { 'net.ipv4.ip_forward':
    value     => '1',
  }

  # Ensure the required modules for IPsec VPNs are loaded
  kmod::load { 'esp4': }
  kmod::load { 'esp6': }
  kmod::load { 'ah4': }
  kmod::load { 'ah6': }
  kmod::load { 'af_key': }
  kmod::load { 'xfrm_user': }
  kmod::load { 'xfrm_ipcomp': }

  $controller_management_address = $::openstack::config::controller_address_management

  $dnsmasq_config_file = $::openstack::config::neutron_instance_mtu ? {
    undef   => undef,
    default => '/etc/neutron/dnsmasq-neutron.conf'
  }

  include ::openstack::common::neutron
  include ::openstack::common::ml2::ovs


  ### Router service installation
  class { '::neutron::agents::l3':
    package_ensure          => 'absent',
    debug                   => $::openstack::config::debug,
    external_network_bridge => '',
    manage_service          => false,
  }

  class { '::neutron::agents::dhcp':
    debug               => $::openstack::config::debug,
    dnsmasq_config_file => $dnsmasq_config_file,
    enabled             => true,
  }

  class { '::neutron::agents::vpnaas':
    external_network_bridge => '',
    enabled                 => true,
  }

  if (is_array($::dnsclient::nameservers)) {
    neutron_dhcp_agent_config { 'DEFAULT/dnsmasq_dns_servers': value => join($::dnsclient::nameservers, ',') }
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


  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  class { '::neutron::agents::metadata':
    auth_password => $::openstack::config::neutron_password,
    shared_secret => $::openstack::config::neutron_shared_secret,
    auth_url      => "${scheme}://${controller_management_address}:35357/v2.0",
    debug         => $::openstack::config::debug,
    auth_region   => $::openstack::config::region,
    metadata_ip   => $controller_management_address,
    enabled       => true,
  }

  if $::openstack::config::ssl { 
    neutron_metadata_agent_config { 'DEFAULT/use_ssl': value => true; }
  }

  # NOTE: The upstream neutron module doesn't currently support lbaasv2 so we're going to use
  # the ::neutron::agents::lbaas class to perform the configuration then add the package/service
  # management here.
  class { '::neutron::agents::lbaas':
    debug         => $::openstack::config::debug,
    device_driver => 'neutron_lbaas.drivers.haproxy.namespace_driver.HaproxyNSDriver',
    enabled       => false,
  }->
  package { 'neutron-lbaasv2-agent':
    ensure => present,
  }->
  service { 'neutron-lbaasv2-agent':
    ensure => running,
    enable => true,
  }

  Neutron_config<||>             ~> Service['neutron-lbaasv2-agent']
  Neutron_lbaas_agent_config<||> ~> Service['neutron-lbaasv2-agent']

  class { '::neutron::agents::metering':
    enabled => true,
  }

  class { '::neutron::services::fwaas':
    enabled              => true,
  }
}
