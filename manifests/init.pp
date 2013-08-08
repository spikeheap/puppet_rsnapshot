class rsnapshot (
  $snapshot_root          = '/var/cache/rsnapshot/',
  $no_create_root         = false,
  $cmd_cp                 = '/bin/cp',
  $cmd_rm                 = '/bin/rm',
  $cmd_rsync              = '/usr/bin/rsync',
  $cmd_ssh                = '/usr/bin/ssh',
  $cmd_logger             = '/usr/bin/logger',
  $cmd_du                 = '/usr/bin/du',
  $cmd_rsnapshot_diff     = '/usr/bin/rsnapshot-diff',
  $cmd_preexec            = undef,
  $use_lvm                = false,
  $linux_lvm_cmd_lvcreate =	'/sbin/lvcreate',
  $linux_lvm_cmd_lvremove =	'/sbin/lvremove',
  $linux_lvm_cmd_mount	  =	'/bin/mount',
  $linux_lvm_cmd_umount	  = '/bin/umount',
  $linux_lvm_snapshotsize = '4096M',
  $linux_lvm_snapshotname = 'rsnapshot',
  $linux_lvm_vgpath       = '/dev',
  $linux_lvm_mountpath    = '/tmp/lvm_snapshot',
  $interval_hourly        = 6,
  $interval_daily         = 7,
  $interval_weekly        = 4,
  $interval_monthly       = 72,
  $console_verbosity      = 2, # 1 to 5, inclusive. 5 = debug
  $log_level              = 3, # 1 to 5, inclusive. 5 = debug
  $log_file               = '/var/log/rsnapshot.log',
  $lockfile               = '/var/run/rsnapshot/rsnapshot.pid',
  $stop_on_stale_lockfile = false,
  $rsync_short_args	      = '-a',
  $rsync_long_args	      = '--delete --numeric-ids --relative --delete-excluded',
  $ssh_args               = undef,
  $du_args                = '-csh',
  $one_fs                 = false,
  $rsync_include          = [],
  $rsync_exclude          = [],
  $rsync_include_file     = [],
  $rsync_exclude_exclude  = [],
  $link_dest              = true,
  $sync_first             = false,
  $use_lazy_deletes       = false,
  $rsync_numtries         = 0,
){

  package { 'rsnapshot':
    ensure => present,
  }
  #
  # TODO owner, group, mode
  #  
#  file { '/etc/rsnapshot.conf':
#    ensure  => present,
#    source  => 'puppet:///modules/rsnapshot/etc/rsnapshot.conf',
#    require => Package['rsnapshot'],
#  }
  
  file { '/var/run/rsnapshot':
    ensure  => directory,
	# TODO owner & group
  }
  
  file { '/etc/default/rsync':
    ensure  => present,
    source  => 'puppet:///modules/rsnapshot/etc/default/rsync',
  }
  
  concat { '/etc/rsnapshot.conf': }
   
  concat::fragment { 'rsnapshot_default':
    target  => '/etc/rsnapshot.conf',
    content => template('rsnapshot.conf'),
    order   => '01',
  }
}
