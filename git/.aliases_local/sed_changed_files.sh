# should be using gitbin: https://medium.com/@santiaro90/write-your-own-git-subcommands-36d08f6a673ej
function exec_against_changed_files {
  upstream=$1
  command=$2

  if [ -z "$upstream" ]; then
    echo "Please provide upstream commitish (e.g. origin/main) as first argument."
    return -1
  fi

  if [ -z "$command" ]; then
    echo "Please provide command as second argument."
    return -2
  fi

  git diff --name-only $upstream...HEAD | while read file;
  do
    echo "$command $file"
    eval "$command $file"
  done
}

function sed_changed_files {
  upstream=$1
  sed_command="sed -I '' '$2'"
  exec_against_changed_files $upstream $sed_command
}
