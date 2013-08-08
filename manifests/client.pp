class rsnapshot::client( $dirs = [] ){
	
  # TODO backup user
  # TODO backup user SSH keys
  # TODO require SSH
	
  rsnapshot::directory{$dirs: }
}
