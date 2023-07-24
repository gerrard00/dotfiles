function chamber () {
  aws-vault exec torticity-$1 -- chamber "${@:2}"
}