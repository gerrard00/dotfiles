function remove_debug_rad {
  upstream=$1

  sed_changed_files $upstream '/^[[:blank:]]*debugger[[:blank:]]*$/d'
}
