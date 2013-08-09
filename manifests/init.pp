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
  $linux_lvm_cmd_lvcreate = '/sbin/lvcreate',
  $linux_lvm_cmd_lvremove = '/sbin/lvremove',
  $linux_lvm_cmd_mount    = '/bin/mount',
  $linux_lvm_cmd_umount   = '/bin/umount',
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
  $rsync_short_args       = '-a',
  $rsync_long_args        = '--delete --numeric-ids --relative --delete-excluded',
  $ssh_args               = undef,
  $du_args                = '-csh',
  $one_fs                 = false,
  $rsync_include          = [],
  $rsync_exclude          = [],
  $rsync_include_file     = [],
  $rsync_exclude_file  = [],
  $link_dest              = true,
  $sync_first             = false,
  $use_lazy_deletes       = false,
  $rsync_numtries         = 0,
  $ssh_private_key        = undef,
  $sync_first            = true,
  $cron_sync_hour        = '*/4',    # Every 4 hours
  $cron_sync_minute      = 0,
  $cron_hourly_hour      = '1-23/4', # Every 4 hours, offset by 1
  $cron_hourly_minute    = 30,
  $cron_daily_hour       = 23,
  $cron_daily_minute     = 0,
  $cron_weekly_hour      = 22,
  $cron_weekly_minute    = 0,
  $cron_monthly_hour     = 21,
  $cron_monthly_minute   = 0,
){

  package { 'rsnapshot':
    ensure => present,
  }

  user { 'rsnapshot':
    ensure     => present,
    home       => '/home/rsnapshot',
    managehome => true,
    uid        => '5000',
    gid        => 'backup',
    shell      => '/bin/bash',
  }

  group { 'backup':
    ensure => present,
    gid    => '5000',
  }

  file { '/home/rsnapshot/.ssh/':
    ensure  => directory,
    owner   => 'rsnapshot',
    group   => 'backup',
    mode    => '0600'
  }

  file { $snapshot_root }:
    ensure => directory,
    owner  => 'backup',
    group  => 'backup',
    mode   => '0700'
  }

  file { '/home/rsnapshot/.ssh/rsnapshot':
    ensure  => present,
    content => $ssh_private_key,
    owner   => 'rsnapshot',
    group   => 'backup',
    mode    => '0600',
  }

  file { '/var/run/rsnapshot':
    ensure  => directory,
    # TODO owner & group
  }

  file { '/etc/default/rsync':
    ensure  => present,
    source  => 'puppet:///modules/rsnapshot/etc/default/rsync',
  }

  # Crontab entries
  if $sync_first {
    cron { 'rsnapshot_sync':
      command => '/usr/bin/rsnapshot sync',
      user    => rsnapshot,
      hour    => $cron_sync_hour,
      minute  => $cron_sync_minute,
    }
  }
  cron { 'rsnapshot_hourly':
    command => '/usr/bin/rsnapshot hourly',
    user    => rsnapshot,
    hour    => $cron_hourly_hour,
    minute  => $cron_hourly_minute,
  }
  cron { 'rsnapshot_daily':
    command => '/usr/bin/rsnapshot daily',
    user    => rsnapshot,
    hour    => $cron_daily_hour,
    minute  => $cron_daily_minute,
  }
  cron { 'rsnapshot_weekly':
    command => '/usr/bin/rsnapshot weekly',
    user    => rsnapshot,
    hour    => $cron_weekly_hour,
    minute  => $cron_weekly_minute,
  }
  cron { 'rsnapshot_monthly':
    command => '/usr/bin/rsnapshot monthly',
    user    => rsnapshot,
    hour    => $cron_monthly_hour,
    minute  => $cron_monthly_minute,
  }

  # Build the Rsnapshot configuration file with the fragments from all clients
  concat { '/etc/rsnapshot.conf': }

  concat::fragment { 'rsnapshot_default':
    target  => '/etc/rsnapshot.conf',
    content => template('rsnapshot/rsnapshot.conf.erb'),
    order   => '01',
  }
}
