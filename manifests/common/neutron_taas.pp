class openstack::common::neutron_taas {
  # FIXME: as and when a neutron-taas is added to the neutron module, use that. For now we
  # FIXME: implement it ourselves in this module.
  package { 'neutron-taas-openvswitch-agent':
    ensure => installed,
  }->
  service { 'neutron-taas-openvswitch-agent':
    ensure => running,
    enable => true,
  }
}
