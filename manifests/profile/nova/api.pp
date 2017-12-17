#: The profile to set up the Nova controller (several services)
class openstack::profile::nova::api {

  $controller_management_address = $::openstack::config::controller_address_management

  openstack::resources::database { 'nova': }
  class { "::nova::db::mysql_api":
    user          => $::openstack::config::mysql_user_nova_api,
    password      => $::openstack::config::mysql_pass_nova_api,
    dbname        => 'nova_api',
    allowed_hosts => $::openstack::config::mysql_allowed_hosts,
    require       => Anchor['database-service'],
  }
  openstack::resources::firewall { 'Nova API': port => '8774', }
  openstack::resources::firewall { 'Nova Metadata': port => '8775', }
  openstack::resources::firewall { 'Nova EC2': port => '8773', }
  openstack::resources::firewall { 'Nova S3': port => '3333', }
  openstack::resources::firewall { 'Nova novnc': port => '6080', }

  $scheme = $::openstack::config::ssl ? {
    true    => 'https',
    default => 'http'
  }

  $public_url = "${scheme}://${::openstack::config::controller_address_api}:8774"
  $admin_url = "${scheme}://${::openstack::config::controller_address_management}:8774"
  $internal_url = "${scheme}://${::openstack::config::controller_address_management}:8774"

  class { '::nova::keystone::auth':
    password        => $::openstack::config::nova_password,
    public_url      => "${public_url}/v2/%(tenant_id)s",
    admin_url       => "${admin_url}/v2/%(tenant_id)s",
    internal_url    => "${internal_url}/v2/%(tenant_id)s",
    public_url_v3   => "${public_url}/v3",
    admin_url_v3    => "${admin_url}/v3",
    internal_url_v3 => "${internal_url}/v3",
    region          => $::openstack::config::region,
  }

  include ::openstack::common::nova

  class { '::nova::api':
    admin_password                       => $::openstack::config::nova_password,
    auth_uri                             => "${scheme}://${::openstack::config::controller_address_api}:5000/",
    identity_uri                         => "${scheme}://${::openstack::config::controller_address_management}:35357/",
    neutron_metadata_proxy_shared_secret => $::openstack::config::neutron_shared_secret,
    enabled                              => false,
    api_bind_address                     => $::openstack::common::nova::nova_api_host,
    metadata_listen                      => $::openstack::common::nova::nova_api_host,
    allow_resize_to_same_host            => true,
  }

  if ($::openstack::config::ssl) {
    File['/etc/nova/ssl/key.pem']->
    Class['::nova::wsgi::apache']
    $ssl_cert_file = '/etc/nova/ssl/cert.pem'
    $ssl_key_file = '/etc/nova/ssl/key.pem'
  } else {
    $ssl_cert_file = undef
    $ssl_key_file = undef
  }

  # This class in Mitaka only configures the API service, not the metadata service
  class { '::nova::wsgi::apache':
    servername => $::openstack::config::controller_address_api,
    bind_host  => $::openstack::profile::base::api_address,
    ssl        => $::openstack::config::ssl,
    ssl_cert   => $ssl_cert_file,
    ssl_key    => $ssl_key_file,
  }
  File<| title == '/usr/lib/cgi-bin/nova' |> {
    mode => '0755',
  }

  # As a result we have to manually define the nova-metadata issue
  ::openstacklib::wsgi::apache { 'nova-metadata':
    bind_host           => $::openstack::profile::base::api_address,
    bind_port           => 8775,
    group               => 'nova',
    path                => '/',
    priority            => '10',
    servername          => $::openstack::config::controller_address_api,
    ssl                 => $::openstack::config::ssl,
    ssl_cert            => $ssl_cert_file,
    ssl_key             => $ssl_key_file,
    threads             => $::processorcount,
    user                => 'nova',
    workers             => 1,
    wsgi_daemon_process => 'nova-metadata',
    wsgi_process_group  => 'nova-metadata',
    wsgi_script_dir     => '/usr/lib/cgi-bin/nova',
    wsgi_script_file    => 'nova-metadata',
    wsgi_script_source  => '/usr/lib/python2.7/dist-packages/nova/wsgi/nova-metadata.py'
  }

  class { '::nova::compute::neutron': }

  class { '::nova::vncproxy':
    host              => $::openstack::common::nova::nova_api_host,
    vncproxy_protocol => $scheme,
    enabled           => true,
  }

  class { [
    'nova::scheduler',
    'nova::cert',
    'nova::consoleauth',
    'nova::conductor'
  ]:
    enabled => true
  }
}
