#! /bin/zsh

DEFAULT_WARNING="WARNING: in simulation mode so not modifying filesystem."

for folder in */; do
  # for folder in */; do
  echo "- ${folder}"; 
  
  # capture stderr, but send stdout to /dev/tty like normal
  output="$(stow -n -v ${folder} 2>&1)"
  lines=("${(@f)output}")

  for line in $lines; do
    if [[ $line != $DEFAULT_WARNING ]]; then
      echo "\t$line"
    fi
  done

  echo 
done
