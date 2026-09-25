#!/usr/bin/env bash
# Set or clear the "wrap up pending" marker for the current Claude session.
# Used only by the `notes` skill: set once a Resume context draft is on screen
# awaiting approval, cleared once the write is applied or abandoned.
#
#   set-wrapup-pending.sh 1   # mark wrap up as pending approval
#   set-wrapup-pending.sh     # clear it
#
# State is stored per-session at ~/.claude/wrapup-pending/<session_id>.

session="$CLAUDE_CODE_SESSION_ID"
[ -z "$session" ] && { echo "CLAUDE_CODE_SESSION_ID is not set" >&2; exit 1; }

dir="$HOME/.claude/wrapup-pending"
mkdir -p "$dir"

if [ -z "$1" ]; then
  rm -f "$dir/$session"
  echo "Cleared wrap up pending for this session."
else
  printf '1' > "$dir/$session"
  echo "Marked wrap up as pending approval."
fi
