#
# Sets up the package repos necessary to use OpenStack
# on RHEL-alikes and Ubuntu
#
class openstack::resources::repo(
  $release = 'ocata'
) {
  case $release {
    'ocata', 'newton', 'mitaka', 'liberty', 'kilo', 'juno', 'icehouse', 'havana', 'grizzly': {
      if $::osfamily == 'RedHat' {
        class {'openstack::resources::repo::rdo': release => $release }
        class {'openstack::resources::repo::erlang': }
        class {'openstack::resources::repo::yum_refresh': }
      } elsif $::osfamily == 'Debian' {
        unless ($release == 'mitaka') and (versioncmp($::lsbdistrelease, '16.04') >= 0) {
          class {'openstack::resources::repo::uca': release => $release }
        }
      }
    }
    default: {
      fail { "FAIL: openstack::resources::repo parameter 'release' of '${release}' not recognized; please use one of 'juno', 'icehouse', 'havana', 'grizzly'.": }
    }
  }
}
