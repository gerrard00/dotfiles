claude() {
  # setup one password one time for all mcps
  op vault list >/dev/null || return 1
  command claude "$@"
}
