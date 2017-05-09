class openstack::common::neutron_taas {
  # FIXME: as and when a neutron-taas is added to the neutron module, use that. For now we
  # FIXME: implement it ourselves in this module. 
  package { 'neutron-taas-openvswitch-agent':
    ensure => installed,
  }->
  file { '/usr/bin/neutron-taas-openvswitch-agent':
    content => '#!/usr/bin/python
# PBR Generated from u\'console_scripts\'

import sys

from neutron_lbaas.cmd.lbaasv2_agent import main


if __name__ == "__main__":
    sys.exit(main())
',
		owner => 'root',
		group => 'root',
		mode  => '0755',
  }->
  service { 'neutron-taas-openvswitch-agent':
    ensure => running,
    enable => true,
  }

}
