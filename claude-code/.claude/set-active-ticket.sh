#!/usr/bin/env bash
# Set or clear the active Jira ticket for the current Claude session.
# Used only by the `notes` skill to drive the status line (see statusline.sh).
#
#   set-active-ticket.sh PC-3633   # set the active ticket for this session
#   set-active-ticket.sh           # clear it
#
# State is stored per-session at ~/.claude/active-ticket/<session_id>.

session="$CLAUDE_CODE_SESSION_ID"
[ -z "$session" ] && { echo "CLAUDE_CODE_SESSION_ID is not set" >&2; exit 1; }

dir="$HOME/.claude/active-ticket"
mkdir -p "$dir"

key="$1"
if [ -z "$key" ]; then
  rm -f "$dir/$session"
  echo "Cleared active ticket for this session."
else
  printf '%s' "$key" > "$dir/$session"
  echo "Set active ticket to $key."
fi
