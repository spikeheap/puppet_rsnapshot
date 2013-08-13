class rsnapshot::client( $server_ip, $ssh_rsa_pub_key, $dirs = [] ){
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
    options => [ "from=\"$server_ip\"",
                 'command="/usr/local/rsnapshot/validate_rsync.sh"',
                 'no-port-forwarding',
                 'no-X11-forwarding',
                 'no-agent-forwarding',
                 'no-pty']
  }

  # Include partial hostname 'app1.site' in hosts like 'app1.site.company.com'.
  $partial_hostname = regsubst($fqdn, '\.nmi\.uk\.com$', '')
  if $partial_hostname == $hostname {
    $host_aliases = [ $ipaddress, $hostname ]
  } else {
    $host_aliases = [ $ipaddress, $hostname, $partial_hostname ]
  }

  file{'/usr/local/rsnapshot/':
    ensure => directory,
    owner  => 'rsnapshotclient',
    group  => 'backupclient',
    mode   => '0754',
  }

  file{'/usr/local/rsnapshot/validate_rsync.sh':
    ensure => file,
    source => 'puppet:///modules/rsnapshot/validate_rsync.sh',
    owner  => 'rsnapshotclient',
    group  => 'backupclient',
    mode   => '0754',
    # TODO make owner and group variables
  }

  file{'/usr/local/rsnapshot/rsync_wrapper.sh':
    ensure => file,
    source => 'puppet:///modules/rsnapshot/rsync_wrapper.sh',
    owner  => 'rsnapshotclient',
    group  => 'backupclient',
    mode   => '0754',
    # TODO make owner and group variables
  }

#  file{'/usr/local/rsnapshot/rsnapshot-rsync.conf':
#    ensure  => file,
#    source  => 'puppet:///modules/rsnapshot/rsnapshot-rsync.conf',
#    owner  => 'rsnapshotclient',
#    group  => 'backupclient',
#    mode   => '0644',
# }

  # This is necessary because of a bug in Puppet which makes it unreadable by default (http://projects.puppetlabs.com/issues/21811)
  file{'/etc/ssh/ssh_known_hosts':
    ensure => file,
    owner  => 'root', 
    group  => 'root',
    mode   => '0644',
  }
  @@sshkey{"${::fqdn}":
    ensure  => present,
    type    => 'rsa',
    key     => $sshrsakey,
    host_aliases => $host_aliases,
    tag     => 'rsnapshot-client',
  }
  Sshkey <<| tag == 'rsnapshot' |>>

## TODO wrap in IF
# This is only necessary for the remote rsync with sudo configuration
# TODO sudoers:
# rsnapshotclient ALL=NOPASSWD:/usr/bin/rsync
  rsnapshot::directory{$dirs: }
}
