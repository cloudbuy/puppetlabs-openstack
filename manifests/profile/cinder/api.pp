# The profile for installing the Cinder API
class openstack::profile::cinder::api {

  openstack::resources::database { 'cinder': }
  openstack::resources::firewall { 'Cinder API': port => '8776', }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  $api_v1_url = "${scheme}://${::openstack::config::controller_address_api}:8776/v1/%(tenant_id)s"
  $internal_v1_url = "${scheme}://${::openstack::config::controller_address_management}:8776/v1/%(tenant_id)s"
  $api_v2_url = "${scheme}://${::openstack::config::controller_address_api}:8776/v2/%(tenant_id)s"
  $internal_v2_url = "${scheme}://${::openstack::config::controller_address_management}:8776/v2/%(tenant_id)s"
  $api_v3_url = "${scheme}://${::openstack::config::controller_address_api}:8776/v3/%(tenant_id)s"
  $internal_v3_url = "${scheme}://${::openstack::config::controller_address_management}:8776/v3/%(tenant_id)s"

  class { '::cinder::keystone::auth':
    password        => $::openstack::config::cinder_password,
    public_url      => $api_v1_url,
    internal_url    => $internal_v1_url,
    admin_url       => $internal_v1_url,
    public_url_v2   => $api_v2_url,
    internal_url_v2 => $internal_v2_url,
    admin_url_v2    => $internal_v2_url,
    public_url_v3   => $api_v3_url,
    internal_url_v3 => $internal_v3_url,
    admin_url_v3    => $internal_v3_url,
    region          => $::openstack::config::region,
  }

  include ::openstack::common::cinder

  class { '::cinder::keystone::authtoken':
    password => $::openstack::config::cinder_password,
    auth_uri => $::openstack::profile::base::auth_uri,
    auth_url => $::openstack::profile::base::auth_url,
  }

  class { '::cinder::api':
    enabled           => false,
    manage_service    => true,
    bind_host         => $::openstack::common::cinder::cinder_host,
  }

  cinder_config { 'keystone_authtoken/memcached_servers': value => $::openstack::profile::base::memcached_servers }

  class { '::cinder::scheduler':
    scheduler_driver => 'cinder.scheduler.filter_scheduler.FilterScheduler',
    enabled          => true,
  }

  if ($::openstack::config::ssl) {
    File['/etc/cinder/ssl/key.pem']->
    ::Openstacklib::Wsgi::Apache['cinder_wsgi']
    $ssl_cert_file = '/etc/cinder/ssl/cert.pem'
    $ssl_key_file = '/etc/cinder/ssl/key.pem'
  } else {
    $ssl_cert_file = undef
    $ssl_key_file = undef
  }

# FIXME: uncomment and use this on switch to Newton instead of the ::openstacklib::wsgi::apache block
#  class { '::cinder::wsgi::apache':
#    servername => $::openstack::config::controller_address_api,
#    bind_host  => $::openstack::profile::base::management_address,
#    ssl_cert   => $ssl_cert_file,
#    ssl_key    => $ssl_key_file,
#  }

  file { '/usr/lib/cgi-bin/cinder':
    ensure  => directory,
    owner   => 'cinder',
    group   => 'cinder',
    mode    => '0755',
    require => Package['httpd'],
  }->
  ::openstacklib::wsgi::apache { 'cinder_wsgi':
    bind_host           => $::openstack::profile::base::api_address,
    bind_port           => 8776,
    group               => 'cinder',
    path                => '/',
    priority            => '10',
    servername          => $::openstack::config::controller_address_api,
    ssl                 => $::openstack::config::ssl,
    ssl_cert            => $ssl_cert_file,
    ssl_key             => $ssl_key_file,
    threads             => $::processorcount,
    user                => 'cinder',
    workers             => 1,
    wsgi_daemon_process => 'cinder-api',
    wsgi_process_group  => 'cinder-api',
    wsgi_script_dir     => '/usr/lib/cgi-bin/cinder',
    wsgi_script_file    => 'cinder-api',
    wsgi_script_source  => '/usr/bin/cinder-wsgi'
  }
}
