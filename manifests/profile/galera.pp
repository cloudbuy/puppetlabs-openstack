# The profile to install an OpenStack specific Galera MySQL cluster member
class openstack::profile::galera {

  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  $cluster_addresses = hiera_hash('openstack::controllers').map |Hash $ctrl| {
    $ctrl['management']
  }

  class { '::galera::server':
    root_password    => $::openstack::config::mysql_root_password,
    restart          => true,
    package_manage   => true,
    override_options => {
      'mysqld' => {
        'bind_address'                   => $management_address,
        'default-storage-engine'         => 'innodb',
        'binlog_format'                  => 'ROW',
        'innodb_autoinc_lock_mode'       => 2,
        'innodb_flush_log_at_trx_commit' => 0,
        'innodb_buffer_pool_size'        => '122M',

        'wsrep_provider'                 => '/usr/lib/libgalera_smm.so',
        'wsrep_provider_options'         => 'gcache.size=300M; gcache.page_size=1G',
        'wsrep_cluster_name'             => '',
        'wsrep_cluster_address'          => "gcomm://${join($cluster_addresses, ',')}",
        'wsrep_sst_method'               => 'rsync',
      }
    }
  }

  class { '::mysql::bindings':
    python_enable => true,
  }

  Service['mysqld'] -> Anchor['database-service']

  class { 'mysql::server::account_security': }
}
