# The profile to install an OpenStack specific Galera MySQL cluster member
class openstack::profile::galera {

  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  $cluster_addresses = $::openstack::config::controllers.map |String $name, Hash $info| {
    $info['management']
  }

  $default_wsrep_provider_options = {
    'gcache.size'      => '300M',
    'gcache.page_size' => '1G',
  }

  if ($::openstack::config::ssl) {
    file { '/etc/mysql/ssl':
      ensure => directory,
      owner  => 'mysql',
      group  => 'mysql',
      mode   => '0700',
    }
    file { '/etc/mysql/ssl/cert.pem':
      source => $::openstack::config::ssl_cert,
      owner  => 'mysql',
      group  => 'mysql',
      mode   => '0644',
    }
    file { '/etc/mysql/ssl/key.pem':
      source => $::openstack::config::ssl_key,
      owner  => 'mysql',
      group  => 'mysql',
      mode   => '0600',
    }
    file { '/etc/mysql/ssl/ca.pem':
      source => $::openstack::config::ssl_cacert,
      owner  => 'mysql',
      group  => 'mysql',
      mode   => '0644',
    }

    Class['mysql::server::install']->
    File['/etc/mysql/ssl']->
    File['/etc/mysql/ssl/cert.pem', '/etc/mysql/ssl/key.pem', '/etc/mysql/ssl/ca.pem']~>
    Class['mysql::server::service']

    $ssl_provider_options = {
      'socket.ssl_key'   => '/etc/mysql/ssl/key.pem',
      'socket.ssl_cert'  => '/etc/mysql/ssl/cert.pem',
      'socket.ssl_ca'    => '/etc/mysql/ssl/ca.pem'
    }

    $ssl_mysqld_options = {
      'ssl'      => 'true',
      'ssl-ca'   => '/etc/mysql/ssl/ca.pem',
      'ssl-cert' => '/etc/mysql/ssl/cert.pem',
      'ssl-key'  => '/etc/mysql/ssl/key.pem'
    }

  } else {
    $ssl_provider_options = {}
    $ssl_mysqld_options = {}
  }

  $_wsrep_provider_options = deep_merge($default_wsrep_provider_options, $ssl_provider_options)
  $wsrep_provider_options = join(join_keys_to_values($_wsrep_provider_options, '='), '; ')

  $default_mysqld_options = {
    'bind_address'                   => $management_address,
    'default-storage-engine'         => 'innodb',
    'binlog_format'                  => 'ROW',
    'innodb_autoinc_lock_mode'       => 2,
    'innodb_flush_log_at_trx_commit' => 0,
    'innodb_buffer_pool_size'        => '122M',
    'max_connections'                => '2048',

    'wsrep_provider'                 => '/usr/lib/libgalera_smm.so',
    'wsrep_provider_options'         => $wsrep_provider_options,
    'wsrep_cluster_name'             => 'openstack',
    'wsrep_cluster_address'          => "gcomm://${join($cluster_addresses, ',')}",
    'wsrep_sst_method'               => 'rsync',
  }

  $mysqld_options = deep_merge($default_mysqld_options, $ssl_mysqld_options)

  class { '::galera::server':
    root_password    => $::openstack::config::mysql_root_password,
    restart          => true,
    package_manage   => true,
    override_options => {
      'mysqld' => $mysqld_options
    }
  }

  class { '::mysql::client':
    package_name => 'mariadb-client-10.0',
  }

  class { '::mysql::bindings':
    python_enable => true,
  }

  $cluster_addresses.each |String $addr| {
    mysql_user { "haproxy@${addr}":
      ensure => present
    }
  }

  Service['mysqld'] -> Anchor['database-service']

  class { 'mysql::server::account_security': }
}
