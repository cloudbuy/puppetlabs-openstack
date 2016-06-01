# Profile to install the horizon web service
class openstack::profile::horizon {

  if ($::openstack::config::ha) {
    $horizon_bind_address = $::openstack::profile::base::management_address
  } else {
    $horizon_bind_address = undef
  }

  if ($::openstack::config::ssl) {
    $horizon_cert = '/etc/apache2/ssl/horizon.crt.pem'
    $horizon_key = '/etc/apache2/ssl/horizon.key.pem'
    $horizon_ca = '/etc/apache2/ssl/horizon.ca.pem'

    file { '/etc/apache2/ssl':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }->
    file { '/etc/apache2/ssl/horizon.crt.pem':
      source => $::openstack::config::ssl_cert,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }->
    file { '/etc/apache2/ssl/horizon.key.pem':
      source => $::openstack::config::ssl_key,
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
    }->
    file { '/etc/apache2/ssl/horizon.ca.pem':
      source => $::openstack::config::ssl_cacert,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
    $scheme = 'https'
  } else {
    $horizon_cert = undef
    $horizon_key = undef
    $horizon_ca = undef
    $scheme = 'http'
  }

  class { '::horizon':
    allowed_hosts   => concat([ '127.0.0.1', $::openstack::config::controller_address_api, $::fqdn ], $::openstack::config::horizon_allowed_hosts),
    server_aliases  => concat([ '127.0.0.1', $::openstack::config::controller_address_api, $::fqdn ], $::openstack::config::horizon_server_aliases),
    servername      => $::openstack::config::horizon_servername,
    ssl_redirect    => $::openstack::config::ssl,
    listen_ssl      => $::openstack::config::ssl,
    horizon_cert    => $horizon_cert,
    horizon_key     => $horizon_key,
    horizon_ca      => $horizon_ca,
    bind_address    => $horizon_bind_address,
    secret_key      => $::openstack::config::horizon_secret_key,
    cache_server_ip => $::openstack::config::controller_address_management,
    keystone_url    => "${scheme}://${::openstack::config::controller_address_api}:5000/v2.0",
    neutron_options => {
      enable_firewall       => true,
      enable_ha_router      => true,
      enable_lb             => false, # Even though we are using lbaas we use lbaasv2
      enable_quotas         => true,
      enable_security_group => true,
      enable_vpn            => true,
    }
  }

	# Disable TRACE method
  file { '/etc/apache2/conf.d/disable-trace.conf':
    content => "TraceEnable off\n",
    owner   => 'root',
    group   => 0,
    mode    => '0644',
  }~>Service['httpd']
  
  # PCI Hardening
  concat::fragment { 'disable_password_reveal_and_autocomplete':
    target  => $::horizon::params::config_file,
    content => 'HORIZON_CONFIG["disable_password_reveal"] = True
HORIZON_CONFIG["password_autocomplete"] = "off"
SESSION_COOKIE_HTTPONLY = True',
    order   => '60',
  }

  if ($::openstack::config::ssl) {
    concat::fragment { 'horizon_ssl_hardening':
      target  => $::horizon::params::config_file,
      content => 'SECURE_PROXY_SSL_HEADER = (\'HTTP_X_FORWARDED_PROTOCOL\', \'https\')
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True',
      order   => 60,
    }
  }

  openstack::resources::firewall { 'Apache (Horizon)': port => '80' }
  openstack::resources::firewall { 'Apache SSL (Horizon)': port => '443' }

  if $::selinux and str2bool($::selinux) != false {
    selboolean{'httpd_can_network_connect':
      value      => on,
      persistent => true,
    }
  }

}
