
# https://github.com/idank/explainshell/issues/4#issuecomment-354709120

explainshell () {
  # Here strings are noted to be faster for a small amount of
  # data as compared to pipes where the setup cost dominates.
  # https://unix.stackexchange.com/a/219806/158139
  response=$(w3m -dump "https://explainshell.com/explain?cmd="$(echo $@ | tr ' ' '+'))
  cat -s <(grep -v -e explainshell -e • -e □ -e "source manpages" <<< "$response")
}
