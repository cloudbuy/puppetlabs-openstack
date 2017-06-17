# The puppet module to set up a Nova Compute node
class openstack::profile::nova::compute {
  $management_network            = $::openstack::config::network_management
  $management_address            = ip_for_network($management_network)
  $controller_management_address = $::openstack::config::controller_address_management

  include ::openstack::common::nova

  class { '::nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => $management_address,
    vncproxy_host                 => $::openstack::config::controller_address_api,
  }

  if ($::facts['os']['name'] == 'Ubuntu') and (versioncmp($::facts['os']['release']['full'], '16.04') >= 0) {
    $virtlock_service_name = false
    $virtlog_service_name = false
  } else {
    $virtlock_service_name = undef
    $virtlog_service_name = undef
  }

  class { '::nova::compute::libvirt':
    libvirt_virt_type       => $::openstack::config::nova_libvirt_type,
    vncserver_listen        => $management_address,
    libvirt_hw_disk_discard => 'unmap',
    virtlock_service_name   => $virtlock_service_name,
    virtlog_service_name    => $virtlog_service_name,
  }

  class { 'nova::migration::libvirt':
  }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  file { '/etc/libvirt/qemu.conf':
    ensure => present,
    source => 'puppet:///modules/openstack/qemu.conf',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['libvirt'],
  }

  if $::osfamily == 'RedHat' {
    package { 'device-mapper':
      ensure => latest
    }
    Package['device-mapper'] ~> Service['libvirtd'] ~> Service['nova-compute']
  }
  Package['libvirt'] -> File['/etc/libvirt/qemu.conf']
}
