class rsnapshot::client( $dirs = [] ){
  #$rsnapshot_dirs = hiera('rsnapshot_directories',[])
  rsnapshot::directory{$dirs: }
}
