define rsnapshot::directory {
  
  # TODO backup user
  # TODO backup user SSH keys
  # TODO require SSH
  
  # Add a slash if it's been omitted (otherwise rsnapshot just won't work)
  if $name !~ /\/$/ {
    $directory = "${name}/"
  }else{
    $directory = "${name}"
  }

  # Build a single directory fragment for rsnapshot.conf.
  # The format is:
  #   backup	DIRECTORY	BACKUP_DEST
  # Both DIRECTORY and BACKUP_DEST must be followed with a slash.
  #   DIRECTORY		The source for the backup, e.g. backupuser@example.com:/etc/puppet/
  #
  #   BACKUP_DEST	The destination for the backup on the rsnapshot server, e.g. example.com/
  #			Note that this doesn't include the path from DIRECTORY.
  concat::fragment { "rsnapshot_fragment_$directory":
    target  => '/etc/rsnapshot.conf',
    content => "backup	$directory	${::fqdn}/\n",
    order   => '15',
  }
}
