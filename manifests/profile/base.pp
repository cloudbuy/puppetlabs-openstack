# The base profile for OpenStack. Installs the repository and ntp
class openstack::profile::base {
  # make sure the parameters are initialized
  include ::openstack

  # everyone also needs to be on the same clock
  include ::ntp

  # all nodes need the OpenStack repository
  class { '::openstack::resources::repo': }

  # database anchor
  anchor { 'database-service': }

  $management_network = $::openstack::config::network_management
  $management_address = ip_for_network($management_network)
  $controller_management_address = $::openstack::config::controller_address_management
  $storage_management_address = $::openstack::config::storage_address_management


  $api_network = $::openstack::config::network_api
  $api_address = ip_for_network($api_network)
  $controller_api_address = $::openstack::config::controller_address_api
  $storage_api_address    = $::openstack::config::storage_address_api

  if ($::openstack::config::ha) {
    $controller_management_addresses = $::openstack::config::controllers.map|String $name, Hash $data| { $data['management'] }
    $controller_api_addresses = $::openstack::config::controllers.map|String $name, Hash $data| { $data['api'] }

    $management_matches = member($controller_management_addresses, $management_address)
    $api_matches = member($controller_api_addresses, $api_address)

    $storage_management_addresses = $::openstack::config::storage.map|String $name, Hash $addr| { $addr['management'] }
    $storage_api_addresses = $::openstack::config::storage.map|String $name, Hash $addr| { $addr['api'] }

    $storage_management_matches = member($storage_management_addresses, $management_address)
    $storage_api_matches = member($storage_api_addresses, $api_address)

  } else {
    $management_matches = ($management_address == $controller_management_address)
    $api_matches = ($api_address == $controller_api_address)

    $storage_management_matches = ($management_address == $storage_management_address)
    $storage_api_matches = ($api_address == $storage_api_address)
  }
    
  $is_controller = ($management_matches and $api_matches)
  $is_storage    = ($storage_management_matches and $storage_api_matches)

  if ($management_matches and $api_matches) and ($::openstack::config::ha) {
    $is_primary_controller = pick($::openstack::config::controllers[$hostname]['primary'], false)
  } else {
    $is_primary_controller = false
  }
}
