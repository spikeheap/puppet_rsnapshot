class rsnapshot_directory {
  
  # TODO backup user
  # TODO backup user SSH keys
  # TODO require SSH
  
  #backup	/home/		localhost/
  #backup	/etc/		localhost/
  #backup	/usr/local/	localhost/
  
  concat::fragment { "rsnapshot_fragment_$name":
    target  => '/etc/rsnapshot.conf',
    content => "backup	$directory	${::fqdn}/\n",
    order   => '15',
  }
}