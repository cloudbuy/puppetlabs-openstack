# The profile to install rabbitmq and set the firewall
class openstack::profile::rabbitmq {
  $management_address = $::openstack::config::controller_address_management

  if $::osfamily == 'RedHat' {
    package { 'erlang':
      ensure => installed,
      before => Package['rabbitmq-server'],
    }
    # Erlang solutions doesn't have a yum repo for Fedora >= 17, but Fedora has an up-to-date erlang
    if $::operatingsystem != 'Fedora' {
      Yumrepo['erlang-solutions'] -> Package['erlang']
    }
  }

  rabbitmq_user { $::openstack::config::rabbitmq_user:
    admin    => true,
    password => $::openstack::config::rabbitmq_password,
    provider => 'rabbitmqctl',
    require  => Class['::rabbitmq'],
  }
  rabbitmq_user_permissions { "${openstack::config::rabbitmq_user}@/":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }->Anchor<| title == 'nova-start' |>

  if $::openstack::config::ssl {
    class { '::rabbitmq':
      service_ensure              => 'running',
      config_management_variables => {},
      delete_guest_user           => true,
      port                        => 5672,
      ssl                         => true,
      ssl_versions                => ['tlsv1.2', 'tlsv1.1', 'tlsv1'],
      ssl_cacert                  => '/etc/rabbitmq/ssl/certificate.pem',
      ssl_cert                    => '/etc/rabbitmq/ssl/certificate.pem',
      ssl_key                     => '/etc/rabbitmq/ssl/key.pem',
      ssl_fail_if_no_peer_cert    => false,
      ssl_verify                  => 'verify_peer',
      tcp_backlog                 => 1024,
    }

    file { '/etc/rabbitmq/ssl/certificate.pem':
      source => $::openstack::config::ssl_cert,
      owner  => 'rabbitmq',
      group  => 'rabbitmq',
      mode   => '0644',
    }
    file { '/etc/rabbitmq/ssl/key.pem':
      source => $::openstack::config::ssl_key,
      owner  => 'rabbitmq',
      group  => 'rabbitmq',
      mode   => '0600',
    }

    Package['rabbitmq-server'] ->
    File['/etc/rabbitmq/ssl/certificate.pem', '/etc/rabbitmq/ssl/key.pem'] ~> Service['rabbitmq-server']
  } else {
    class { '::rabbitmq':
      service_ensure              => 'running',
      port                        => 5672,
      delete_guest_user           => true,
      config_management_variables => {},
      tcp_backlog                 => 1024,
    }
  }
}
