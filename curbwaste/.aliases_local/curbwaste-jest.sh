run-e2e() {
  local pattern='tests/e2e/**/*.spec.ts'
  local changed
  changed=($(
    {
      git diff --name-only origin/main... -- "$pattern"
      git diff --name-only -- "$pattern"
      git diff --name-only --cached -- "$pattern"
      git ls-files --others --exclude-standard -- "$pattern"
    } | sort -u
  ))

  if (( ${#changed[@]} == 0 )); then
    echo "✅ No changed E2E test files since origin/main."
    return 0
  fi

  echo "🔍 Running Jest on changed E2E tests since origin/main:"
  printf '  %s\n' "${changed[@]}"
  echo ""

  node -r dotenv/config ./node_modules/.bin/jest "${changed[@]}" \
    --watch \
    --detectOpenHandles \
    --runInBand \
    --forceExit \
    --showSeed \
    --dotenv_config_path=.env.test
}

run-unit () {
    # Get remote default branch (e.g. origin/main or origin/master)
    local default_branch
    default_branch=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)

    # Fallback if origin/HEAD isn't set
    if [[ -z "$default_branch" ]]; then
        if git show-ref --verify --quiet refs/remotes/origin/main; then
            default_branch="origin/main"
        else
            default_branch="origin/master"
        fi
    fi

    local pattern='tests/unit/**/*.spec.ts'
    local changed
    changed=($(
      {
        git diff --name-only "$default_branch"... -- "$pattern"
        git diff --name-only -- "$pattern"
        git diff --name-only --cached -- "$pattern"
        git ls-files --others --exclude-standard -- "$pattern"
      } | sort -u
    ))

    if (( ${#changed[@]} == 0 )); then
        echo "✅ No changed unit test files since $default_branch."
        return 0
    fi

    echo "🔍 Running Jest on changed unit tests since $default_branch:"
    printf '  %s\n' "${changed[@]}"
    echo ""

    node -r dotenv/config ./node_modules/.bin/jest "${changed[@]}" \
        --watch \
        --detectOpenHandles \
        --runInBand \
        --forceExit \
        --showSeed \
        --dotenv_config_path=.env.test
}

gc() {
  # Get current branch name
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  if [[ $? -ne 0 || -z "$branch" ]]; then
    echo "Error: Unable to determine git branch" >&2
    return 1
  fi

  # Extract commit type (feat or fix) and JIRA ID from branch name
  # Expected format: type-XX-1234-* where type is before first hyphen
  local type jira_id
  if [[ $branch =~ ^([^-]+)-([a-zA-Z]{2})-([0-9]+) ]]; then
    type="${match[1]}"
    jira_id="${(U)match[2]}-${match[3]}"  # Uppercase the letters
  else
    echo "Error: Unable to parse branch name '$branch'" >&2
    echo "Expected format: type-XX-1234-* (e.g., feat-pc-2106-description)" >&2
    return 1
  fi

  # Parse arguments to find and modify the commit message
  local args=()
  local found_message=0
  local i=1

  while [[ $i -le $# ]]; do
    local arg="${@[$i]}"

    # Check if this is -m or -nm flag
    if [[ "$arg" == "-m" || "$arg" == "-nm" ]]; then
      args+=("$arg")
      i=$((i + 1))

      if [[ $i -le $# ]]; then
        local message="${@[$i]}"
        # Prefix the message with type and JIRA ID
        args+=("${type}: ${jira_id} ${message}")
        found_message=1
      else
        echo "Error: -m flag provided but no message found" >&2
        return 1
      fi
    else
      args+=("$arg")
    fi

    i=$((i + 1))
  done

  if [[ $found_message -eq 0 ]]; then
    echo "Error: No commit message found (expected -m or -nm flag)" >&2
    return 1
  fi

  # Execute git commit with modified arguments
  git commit "${args[@]}"
}

prisma_everything() {
  npm run prisma:gen && npm run prisma:apply && npm run prisma:test-apply
}

format_everything() {
  npm run lint:fix && npm run format && npx tsc --noEmit
}
