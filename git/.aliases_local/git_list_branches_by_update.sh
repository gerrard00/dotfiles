#!/bin/bash

function git_list_branches_by_update {

  # Check if we're in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Not a git repository."
    exit 1
  fi

  # Print table header
  printf "%-41s %-26s %s\n" "Branch" "Last Commit Date" "Commit Hash"
  printf "%-41s %-26s %s\n" "------" "----------------" "-----------"

  # List local branches sorted by least recent commit date (so most recent appears last)
  git for-each-ref --sort=committerdate refs/heads/ --format="%(refname:short) %(committerdate:iso8601-strict) %(objectname:short)" | \
  while read -r line; do
    # Use awk to split the line into its components
    branch=$(echo "$line" | awk '{print $1}')
    date=$(echo "$line" | awk '{print $2}')
    hash=$(echo "$line" | awk '{print $3}')

    # Remove timezone (+0000) part from date
    date=$(echo "$date" | cut -d'+' -f1)

    # Truncate the branch name to 20 characters
    truncated_branch=$(echo "$branch" | cut -c 1-40)

    # Print each element in a formatted table row, add a space after the date
    printf "%-41s\t%-26s\t%s\n" "$truncated_branch" "$date==>" "$hash"
  done
}
