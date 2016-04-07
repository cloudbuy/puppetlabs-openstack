# Common class for ceilometer installation
# Private, and should not be used on its own
class openstack::common::ceilometer {

  if ($::openstack::config::ha) {
    $ceilometer_host = $::openstack::profile::base::management_address
  } else {
    $ceilometer_host = '0.0.0.0'
  }

  class { '::ceilometer':
    metering_secret  => $::openstack::config::ceilometer_meteringsecret,
    debug            => $::openstack::config::debug,
    verbose          => $::openstack::config::verbose,
    rabbit_hosts     => $::openstack::config::rabbitmq_hosts,
    rabbit_userid    => $::openstack::config::rabbitmq_user,
    rabbit_password  => $::openstack::config::rabbitmq_password,
    rabbit_ha_queues => $::openstack::config::ha,
    rabbit_use_ssl   => $::openstack::config::ssl,
  }

}

