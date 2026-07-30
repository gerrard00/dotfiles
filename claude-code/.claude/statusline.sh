#!/usr/bin/env bash
# Claude Code status line: show the Jira ticket for the current session.
# The active ticket is set exclusively by the `notes` skill (start/resume work),
# stored per-session at ~/.claude/active-ticket/<session_id>. It is NOT derived
# from the git branch. Prints nothing when no ticket is set for this session.

input=$(cat)
session=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -z "$session" ] && exit 0

state_file="$HOME/.claude/active-ticket/$session"
[ -f "$state_file" ] || exit 0

key=$(tr -d '[:space:]' < "$state_file")
[ -z "$key" ] && exit 0

printf '🎫 %s' "$key"
