define openstack::resources::database (
  $user = pick(getvar("::openstack::config::mysql_user_${title}"),getvar("::openstack::config::${title}::mysql_user")),
  $password = pick(getvar("::openstack::config::mysql_pass_${title}"),getvar("::openstack::config::${title}::mysql_pass"))
) {
  class { "::${title}::db::mysql":
    user          => $user,
    password      => $password,
    dbname        => $title,
    allowed_hosts => $::openstack::config::mysql_allowed_hosts,
    require       => Anchor['database-service'],
  }
}
