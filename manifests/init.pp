# = Puppet Labs OpenStack Parameters
# == Class: openstack
#
# === Authors
#
# Christian Hoge <chris.hoge@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013-2014 Puppet Labs.
#
# Class for configuring the global installation parameters for the puppetlabs-openstack module.
# By default, the module will try to find the parameters in hiera. If the hiera lookup fails,
# it will fall back to the parameters passed to this class. The use of this class is optional,
# and will be automatically included through the configuration. If the ::openstack
# class is used, it needs appear first in node parse order to ensure proper variable
# initialization.
#
# [*ssl*]
#   Enable SSL on RabbitMQ, MySQL, HAProxy and all the OpenStack components
#
# [*ssl_cacert*]
#   Puppet file path to the CA certificate to use within the SSL setup
#
# [*ssl_cert*]
#   Puppet file path to the certificate to use for the services
#
# [*ssl_key*]
#   Puppet file path to the private key to use for the services
#
# [*ha*]
#   Use the new Highly Available set up and configuration params
#
# [*region*]
#   The region name to set up the OpenStack services.
#
# == Networks
# [*network_api*]
#   The CIDR of the api network. This is the network that all public
#   api calls are made on, as well as the network to access Horizon.
#
# [*network_external*]
#   The CIDR of the external network. May be the same as network_api.
#   This is the network that floating IP addresses are allocated in
#   to allow external access to virtual machine instances.
#
# [*network_management*]
#   The CIDR of the management network.
#
# [*network_data*]
#   The CIDR of the data network. May be the same as network_management.
#
# [*network_external_ippool_start*]
#   The starting address of the external network IP pool. Must be contained
#   within the network_external CIDR range.
#
# [*network_external_ippool_end*]
#   The end address of the external network IP pool. Must be contained within
#   the network_external CIDR range, and greater than network_external_ippool_start.
#
# [*network_external_gateway*]
#   The gateway address for the external network.
#
# [*network_external_dns*]
#   The DNS server for the external network.
#
# == Private Neutron Network
# [*network_neutron_private*]
#   The CIDR of the automatically created private network.
#
# == Fixed IPs (controllers)
# [*controller_address_api*]
#   The API IP address of the controller node. Must be in the network_api CIDR.
#
# [*controller_address_management*]
#   The management IP address of the controller node. Must be in the network_management CIDR.
#
# [*storage_address_api*]
#   The API IP address of the storage node. Must be in the network_api CIDR.
#
# [*storage_address_management*]
#   The management IP address of the storage node. Must be in the network_management CIDR.
#
# == Database
# [*mysql_root_password*]
#   The root password for the MySQL database.
#
# [*mysql_service_password*]
#   The MySQL shared password for all of the OpenStack services.
#
# [*mysql_allowed_hosts*]
#   Array of hosts that are allowed to access the MySQL database. Should include all of the network_management CIDR.
#   Example configuration: ['localhost', '127.0.0.1', '172.16.33.%']
#
# [*mysql_user_keystone*]
#   The database username for keystone service.
#
# [*mysql_pass_keystone*]
#   The database password for keystone service.
#
# [*mysql_user_ceilometer*]
#   The database username for ceilometer service.
#
# [*mysql_pass_ceilometer*]
#   The database password for ceilometer service.
#
# [*mysql_user_cinder*]
#   The database username for cinder service.
#
# [*mysql_pass_cinder*]
#   The database password for cinder service.
#
# [*mysql_user_glance*]
#   The database username for glance service.
#
# [*mysql_pass_glance*]
#   The database password for glance service.
#
# [*mysql_user_nova*]
#   The database username for nova service.
#
# [*mysql_pass_nova*]
#   The database password for nova service.
#
# [*mysql_user_nova_api*]
#   The database username for nova api service.
#
# [*mysql_pass_nova_api*]
#   The database password for nova api service.
#
# [*mysql_user_neutron*]
#   The database username for neutron service.
#
# [*mysql_pass_neutron*]
#   The database password for neutron service.
#
# [*mysql_user_heat*]
#   The database username for heat service.
#
# [*mysql_pass_heat*]
#   The database password for heat service.
#
# == RabbitMQ
# [*rabbitmq_hosts*]
#   The host list for the RabbitMQ service.
#
# [*rabbitmq_user*]
#   The username for the RabbitMQ queues.
#
# [*rabbitmq_password*]
#   The password for accessing the RabbitMQ queues.
#
# == Keystone
# [*keystone_admin_token*]
#   The global administrative token for the Keystone service.
#
# [*keystone_admin_email*]
#   The e-mail address of the Keystone administrator.
#
# [*keystone_admin_password*]
#   The password for keystone user in Keystone.
#
# [*keystone_tenants*]
#   The intial keystone tenants to create. Should be a Hash in the form of: 
#   {'tenant_name1' => { 'descritpion' => 'Tenant Description 1'}, 
#    'tenant_name2' => {'description' => 'Tenant Description 2'}}
#
# [*keystone_users*]
#   The intial keystone users to create. Should be a Hash in the form of:
#   {'user1' => {'password' => 'somepass1', 'tenant' => 'some_preexisting_tenant',
#                'email' => 'foo@example.com', 'admin'  =>  'true'},
#   'user2' => {'password' => 'somepass2', 'tenant' => 'some_preexisting_tenant',
#                'email' => 'foo2@example.com', 'admin'  =>  'false'}} 
#
# [*keystone_use_httpd*]
#   Whether to set up an Apache web service with mod_wsgi or to use the default
#   Eventlet service. If false, the default from $keystone::params::service_name
#   will be used, which will be the default Eventlet service. Set to true to
#   configure an Apache web service using mod_wsgi, which is currently the only
#   web service configuration available through the keystone module.
#   Defaults to false.
#
# == Glance
# [*glance_password*]
#   The password for the glance user in Keystone.
#
# [*glance_api_servers*]
#   Array of api servers, with port setting
#   Example configuration: ['172.16.33.4:9292'] 
#
# ==Cinder
# [*cinder_password*]
#   The password for the cinder user in Keystone.
#
# [*cinder_volume_size*]
#   The size of the Cinder loopback storage device. Example: '8G'.
#
# == Swift
# [*swift_password*]
#    The password for the swift user in Keystone.
#
# [*swift_hash_suffix*]
#   The hash suffix for Swift ring communication.
#
# == Nova
# [*nova_libvirt_type*]
#   The type of hypervisor to use for Nova. Typically 'kvm' for
#   hardware accelerated virtualization or 'qemu' for software virtualization.
#
# [*nova_password*]
#   The password for the nova user in Keystone.
#
# == Neutron
# [*neutron_password*]
#   The password for the neutron user in Keystone.
#
# [*neutron_shared_secret*]
#   The shared secret to allow for communication between Neutron and Nova.
#
# [*neutron_core_plugin*]
#   The core_plugin for the neutron service
#
# [*neutron_service_plugins*]
#   The service_plugins for neutron service
#
# [*neutron_tunneling*] (Deprecated)
#   Boolean. Whether to enable Neutron tunneling.
#   Default to true.
#
# [*neutron_tunnel_types*] (Deprecated)
#   Array. Tunnel types to use
#   Defaults to ['gre'],
#
# [*neutron_tenant_network_type*] (Deprecated)
#   Array. Tenant network type.
#   Defaults to ['gre'],
#
# [*neutron_type_drivers*] (Deprecated)
#   Array. Neutron type drivers to use.
#   Defaults to ['gre'],
#
# [*neutron_mechanism_drivers*] (Deprecated)
#   Defaults to ['openvswitch'].
#
# [*neutron_tunnel_id_ranges*] (Deprecated)
#   Neutron tunnel id ranges.
#   Defaults to ['1:1000']
#
# == Ceilometer
# [*ceilometer_address_management*]
#   The management IP address of the ceilometer node. Must be in the network_management CIDR.
#
# [*ceilometer_password*]
#   The password for the ceilometer user in Keystone.
#
# [*ceilometer_meteringsecret*]
#   The shared secret to allow communication betweek Ceilometer and other
#   OpenStack services.
#
# == Heat
# [*heat_password*]
#   The password for the heat user in Keystone.
#
# [*heat_encryption_key*]
#   The encyption key for the shared heat services.
#
# == Horizon
# [*horizon_secret_key*]
#   The secret key for the Horizon service.
#
# [*allowed_hosts*]
#   List of hosts which will be set as value of ALLOWED_HOSTS
#   parameter in settings_local.py. This is used by Django for
#   security reasons. Can be set to * in environments where security is
#   deemed unimportant.
#
# [*server_aliases*]
#   List of names which should be defined as ServerAlias directives
#   in vhost.conf.
#
# [*servername*]
#   The hostname to use for the Horizon service
#
# [*purge_config*]
#   Whether to remove un-managed options from configuration files
#
# == Log levels
# [*verbose*]
#   Boolean. Determines if verbose is enabled for all OpenStack services.
#
# [*debug*]
#   Boolean. Determines if debug is enabled for all OpenStack services.
#
# == Tempest
# [*tempest_configure_images*]
#   Boolean. Whether Tempest should configure images.
#
# [*tempest_image_name*]
#   The name of the primary image to use for tests.
#
# [*tempest_image_name_alt*]
#   The name of the secondary image to use for tests. If the same as the
#   tempest_image_primary, some tests will be disabled.
#
# [*tempest_username*]
#   The login username to run tempest tests.
#
# [*tempest_username_alt*]
#   The alternate login username for tempest tests.
#
# [*tempest_username_admin*]
#   The uername for the Tempest admin user.
#
# [*tempest_configure_network*]
#   Boolean. If Tempest should configure test networks.
#
# [*tempest_public_network_name*]
#   The name of the public neutron network for Tempest to connect to.
#
# [*tempest_cinder_available*]
#   Boolean. If Cinder services are available.
#
# [*tempest_glance_available*]
#   Boolean. If Glance services are available.
#
# [*tempest_horizon_available*]
#   Boolean. If Horizon is available.
#
# [*tempest_nova_available*]
#   Boolean. If Nova services are available.
#
# [*tempest_neutron_available*]
#   Boolean. If Neutron services are availale.
#
# [*tempest_heat_available*]
#   Boolean. If Heat services are available.
#
# [*tempest_swift_available*]
#   Boolean. If Swift services are available.
#
class openstack (
  $use_hiera = true,
  $ssl = undef,
  $ssl_cacert = undef,
  $ssl_cert = undef,
  $ssl_key = undef,
  $ha = undef,
  $region = undef,
  $network_api = undef,
  $network_external = undef,
  $network_external_bridge = 'br-ex',
  $network_external_device = undef,
  $network_management = undef,
  $network_data = undef,
  $network_external_ippool_start = undef,
  $network_external_ippool_end = undef,
  $network_external_gateway = undef,
  $network_external_dns = undef,
  $network_neutron_private = undef,
  $controllers = undef,
  $storage = undef,
  $controller_address_api = undef,
  $controller_address_management = undef,
  $controller_keepalived_address = undef,
  $controller_keepalived_pass = undef,
  $controller_keepalived_router_id = undef,
  $storage_address_api = undef,
  $storage_address_management = undef,
  $mysql_root_password = undef,
  $mysql_service_password = undef,
  $mysql_allowed_hosts = undef,
  $mysql_user_keystone = undef,
  $mysql_pass_keystone = undef,
  $mysql_user_ceilometer = undef,
  $mysql_pass_ceilometer = undef,
  $mysql_user_cinder = undef,
  $mysql_pass_cinder = undef,
  $mysql_user_glance = undef,
  $mysql_pass_glance = undef,
  $mysql_user_nova = undef,
  $mysql_pass_nova = undef,
  $mysql_user_nova_api = undef,
  $mysql_pass_nova_api = undef,
  $mysql_user_nova_placement = undef,
  $mysql_pass_nova_placement = undef,
  $mysql_user_neutron = undef,
  $mysql_pass_neutron = undef,
  $mysql_user_heat = undef,
  $mysql_pass_heat = undef,
  $rabbitmq_hosts = undef,
  $rabbitmq_user = undef,
  $rabbitmq_password = undef,
  $keystone_admin_token = undef,
  $keystone_admin_email = undef,
  $keystone_admin_password = undef,
  $keystone_tenants = undef,
  $keystone_users = undef,
  $keystone_use_httpd = false,
  $glance_password = undef,
  $glance_api_servers = undef,
  $cinder_password = undef,
  $cinder_volume_size = undef,
  $swift_password = undef,
  $swift_hash_suffix = undef,
  $nova_libvirt_type = undef,
  $nova_password = undef,
  $placement_password = undef,
  $neutron_password = undef,
  $neutron_shared_secret = undef,
  $neutron_core_plugin = undef,
  $neutron_service_plugins = undef,
  $neutron_tunneling = true,
  $neutron_tunnel_types = ['gre'],
  $neutron_tenant_network_type = ['gre'],
  $neutron_type_drivers = ['gre'],
  $neutron_mechanism_drivers = ['openvswitch'],
  $neutron_tunnel_id_ranges = ['1:1000'],
  $neutron_instance_mtu = undef,
  $ceilometer_address_management = undef,
  $ceilometer_password = undef,
  $ceilometer_meteringsecret = undef,
  $heat_password = undef,
  $heat_encryption_key = undef,
  $horizon_secret_key = undef,
  $horizon_allowed_hosts = undef,
  $horizon_server_aliases = undef,
  $horizon_servername = undef,
  $tempest_configure_images    = undef,
  $tempest_image_name          = undef,
  $tempest_image_name_alt      = undef,
  $tempest_username            = undef,
  $tempest_username_alt        = undef,
  $tempest_username_admin      = undef,
  $tempest_configure_network   = undef,
  $tempest_public_network_name = undef,
  $tempest_cinder_available    = undef,
  $tempest_glance_available    = undef,
  $tempest_horizon_available   = undef,
  $tempest_nova_available      = undef,
  $tempest_neutron_available   = undef,
  $tempest_heat_available      = undef,
  $tempest_swift_available     = undef,
  $purge_config = false,
  $verbose = undef,
  $debug = undef,
) {
  if $use_hiera {
    class { '::openstack::config':
      ssl                             => lookup(openstack::ssl, Boolean, 'first', false),
      ssl_cacert                      => lookup(openstack::ssl::cacert, Optional[String], 'first', undef),
      ssl_cert                        => lookup(openstack::ssl::cert, Optional[String], 'first', undef),
      ssl_key                         => lookup(openstack::ssl::key, Optional[String], 'first', undef),
      ha                              => lookup(openstack::ha, Boolean, 'first', false),
      region                          => lookup(openstack::region),
      network_api                     => lookup(openstack::network::api),
      network_external                => lookup(openstack::network::external),
      network_external_bridge         => lookup(openstack::network::external::bridge, Optional[String], 'first', $network_external_bridge),
      network_external_device         => lookup(openstack::network::external::device, Optional[String], 'first', undef),
      network_management              => lookup(openstack::network::management),
      network_data                    => lookup(openstack::network::data),
      network_external_ippool_start   => lookup(openstack::network::external::ippool::start),
      network_external_ippool_end     => lookup(openstack::network::external::ippool::end),
      network_external_gateway        => lookup(openstack::network::external::gateway),
      network_external_dns            => lookup(openstack::network::external::dns),
      network_neutron_private         => lookup(openstack::network::neutron::private, Optional[String], 'first', undef),
      controllers                     => lookup(openstack::controllers, Optional[Hash], 'first', undef),
      storage                         => lookup(openstack::storage, Optional[Hash], 'first', undef),
      controller_address_api          => lookup(openstack::controller::address::api, Optional[String], 'first', undef),
      controller_address_management   => lookup(openstack::controller::address::management, Optional[String], 'first', undef),
      controller_keepalived_address   => lookup(openstack::controller::keepalived_address, Optional[String], 'first', undef),
      controller_keepalived_pass      => lookup(openstack::controller::keepalived_pass, Optional[String], 'first', undef),
      controller_keepalived_router_id => lookup(openstack::controller::keepalived_router_id, Optional[Integer], 'first', undef),
      storage_address_api             => lookup(openstack::storage::address::api, Optional[String], 'first', undef),
      storage_address_management      => lookup(openstack::storage::address::management, Optional[String], 'first', undef),
      mysql_root_password             => lookup(openstack::mysql::root_password),
      mysql_service_password          => lookup(openstack::mysql::service_password),
      mysql_allowed_hosts             => lookup(openstack::mysql::allowed_hosts),
      mysql_user_keystone             => pick(lookup(openstack::mysql::keystone::user, Optional[String], 'first', undef), 'keystone'),
      mysql_pass_keystone             => pick(lookup(openstack::mysql::keystone::pass, Optional[String], 'first', undef), lookup(openstack::mysql::service_password)),
      mysql_user_ceilometer           => pick(lookup(openstack::mysql::ceilometer::user, Optional[String], 'first', undef), 'cinder'),
      mysql_pass_ceilometer           => pick(lookup(openstack::mysql::ceilometer::pass, Optional[String], 'first', undef), lookup(openstack::mysql::service_password)),
      mysql_user_cinder               => pick(lookup(openstack::mysql::cinder::user, Optional[String], 'first', undef), 'cinder'),
      mysql_pass_cinder               => pick(lookup(openstack::mysql::cinder::pass, Optional[String], 'first', undef), lookup(openstack::mysql::service_password)),
      mysql_user_glance               => pick(lookup(openstack::mysql::glance::user, Optional[String], 'first', undef), 'glance'),
      mysql_pass_glance               => pick(lookup(openstack::mysql::glance::pass, Optional[String], 'first', undef), lookup(openstack::mysql::service_password)),
      mysql_user_nova                 => pick(lookup(openstack::mysql::nova::user, Optional[String], 'first', undef), 'nova'),
      mysql_pass_nova                 => pick(lookup(openstack::mysql::nova::pass, Optional[String], 'first', undef), lookup(openstack::mysql::service_password)),
      mysql_user_nova_api             => pick(lookup(openstack::mysql::nova_api::user, Optional[String], 'first', undef), 'nova_api'),
      mysql_pass_nova_api             => pick(lookup(openstack::mysql::nova_api::pass, Optional[String], 'first', undef), lookup(openstack::mysql::service_password)),
      mysql_user_nova_placement       => pick(lookup(openstack::mysql::nova_placement::user, Optional[String], 'first', undef), 'nova_placement'),
      mysql_pass_nova_placement       => pick(lookup(openstack::mysql::nova_placement::pass, Optional[String], 'first', undef), lookup(openstack::mysql::service_password)),
      mysql_user_neutron              => pick(lookup(openstack::mysql::neutron::user, Optional[String], 'first', undef), 'neutron'),
      mysql_pass_neutron              => pick(lookup(openstack::mysql::neutron::pass, Optional[String], 'first', undef), lookup(openstack::mysql::service_password)),
      mysql_user_heat                 => pick(lookup(openstack::mysql::heat::user, Optional[String], 'first', undef), 'heat'),
      mysql_pass_heat                 => pick(lookup(openstack::mysql::heat::pass, Optional[String], 'first', undef), lookup(openstack::mysql::service_password)),
      rabbitmq_hosts                  => lookup(openstack::rabbitmq::hosts),
      rabbitmq_user                   => lookup(openstack::rabbitmq::user),
      rabbitmq_password               => lookup(openstack::rabbitmq::password),
      keystone_admin_token            => lookup(openstack::keystone::admin_token),
      keystone_admin_email            => lookup(openstack::keystone::admin_email),
      keystone_admin_password         => lookup(openstack::keystone::admin_password),
      keystone_tenants                => lookup(openstack::keystone::tenants),
      keystone_users                  => lookup(openstack::keystone::users),
      keystone_use_httpd              => lookup(openstack::keystone::use_httpd, Boolean, 'first', false),
      glance_password                 => lookup(openstack::glance::password),
      glance_api_servers              => lookup(openstack::glance::api_servers),
      cinder_password                 => lookup(openstack::cinder::password),
      cinder_volume_size              => lookup(openstack::cinder::volume_size),
      swift_password                  => lookup(openstack::swift::password),
      swift_hash_suffix               => lookup(openstack::swift::hash_suffix),
      nova_libvirt_type               => lookup(openstack::nova::libvirt_type),
      nova_password                   => lookup(openstack::nova::password),
      placement_password              => lookup(openstack::placement::password),
      neutron_password                => lookup(openstack::neutron::password),
      neutron_shared_secret           => lookup(openstack::neutron::shared_secret),
      neutron_core_plugin             => lookup(openstack::neutron::core_plugin),
      neutron_service_plugins         => lookup(openstack::neutron::service_plugins),
      neutron_tunneling               => lookup(openstack::neutron::neutron_tunneling, Boolean, 'first', $neutron_tunneling),
      neutron_tunnel_types            => lookup(openstack::neutron::neutron_tunnel_type, Array, 'first', $neutron_tunnel_types),
      neutron_tenant_network_type     => lookup(openstack::neutron::neutron_tenant_network_type, Array, 'first', $neutron_tenant_network_type),
      neutron_type_drivers            => lookup(openstack::neutron::neutron_type_drivers, Array, 'first', $neutron_type_drivers),
      neutron_mechanism_drivers       => lookup(openstack::neutron::neutron_mechanism_drivers, Array, 'first', $neutron_mechanism_drivers),
      neutron_tunnel_id_ranges        => lookup(openstack::neutron::neutron_tunnel_id_ranges, Array, 'first', $neutron_tunnel_id_ranges),
      neutron_instance_mtu            => lookup(openstack::neutron::neutron_instance_mtu, Optional[Integer], 'first', $neutron_instance_mtu),
      ceilometer_address_management   => lookup(openstack::ceilometer::address::management),
      ceilometer_password             => lookup(openstack::ceilometer::password),
      ceilometer_meteringsecret       => lookup(openstack::ceilometer::meteringsecret),
      heat_password                   => lookup(openstack::heat::password),
      heat_encryption_key             => lookup(openstack::heat::encryption_key),
      horizon_secret_key              => lookup(openstack::horizon::secret_key),
      horizon_allowed_hosts           => lookup(openstack::horizon::allowed_hosts, Array, 'first', []),
      horizon_server_aliases          => lookup(openstack::horizon::server_aliases, Array, 'first', []),
      horizon_servername              => lookup(openstack::horizon::servername, Optional[String], 'first', undef),
      purge_config                    => lookup(openstack::purge_config, Boolean, 'first', $purge_config),
      verbose                         => lookup(openstack::verbose),
      debug                           => lookup(openstack::debug),
      tempest_configure_images        => lookup(openstack::tempest::configure_images),
      tempest_image_name              => lookup(openstack::tempest::image_name),
      tempest_image_name_alt          => lookup(openstack::tempest::image_name_alt),
      tempest_username                => lookup(openstack::tempest::username),
      tempest_username_alt            => lookup(openstack::tempest::username_alt),
      tempest_username_admin          => lookup(openstack::tempest::username_admin),
      tempest_configure_network       => lookup(openstack::tempest::configure_network),
      tempest_public_network_name     => lookup(openstack::tempest::public_network_name),
      tempest_cinder_available        => lookup(openstack::tempest::cinder_available),
      tempest_glance_available        => lookup(openstack::tempest::glance_available),
      tempest_horizon_available       => lookup(openstack::tempest::horizon_available),
      tempest_nova_available          => lookup(openstack::tempest::nova_available),
      tempest_neutron_available       => lookup(openstack::tempest::neutron_available),
      tempest_heat_available          => lookup(openstack::tempest::heat_available),
      tempest_swift_available         => lookup(openstack::tempest::swift_available),
    }
  } else {
    class { '::openstack::config':
      ssl                             => $ssl,
      ssl_cacert                      => $ssl_cacert,
      ssl_cert                        => $ssl_cert,
      ssl_key                         => $ssl_key,
      ha                              => $ha,
      region                          => $region,
      network_api                     => $network_api,
      network_external                => $network_external,
      network_external_bridge         => $network_external_bridge,
      network_external_device         => $network_external_device,
      network_management              => $network_management,
      network_data                    => $network_data,
      network_external_ippool_start   => $network_external_ippool_start,
      network_external_ippool_end     => $network_external_ippool_end,
      network_external_gateway        => $network_external_gateway,
      network_external_dns            => $network_external_dns,
      network_neutron_private         => $network_neutron_private,
      controllers                     => $controllers,
      storage                         => $storage,
      controller_address_api          => $controller_address_api,
      controller_address_management   => $controller_address_management,
      controller_keepalived_address   => $controller_keepalived_address,
      controller_keepalived_pass      => $controller_keepalived_pass,
      controller_keepalived_router_id => $controller_keepalived_router_id,
      storage_address_api             => $storage_address_api,
      storage_address_management      => $storage_address_management,
      mysql_root_password             => $mysql_root_password,
      mysql_service_password          => $mysql_service_password,
      mysql_allowed_hosts             => $mysql_allowed_hosts,
      mysql_user_keystone             => pick($mysql_user_keystone, 'keystone'),
      mysql_pass_keystone             => pick($mysql_pass_keystone, $mysql_service_password),
      mysql_user_cinder               => pick($mysql_user_cinder, 'cinder'),
      mysql_pass_cinder               => pick($mysql_pass_cinder, $mysql_service_password),
      mysql_user_glance               => pick($mysql_user_glance, 'glance'),
      mysql_pass_glance               => pick($mysql_pass_glance, $mysql_service_password),
      mysql_user_nova                 => pick($mysql_user_nova, 'nova'),
      mysql_pass_nova                 => pick($mysql_pass_nova, $mysql_service_password),
      mysql_user_nova_api             => pick($mysql_user_nova_api, 'nova_api'),
      mysql_pass_nova_api             => pick($mysql_pass_nova_api, $mysql_service_password),
      mysql_user_nova_placement       => pick($mysql_user_nova_placement, 'nova_placement'),
      mysql_pass_nova_placement       => pick($mysql_pass_nova_placement, $mysql_service_password),
      mysql_user_neutron              => pick($mysql_user_neutron, 'neutron'),
      mysql_pass_neutron              => pick($mysql_pass_neutron, $mysql_service_password),
      mysql_user_heat                 => pick($mysql_user_heat, 'heat'),
      mysql_pass_heat                 => pick($mysql_pass_heat, $mysql_service_password),
      rabbitmq_hosts                  => $rabbitmq_hosts,
      rabbitmq_user                   => $rabbitmq_user,
      rabbitmq_password               => $rabbitmq_password,
      keystone_admin_token            => $keystone_admin_token,
      keystone_admin_email            => $keystone_admin_email,
      keystone_admin_password         => $keystone_admin_password,
      keystone_tenants                => $keystone_tenants,
      keystone_users                  => $keystone_users,
      keystone_use_httpd              => $keystone_use_httpd,
      glance_password                 => $glance_password,
      glance_api_servers              => $glance_api_servers,
      cinder_password                 => $cinder_password,
      cinder_volume_size              => $cinder_volume_size,
      swift_password                  => $swift_password,
      swift_hash_suffix               => $swift_hash_suffix,
      nova_libvirt_type               => $nova_libvirt_type,
      nova_password                   => $nova_password,
      placement_password              => $placement_password,
      neutron_password                => $neutron_password,
      neutron_shared_secret           => $neutron_shared_secret,
      neutron_core_plugin             => $neutron_core_plugin,
      neutron_service_plugins         => $neutron_service_plugins,
      neutron_tunneling               => $neutron_tunneling,
      neutron_tunnel_types            => $neutron_tunnel_types,
      neutron_tenant_network_type     => $neutron_tenant_network_type,
      neutron_type_drivers            => $neutron_type_drivers,
      neutron_mechanism_drivers       => $neutron_mechanism_drivers,
      neutron_tunnel_id_ranges        => $neutron_tunnel_id_ranges,
      neutron_instance_mtu            => $neutron_instance_mtu,
      ceilometer_address_management   => $ceilometer_address_management,
      ceilometer_password             => $ceilometer_password,
      ceilometer_meteringsecret       => $ceilometer_meteringsecret,
      heat_password                   => $heat_password,
      heat_encryption_key             => $heat_encryption_key,
      horizon_secret_key              => $horizon_secret_key,
      horizon_allowed_hosts           => [],
      horizon_server_aliases          => [],
      horizon_servername              => $horizon_servername,
      purge_config                    => $purge_config,
      verbose                         => $verbose,
      debug                           => $debug,
      tempest_configure_images        => $tempest_configure_images,
      tempest_image_name              => $tempest_image_name,
      tempest_image_name_alt          => $tempest_image_name_alt,
      tempest_username                => $tempest_username,
      tempest_username_alt            => $tempest_username_alt,
      tempest_username_admin          => $tempest_username_admin,
      tempest_configure_network       => $tempest_configure_network,
      tempest_public_network_name     => $tempest_public_network_name,
      tempest_cinder_available        => $tempest_cinder_available,
      tempest_glance_available        => $tempest_glance_available,
      tempest_horizon_available       => $tempest_horizon_available,
      tempest_nova_available          => $tempest_nova_available,
      tempest_neutron_available       => $tempest_neutron_available,
      tempest_heat_available          => $tempest_heat_available,
      tempest_swift_available         => $tempest_swift_available,
    }
  }
}
