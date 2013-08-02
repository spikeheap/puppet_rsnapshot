class rsnapshot {

package { 'rsnapshot':
  ensure => present,
}
#
# TODO owner, group, mode
#  
file { '/etc/rsnapshot.conf':
  ensure  => present,
  source  => 'puppet:///modules/rsnapshot/etc/rsnapshot.conf',
  require => Package['rsnapshot'],
}

file { '/etc/default/rsync':
  ensure  => present,
  source  => 'puppet:///modules/rsnapshot/etc/default/rsync',
}
}
