# Common class for ceilometer installation
# Private, and should not be used on its own
class openstack::common::ceilometer {

  if ($::openstack::config::ha) {
    $ceilometer_host = $::openstack::profile::base::management_address
  } else {
    $ceilometer_host = '0.0.0.0'
  }

# FIXME: re-add rabbit_ha_queues for Mitaka
  class { '::ceilometer':
    metering_secret   => $::openstack::config::ceilometer_meteringsecret,
    debug             => $::openstack::config::debug,
    rabbit_hosts      => $::openstack::config::rabbitmq_hosts,
    rabbit_userid     => $::openstack::config::rabbitmq_user,
    rabbit_password   => $::openstack::config::rabbitmq_password,
    rabbit_use_ssl    => $::openstack::config::ssl,
    kombu_ssl_version => $::openstack::profile::base::ssl_version,
    purge_config      => $::openstack::config::purge_config,
  }

  ceilometer_config { 'DEFAULT/rabbit_password': ensure => absent }
  ceilometer_config { 'DEFAULT/rabbit_userid': ensure => absent }
  ceilometer_config { 'DEFAULT/rabbit_virtual_host': ensure => absent }
  ceilometer_config { 'DEFAULT/rabbit_use_ssl': ensure => absent }
  ceilometer_config { 'DEFAULT/rabbit_host': ensure => absent }
  ceilometer_config { 'DEFAULT/rabbit_port': ensure => absent }
  ceilometer_config { 'DEFAULT/rabbit_hosts': ensure => absent }
  ceilometer_config { 'DEFAULT/rabbit_ha_queues': ensure => absent }

}

