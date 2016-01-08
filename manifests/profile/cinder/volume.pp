# The profile to install the volume service
class openstack::profile::cinder::volume {
  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)

  include ::openstack::common::cinder

  class { '::cinder::volume':
    package_ensure => present,
    enabled        => true,
  }

  cinder::backend::rbd {'rbd-ssd':
    rbd_pool                         => 'cinder-volumes-ssd',
    rbd_user                         => 'cinder',
    rbd_secret_uuid                  => '3619fcb5-e5eb-4435-93ff-d2e4ccfdd95a',
    rbd_ceph_conf                    => '/etc/ceph/ceph.conf',
    rbd_flatten_volume_from_snapshot => false,
    rbd_max_clone_depth              => '5',
  }

  cinder::backend::rbd {'rbd-scsi':
    rbd_pool                         => 'cinder-volumes-scsi',
    rbd_user                         => 'cinder',
    rbd_secret_uuid                  => '3619fcb5-e5eb-4435-93ff-d2e4ccfdd95a',
    rbd_ceph_conf                    => '/etc/ceph/ceph.conf',
    rbd_flatten_volume_from_snapshot => false,
    rbd_max_clone_depth              => '5',
  }

  cinder::backend::rbd {'rbd-sata':
    rbd_pool                         => 'cinder-volumes-sata',
    rbd_user                         => 'cinder',
    rbd_secret_uuid                  => '3619fcb5-e5eb-4435-93ff-d2e4ccfdd95a',
    rbd_ceph_conf                    => '/etc/ceph/ceph.conf',
    rbd_flatten_volume_from_snapshot => false,
    rbd_max_clone_depth              => '5',
  }

  class { '::cinder::backends':
    enabled_backends => ['rbd-ssd', 'rbd-scsi', 'rbd-sata']
  }
}
