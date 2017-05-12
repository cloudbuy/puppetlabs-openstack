class openstack::profile::magnum {
  if ($::openstack::config::ha and $::openstack::profile::base::is_controller) {
    $management_address = $::openstack::profile::base::management_address
  } else {
    $management_address = $::openstack::config::controller_address_management
  }
	$user = $::openstack::config::designate::mysql_user
	$pass = $::openstack::config::designate::mysql_pass
	$database_connection = "mysql://${user}:${pass}@${management_address}/designate"
  $scheme = $::openstack::profile::base::url_scheme
	

  openstack::resources::database { 'magnum': }
  openstack::resources::firewall { 'Magnum API': port => '9511', }

  class { '::magnum::keystone::auth':
    password     => $::openstack::config::magnum::password,
    public_url   => "${scheme}://${::openstack::config::controller_address_api}:9511/v1",
    admin_url    => "${scheme}://${::openstack::config::controller_address_management}:9511/v1",
    internal_url => "${scheme}://${::openstack::config::controller_address_management}:9511/v1",
    region       => $::openstack::config::region,
  }

  class { '::magnum::keystone::authtoken':
    password          => $::openstack::config::magnum::password,
    auth_uri          => "${scheme}://${::openstack::config::controller_address_api}:5000/",
    auth_url          => "${scheme}://${::openstack::config::controller_address_management}:35357/",
    memcached_servers => $::openstack::profile::base::memcached_servers,
  }

  class { '::magnum::api':
    host        => $::openstack::config::controller_address_api,
    enabled_ssl => $::openstack::config::ssl,
  }

	class { '::magnum':
    default_transport_url => $::openstack::profile::base::transport_url,
    rabbit_use_ssl        => $::openstacl::config::ssl,
    kombu_ssl_version     => $::openstack::profile::base::ssl_version,
    purge_config          => $::openstack::config::purge_config,
  }

  class { '::magnum::conductor': }

  class { '::magnum::logging':
    debug => $::openstack::config::debug,
  }
}
