# The profile to set up the Ceilometer API
# For co-located api and worker nodes this appear
# after openstack::profile::ceilometer::agent
class openstack::profile::ceilometer::api {

  $mongo_username                = $::openstack::config::ceilometer_mongo_username
  $mongo_password                = $::openstack::config::ceilometer_mongo_password
  $ceilometer_management_address = $::openstack::config::ceilometer_address_management
  $controller_management_address = $::openstack::config::controller_address_management

  openstack::resources::database { 'ceilometer': }
  openstack::resources::firewall { 'Ceilometer API':
    port => '8777',
  }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  include ::openstack::common::ceilometer

  class { '::ceilometer::keystone::auth':
    password     => $::openstack::config::ceilometer_password,
    public_url   => "http://${::openstack::config::controller_address_api}:8777",
    admin_url    => "http://${::openstack::config::controller_address_management}:8777",
    internal_url => "http://${::openstack::config::controller_address_management}:8777",
    region       => $::openstack::config::region,
  }

  class { '::ceilometer::keystone::authtoken':
    auth_uri => "${scheme}://${controller_management_address}:5000/",
    auth_url => "${scheme}://${controller_management_address}:35357/", 
    password => $::openstack::config::ceilometer_password,
  }

  class { '::ceilometer::api':
    host => $::openstack::common::ceilometer::ceilometer_host,
  }

  class { '::ceilometer::db':
    database_connection => $mongo_connection,
  }

  class { '::ceilometer::agent::central':
  }

  class { '::ceilometer::expirer':
  }

  # For the time being no upstart script are provided
  # in Ubuntu 12.04 Cloud Archive. Bug report filed
  # https://bugs.launchpad.net/cloud-archive/+bug/1281722
  # https://bugs.launchpad.net/ubuntu/+source/ceilometer/+bug/1250002/comments/5
  if $::osfamily != 'Debian' {
    class { '::ceilometer::alarm::notifier':
    }

    class { '::ceilometer::alarm::evaluator':
    }
  }

  class { '::ceilometer::collector': }
}
