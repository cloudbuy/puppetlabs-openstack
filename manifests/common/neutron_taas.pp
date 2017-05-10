class openstack::common::neutron_taas {

  $package_ensure        = present
  $enabled               = true
  $manage_service        = true
  $taas_driver           = 'neutron_taas.services.taas.drivers.linux.ovs_taas.OvsTaasDriver'
  $taas_enabled          = true
  $taas_vlan_range_start = 3000
  $taas_vlan_range_end   = 3500
  $interface_driver      = 'neutron.agent.linux.interface.OVSInterfaceDriver'
  $purge_config          = false

  # FIXME: as and when a neutron-taas is added to the neutron module, use that. For now we
  # FIXME: implement it ourselves in this module. 
  package { 'neutron-taas-openvswitch-agent':
    ensure => present,
    tag    => ['openstack', 'neutron-package'],
  }->
  file { '/usr/bin/neutron-taas-openvswitch-agent':
    source => 'puppet:///modules/openstack/neutron-taas-openvswitch-agent',
		owner  => 'root',
		group  => 'root',
		mode   => '0755',
  }->
  service { 'neutron-taas-openvswitch-agent':
    ensure => running,
    enable => true,
    tag    => 'neutron-service',
  }

  neutron_taas_agent_config {
    'taas/driver':              value => $taas_driver;
    'taas/enabled':             value => $taas_enabled;
    'taas/vlan_range_start':    value => $taas_vlan_range_start;
    'taas/vlan_range_end':      value => $taas_vlan_range_end;
    'DEFAULT/interface_driver': value => $interface_driver;
  }

  Anchor['neutron::config::begin'] -> Neutron_taas_agent_config<||> ~> Anchor['neutron::config::end']

}
