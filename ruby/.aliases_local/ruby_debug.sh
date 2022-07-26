function rap {
  git diff --name-only $1...HEAD | while read file;
  do
    sed -I '' '/^[[:blank:]]*puts(.*$/d' $file
  done
}

