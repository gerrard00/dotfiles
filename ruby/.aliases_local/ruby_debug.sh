function remove_debug_rap {
  upstream=$1

  sed_changed_files $upstream '/^[[:blank:]]*puts(.*$/d'
}

