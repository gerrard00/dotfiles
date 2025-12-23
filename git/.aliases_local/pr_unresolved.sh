# Needs: gh, jq, and gh-pr-review ("gh pr-review …")
if (( $+commands[gh] )) && (( $+commands[jq] )); then
  pr_unresolved() {
    local repo pr

    repo="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)" || {
      echo "Couldn't determine repo (are you in a git repo logged into gh?)" >&2
      return 1
    }

    pr="$(gh pr view --json number -q .number 2>/dev/null)" || {
      echo "No PR found for the current branch." >&2
      return 1
    }

    # threads list gives us: threadId, path, line (sometimes), isOutdated, etc.
    local threads_json
    threads_json="$(gh pr-review threads list --unresolved -R "$repo" "$pr" 2>/dev/null)" || return 1

    if [[ "$threads_json" == "[]" || -z "$threads_json" ]]; then
      echo "No unresolved review threads 🎉"
      return 0
    fi

    # Fetch latest comment snippet + URL for each threadId via GraphQL (works even when outdated)
    echo "$threads_json" | jq -r '.[].threadId' | while IFS= read -r tid; do
      gh api graphql -f query='
        query($id:ID!) {
          node(id:$id) {
            ... on PullRequestReviewThread {
              isResolved
              isOutdated
              path
              line
              comments(last:1) { nodes { body url author { login } } }
            }
          }
        }' -f id="$tid" 2>/dev/null \
      | jq -r '
          .data.node as $t
          | ($t.comments.nodes[0] // {}) as $c
          | "• \($t.path)\(if ($t.line != null) then ":\($t.line)" else "" end)\(if ($t.isOutdated==true) then " (outdated)" else "" end)\n  \($c.author.login // "unknown"): \($c.body // "" | gsub("\r\n"; "\n") | gsub("\n"; " ") | .[0:180])\n  \($c.url // "")\n"
        '
    done
  }
fi