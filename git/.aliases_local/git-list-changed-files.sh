git-list-changed-files() {
  local files=$(git diff --name-only origin/master...HEAD && \
    # use status to get all untracked files and all files which are modified but not committed
    git status --porcelain | awk '$1 == "??" || $1 == "M" { print substr($0, 4) }')

  echo "$files"
}
