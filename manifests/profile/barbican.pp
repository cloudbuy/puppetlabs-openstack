class openstack::profile::barbican {

  if ($::openstack::config::ha and $::openstack::profile::base::is_controller) {
    $management_address = $::openstack::profile::base::management_address
  } else {
    $management_address = $::openstack::config::controller_address_management
  }

	$user = $::openstack::config::barbican::mysql_user
	$pass = $::openstack::config::barbican::mysql_pass
	$database_connection = "mysql://${user}:${pass}@${management_address}/barbican"
  $scheme = $::openstack::profile::base::url_scheme
	

  openstack::resources::database { 'barbican': }
  openstack::resources::firewall { 'Barbican API': port => '9311', }

  class { '::barbican::keystone::auth':
    password     => $::openstack::config::barbican::password,
    public_url   => "${scheme}://${::openstack::config::controller_address_api}:9311",
    admin_url    => "${scheme}://${::openstack::config::controller_address_management}:9311",
    internal_url => "${scheme}://${::openstack::config::controller_address_management}:9311",
    region       => $::openstack::config::region,
  }

  class { '::barbican::keystone::authtoken':
    password          => $::openstack::config::barbican::password,
    auth_uri          => "${scheme}://${::openstack::config::controller_address_api}:5000/",
    auth_url          => "${scheme}://${::openstack::config::controller_address_management}:35357/",
    memcached_servers => $::openstack::profile::base::memcached_servers,
  }

  if ($::openstack::config::ssl) {
    Package['barbican-common']->
    file { '/etc/barbican/ssl':
      ensure => directory,
      owner  => 'root',
      group  => 'barbican',
      mode   => '0750',
    }->
    file { '/etc/barbican/ssl/ca.pem':
      source => $::openstack::config::ssl_cacert,
      owner  => 'root',
      group  => 'barbican',
      mode   => '0640',
    }->
    file { '/etc/barbican/ssl/cert.pem':
      source => $::openstack::config::ssl_cert,
      owner  => 'root',
      group  => 'barbican',
      mode   => '0640',
    }->
    file { '/etc/barbican/ssl/key.pem':
      source => $::openstack::config::ssl_key,
      owner  => 'root',
      group  => 'barbican',
      mode   => '0640',
    }->
    Class['::barbican::wsgi::apache']
    $ssl_cert_file = '/etc/barbican/ssl/cert.pem'
    $ssl_key_file = '/etc/barbican/ssl/key.pem'
  } else {
    $ssl_cert_file = undef
    $ssl_key_file = undef
  }

  class { '::barbican::wsgi::apache':
    servername => $::openstack::config::controller_address_api,
    bind_host  => $::openstack::profile::base::api_address,
    ssl        => $::openstack::config::ssl,
    ssl_cert   => $ssl_cert_file,
    ssl_key    => $ssl_key_file,
  }

	class { '::barbican': }

  class { '::barbican::api':
    default_transport_url => $::openstack::profile::base::transport_url,
    rabbit_use_ssl        => $::openstacl::config::ssl,
    rabbit_ha_queues      => $::openstacl::config::ha,
    kombu_ssl_version     => $::openstack::profile::base::ssl_version,
    service_name          => 'httpd',
  }

}
