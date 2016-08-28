# The profile to install the Glance API and Registry services
# Note that for this configuration API controls the storage,
# so it is on the storage node instead of the control node
class openstack::profile::glance::api {
  $api_network = $::openstack::config::network_api
  $api_address = ip_for_network($api_network)

  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  $controller_address  = $::openstack::config::controller_address_management
  $user                = $::openstack::config::mysql_user_glance
  $pass                = $::openstack::config::mysql_pass_glance
  $database_connection = "mysql://${user}:${pass}@${controller_address}/glance"

  openstack::resources::firewall { 'Glance API': port      => '9292', }
  openstack::resources::firewall { 'Glance Registry': port => '9191', }
  
  if ($::openstack::config::ssl) {
    file { '/etc/glance/ssl':
      ensure => directory,
      owner  => 'root',
      group  => 'glance',
      mode   => '0750',
    }->
    file { '/etc/glance/ssl/ca.pem':
      source => $::openstack::config::ssl_cacert,
      owner  => 'root',
      group  => 'glance',
      mode   => '0640',
    }->
    file { '/etc/glance/ssl/cert.pem':
      source => $::openstack::config::ssl_cert,
      owner  => 'root',
      group  => 'glance',
      mode   => '0640',
    }->
    file { '/etc/glance/ssl/key.pem':
      source => $::openstack::config::ssl_key,
      owner  => 'root',
      group  => 'glance',
      mode   => '0640',
    }

    $cert_file = '/etc/glance/ssl/cert.pem'
    $key_file = '/etc/glance/ssl/key.pem'
    $scheme = 'https'
  } else {
    $cert_file = undef
    $key_file = undef
    $scheme = 'http'
  }

  class { '::glance::api':
    keystone_password        => $::openstack::config::glance_password,
    auth_uri                 => $::openstack::profile::base::auth_uri,
    identity_uri             => $::openstack::profile::base::auth_url,
    keystone_tenant          => 'services',
    keystone_user            => 'glance',
    database_connection      => $database_connection,
    registry_host            => $::management_address,
    registry_client_protocol => $scheme,
    verbose                  => $::openstack::config::verbose,
    debug                    => $::openstack::config::debug,
    enabled                  => $::openstack::profile::base::is_storage,
    os_region_name           => $::openstack::config::region,
    cert_file                => $cert_file,
    key_file                 => $key_file,
  }

  class { '::glance::backend::rbd':
    rbd_store_user => 'glance',
    rbd_store_pool => 'glance-images',
  }

  class { '::glance::registry':
    keystone_password   => $::openstack::config::glance_password,
    database_connection => $database_connection,
    auth_uri            => $::openstack::profile::base::auth_uri,
    identity_uri        => $::openstack::profile::base::auth_url,
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    verbose             => $::openstack::config::verbose,
    debug               => $::openstack::config::debug,
    cert_file           => $cert_file,
    key_file            => $key_file,
  }

  class { '::glance::notify::rabbitmq':
    rabbit_password   => $::openstack::config::rabbitmq_password,
    rabbit_userid     => $::openstack::config::rabbitmq_user,
    rabbit_hosts      => $::openstack::config::rabbitmq_hosts,
#    rabbit_ha_queues  => $::openstack::config::ha, # FIXME: re-enable on Mitaka
    rabbit_use_ssl    => $::openstack::config::ssl,
    kombu_ssl_version => 'TLSv1_2',
  }
}
