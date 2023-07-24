#!/bin/bash

git_branch_search() {
  if [ -z "$1" ]; then
    echo "Error: Missing argument." >&2
    exit 1
  fi

  SEARCH_STRING=$1

  # Iterate over all branches
  for branch in $(git branch -r | grep -v HEAD); do
      # Remove whitespace and "origin/" prefix from branch name
      branch_name=$(echo "$branch" | sed 's/^[[:space:]]*origin\///')

      # Checkout the branch
      git checkout "$branch_name" &> /dev/null

      # Search for the string in the current branch
      echo "Searching in branch: $branch_name"
      git grep -i "$SEARCH_STRING" && echo ""
  done

  # Return to the original branch
  git checkout - &> /dev/null
}
