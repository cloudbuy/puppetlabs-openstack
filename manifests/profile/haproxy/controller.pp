# Profile to configure HAProxy to loadbalance API services on the controller
class openstack::profile::haproxy::controller {

  unless ($::openstack::config::ha) {
    fail("HAProxy on the controller is only supported when using high availability")
  }

  $management_address = $::openstack::config::controller_address_management

  sysctl::value { 'net.ipv4.ip_nonlocal_bind': value => 1 }->
  class { '::haproxy':
    defaults_options => {
      'log'     => 'global',
      'mode'    => 'http',
      'option'  => [
        'httplog',
        'dontlognull',
        'redispatch',
        'log-health-checks',
      ],
      'retries' => 3,
      'timeout' => [
        'connect 5000ms',
        'client 50000ms',
        'server 50000ms',
      ]
    },
    global_options => {
      'log'             => '/dev/log local0 info',
      'tune.bufsize'    => 32768, # 32kb,
      'tune.maxrewrite' => 16384, # 16kb,
      'daemon'          => '',
      'uid'             => 604,
      'gid'             => 604,
      'debug'           => '',
      'pidfile'         => '/var/run/haproxy.pid',
      'stats'           => ['socket /var/run/haproxy.sock level admin'],
      'spread-checks'   => 5,
    },
  }

  # Compute the server_names and server_addresses once, they'll be common amongst most of the balancemembers
  $server_names = keys($::openstack::config::controllers)
  $server_addrs = $::openstack::config::controllers.map |String $name, Hash $addr| { $addr['management'] }

  $glance_names = keys($::openstack::config::storage)
  $glance_addrs = $::openstack::config::storage.map |String $name, Hash $addr| { $addr['management'] }

  define api_service($address, $port, $server_names, $server_addresses) {
    haproxy::listen { $name:
      bind => {"${address}:${port}" => []},
      options => {
        'option'  => [
          'httpchk HEAD /',
          'tcpka',
          'forwardfor',
        ],
        'balance' => 'source',
      }
    }

    notify { "${name} - addresses ${server_addresses}": }
    notify { "${name} - names ${server_names}": }

    haproxy::balancermember { $name:
      listening_service => $name,
      ports             => $port,
      ipaddresses       => $server_addresses,
      server_names      => $server_names,
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }

  openstack::profile::haproxy::controller::api_service { 'keystone-admin':
    address          => $management_address,
    port             => 35357,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'keystone-public':
    address          => $management_address,
    port             => 5000,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'nova':
    address          => $management_address,
    port             => 8774,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'nova-ec2':
    address          => $management_address,
    port             => 8773,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'nova-metadata':
    address          => $management_address,
    port             => 8775,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'nova-novnc':
    address          => $management_address,
    port             => 6080,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'neutron':
    address          => $management_address,
    port             => 9696,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'cinder':
    address          => $management_address,
    port             => 8776,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'glance':
    address          => $management_address,
    port             => 9292,
    server_names     => $glance_names,
    server_addresses => $glance_addrs,
  }

  openstack::profile::haproxy::controller::api_service { 'heat':
    address          => $management_address,
    port             => 8004,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'heat-cfn':
    address          => $management_address,
    port             => 8000,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'horizon':
    address          => $management_address,
    port             => 80,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  openstack::profile::haproxy::controller::api_service { 'ceilometer':
    address          => $management_address,
    port             => 8777,
    server_names     => $server_names,
    server_addresses => $server_addresses,
  }

  haproxy::listen { 'mysql':
    bind    => {"${management_address}:3306" => []},
    options => {
      'mode'    => 'tcp',
      'option'  => [
        'mysql-check user haproxy',
        'tcplog',
      ],
      'balance' => 'source',
    },
  }

  haproxy::balancermember { 'mysql':
    listening_service => 'mysql',
    ports             => 3306,
    ipaddresses       => $server_addresses,
    server_names      => $server_names,
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
