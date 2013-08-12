class rsnapshot::client( $ssh_rsa_pub_key, $dirs = [] ){
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

  ssh_authorized_key {'rsnapshot_key':
    ensure  => present,
    key     => $ssh_rsa_pub_key,
    type    => 'rsa',
    user    => 'rsnapshotclient',
  }

  # Include partial hostname 'app1.site' in hosts like 'app1.site.company.com'.
  $partial_hostname = regsubst($fqdn, '\.nmi\.uk\.com$', '')
  if $partial_hostname == $hostname {
    $host_aliases = [ $ipaddress, $hostname ]
  } else {
    $host_aliases = [ $ipaddress, $hostname, $partial_hostname ]
  }

  @sshkey{"${::fqdn}_hostkey":
    ensure  => present,
    type    => 'rsa',
    key     => $sshrsakey,
    host_aliases => $host_aliases,
  }

  rsnapshot::directory{$dirs: }
}
