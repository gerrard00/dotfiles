#!/usr/bin/env bash
# Claude Code status line: show the Jira ticket for the current session,
# context-window usage, and whether a wrap up is waiting on approval. The
# active ticket and the wrap up marker are set exclusively by the `notes` skill,
# stored per-session at ~/.claude/active-ticket/<session_id> and
# ~/.claude/wrapup-pending/<session_id>. Neither is derived from the git branch.
# The ticket and context segments are independent: either can be absent. The
# wrap up marker only renders alongside at least one of them.

input=$(cat)
session=$(printf '%s' "$input" | jq -r '.session_id // empty')

ticket=""
wrapup=""
if [ -n "$session" ]; then
  state_file="$HOME/.claude/active-ticket/$session"
  [ -f "$state_file" ] && ticket=$(tr -d '[:space:]' < "$state_file")
  [ -f "$HOME/.claude/wrapup-pending/$session" ] && wrapup=$(printf '\033[33mwrap up pending\033[0m')
fi

# used_percentage is null before the first API call and right after /compact.
pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
context=""
if [ -n "$pct" ]; then
  pct=${pct%%.*}
  if [ "$pct" -ge 90 ]; then
    color='\033[31m' # red
  elif [ "$pct" -ge 70 ]; then
    color='\033[33m' # yellow
  else
    color='\033[32m' # green
  fi
  context=$(printf "${color}🧠 %s%%\033[0m" "$pct")
fi

out=""
for segment in "$ticket" "$context"; do
  [ -z "$segment" ] && continue
  [ -n "$out" ] && out="$out · "
  out="$out$segment"
done

# Standalone "wrap up pending" reads as noise, so drop it when nothing precedes it.
if [ -n "$out" ] && [ -n "$wrapup" ]; then
  out="$out · $wrapup"
fi

printf '%s' "$out"
