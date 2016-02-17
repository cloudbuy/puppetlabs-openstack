class openstack::common::keystone {
  if $::openstack::profile::base::is_controller {
    if $::openstack::config::keystone_use_httpd == true {
      $service_name = 'httpd'
    } else {
      $service_name = undef
    }
    if ($::openstack::config::ha == true) {
      $admin_bind_host    = $::openstack::profile::base::management_address
      $public_bind_host   = $::openstack::profile::base::management_address
      $management_address = $::openstack::profile::base::management_address
    } else {
      $admin_bind_host    = '0.0.0.0'
      $public_bind_host   = '0.0.0.0'
      $management_address = $::openstack::config::controller_address_management
    }
  } else {
    $admin_bind_host    = $::openstack::config::controller_address_management
    $management_address = $::openstack::config::controller_address_management
    $service_name       = undef
  }

  $user                = $::openstack::config::mysql_user_keystone
  $pass                = $::openstack::config::mysql_pass_keystone
  $database_connection = "mysql://${user}:${pass}@${management_address}/keystone"

  class { '::keystone':
    admin_token         => $::openstack::config::keystone_admin_token,
    database_connection => $database_connection,
    verbose             => $::openstack::config::verbose,
    debug               => $::openstack::config::debug,
    enabled             => $::openstack::profile::base::is_controller,
    admin_bind_host     => $admin_bind_host,
    public_bind_host    => $public_bind_host,
    service_name        => $service_name,
  }
  
  keystone_config {
    'oslo_middleware/max_request_body_size': value => 114688,
  }

  # Remove admin_auth_token from the pipeline
  keystone_paste_ini {
    'pipeline:public_api/pipeline': value => 'sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension user_crud_extension public_service';
    'pipeline:admin_api/pipeline': value  => 'sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension s3_extension crud_extension admin_service';
    'pipeline:api_v3/pipeline': value     => 'sizelimit url_normalize request_id build_auth_context token_auth json_body ec2_extension_v3 s3_extension simple_cert_extension revoke_extension federation_extension oauth1_extension endpoint_filter_extension service_v3';
  }
}
