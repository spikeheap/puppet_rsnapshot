class rsnapshot::client{
  $rsnapshot_dirs = hiera('rsnapshot_directories',[])
  rsnapshot::directory{$rsnapshot_dirs: }
}
