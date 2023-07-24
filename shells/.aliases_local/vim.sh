# function vim_changed() {
#  local source_branch="origin/master"

#   if ! git show-ref --verify --quiet refs/remotes/origin/master; then
#     if git show-ref --verify --quiet refs/remotes/origin/main; then
#       source_branch="origin/main"
#     else
#       echo "No default branch found. Please specify a valid source branch."
#       return 1
#     fi
#   fi

#   vim -- $(git diff --name-only "$source_branch"...HEAD)
# }

function vim_open_to_line() {
  # Check if the script is invoked with exactly one argument
  if [ $# -ne 1 ]; then
    echo "Usage: $0 <file#line[:column] or file?...Lline>"
    exit 1
  fi

  if [[ $1 =~ "\?" ]]; then
    echo "Question Mark Case"
    # Extract file path and line from the argument for the '?...Lline' case
    file=$(echo $1 | sed -E 's/\?.*L[0-9]*$//')
    line=$(echo $1 | grep -Eo 'L[0-9]*$' | tr -d 'L')

    # Check if the file exists
    if [ ! -f "$file" ]; then
      echo "Error: File '$file' not found."
      exit 1
    fi

    # Check if line is a number
    if [[ -z "$line" ]] || ! [[ $line =~ ^[0-9]+$ ]]; then
      echo "Error: Line number '$line' is not valid."
      exit 1
    else
      # Open vim at the specified line
      vim +$line $file
    fi
  else
    # Extract file path, line, and column from the argument for the '#line[:column]' case
    file=$(echo $1 | sed -E 's/#[0-9]*(:[0-9]*)?$//')
    line=$(echo $1 | grep -Eo '#[0-9]*' | tr -d '#')
    column=$(echo $1 | grep -Eo ':[0-9]*' | tr -d ':')

    # Check if the file exists
    if [ ! -f "$file" ]; then
      echo "Error: File '$file' not found."
      exit 1
    fi

    # Check if line is a number
    if [[ -z "$line" ]] || ! [[ $line =~ ^[0-9]+$ ]]; then
      echo "Error: Line number '$line' is not valid."
      exit 1
    elif [ -z "$column" ]; then
      # If column is not specified, open vim at the specified line
      vim +$line $file
    elif [[ $column =~ ^[0-9]+$ ]]; then
      # If column is specified and is a number, open vim at the specified line and column
      vim +$line +normal\ ${column}G $file
    else
      echo "Error: Column number '$column' is not valid."
      exit 1
    fi
  fi
}
