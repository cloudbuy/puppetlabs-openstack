# Profile to configure HAProxy to loadbalance API services on the controller
class openstack::profile::haproxy::controller {

  unless ($::openstack::config::ha) {
    fail("HAProxy on the controller is only supported when using high availability")
  }

  $management_address = $::openstack::config::controller_address_management

  class { '::haproxy':
    defaults_options => [
      'log'     => 'global',
      'mode'    => 'http',
      'option'  => [
        'httplog',
        'dontlognull',
        'redispatch',
        'log-health-checks',
      ],
      'retries' => 3,
    ],
    global_options => {
      'tune.bufsize'    => 32768, # 32kb,
      'tune.maxrewrite' => 16384, # 16kb,
      'daemon'          => undef,
      'stats'           => ['socket /var/run/haproxy.sock level admin'],
      'spread-checks'   => 5,
    ]
  }

  # Compute the server_names and server_addresses once, they'll be common amongst most of the balancemembers
  $server_names = keys($::openstack::config::controllers)
  $server_addresses = $::openstack::config::controllers.map |String $name, Hash $info| { $info['management'] }

  define openstack_api_service($port, $server_names, $server_addresses) {
    haproxy::listen { $name:
      bind => {"${management_address}:${port}" => []},
    }

    $ports = $server_names.map |$_| { $port }
    haproxy::balancemember { $name:
      listening_service => $name,
      ports             => $ports,
      ipaddresses       => $server_addresses,
      server_names      => $server_names,
    }
  }

  openstack_api_service { 'keystone-admin':
    port             => 35357,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack_api_service { 'keystone-public':
    port             => 5000,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack_api_service { 'nova':
    port             => 8774,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack_api_service { 'nova-ec2':
    port             => 8773,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack_api_service { 'neutron':
    port             => 9696,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack_api_service { 'cinder':
    port             => 8776,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack_api_service { 'glance':
    port             => 9292,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack_api_service { 'heat':
    port             => 8004,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack_api_service { 'heat-cfn':
    port             => 8000,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack_api_service { 'ceilometer':
    port             => 8777,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }
}
