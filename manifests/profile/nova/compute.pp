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

  class { '::nova::compute::libvirt':
    libvirt_virt_type       => $::openstack::config::nova_libvirt_type,
    vncserver_listen        => $management_address,
    libvirt_hw_disk_discard => 'unmap,'
  }

  class { 'nova::migration::libvirt':
  }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  class { '::nova::placement':
    password          => $::openstack::config::placement_password,
    auth_uri          => "${scheme}://${::openstack::config::controller_address_api}:5000/",
    auth_url          => "${scheme}://${::openstack::config::controller_address_management}:35357/",
    memcached_servers => $memcached_servers,
  }

  if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemmajrelease, '16') >= 0 {
		# If systemd is being used then libvirtd is already being launched correctly and
      # adding -d causes a second consecutive start to fail which causes puppet to fail.
      $libvirtd_opts = 'libvirtd_opts="-l"'
    } else {
      $libvirtd_opts = 'libvirtd_opts="-d -l"'
  }

  File_line <|$name =="/etc/default/${::nova::compute::libvirt::libvirt_service_name} libvirtd opts" |> {
		line  => $libvirtd_opts
  }

  file { '/etc/systemd/system/libvirt-bin.service.d/override.conf':
		ensure  => absent,
    content => "[Service]\nType=forking",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }~>
  file { '/etc/systemd/system/libvirt-bin.service.d':
    ensure => absent,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }~>
  exec { 'libvirt_reload_systemd':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
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
