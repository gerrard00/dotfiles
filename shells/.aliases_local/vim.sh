function vim_changed() {
 local source_branch="origin/master"

  if ! git show-ref --verify --quiet refs/remotes/origin/master; then
    if git show-ref --verify --quiet refs/remotes/origin/main; then
      source_branch="origin/main"
    else
      echo "No default branch found. Please specify a valid source branch."
      return 1
    fi
  fi

  vim -- $(git diff --name-only "$source_branch"...HEAD)
}
