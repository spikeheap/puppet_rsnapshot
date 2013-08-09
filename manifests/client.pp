class rsnapshot::client( $ssh_public_key, $dirs = [] ){
  include ssh-client

  user { 'rsnapshotclient':
    ensure     => present,
    home       => '/home/rsnapshotclient',
    managehome => true,
    uid        => '5001',
    gid        => 'backup',
    shell      => '/bin/bash',
  }

  group { 'backupclient':
    ensure => present,
    gid    => '5001',
  }

  file { '/home/rsnapshotclient/.ssh/':
    ensure  => directory,
    owner   => 'rsnapshotclient',
    group   => 'backup',
    mode    => '0600'
  }

  file { '/home/rsnapshotclient/.ssh/authorized_keys':
    ensure  => present,
    content => $ssh_public_key,
    owner   => 'rsnapshotclient',
    group   => 'backupclient',
    mode    => '0600',
  }

  rsnapshot::directory{$dirs: }
}
