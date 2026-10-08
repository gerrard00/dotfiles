#!/usr/bin/env bash
# Claude Code status line: show the Jira ticket for the current session,
# context-window usage, whether a wrap up is waiting on approval, and which of
# the ~/projects worktrees the session is in. The active ticket and the wrap up
# marker are set exclusively by the `notes` skill, stored per-session at
# ~/.claude/active-ticket/<session_id> and ~/.claude/wrapup-pending/<session_id>.
# Neither is derived from the git branch.
# The ticket and context segments are independent: either can be absent. The
# wrap up marker only renders alongside at least one of them. The worktree
# segment is right aligned on the same row.

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

# Each repo under ~/projects has sibling worktrees suffixed -parallel and
# -review; the unsuffixed directory is the default one. Anything outside a
# ~/projects git checkout gets no segment rather than a misleading "default".
worktree=""
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
case "$cwd" in
  "$HOME"/projects/*)
    rest=${cwd#"$HOME"/projects/}
    repo=${rest%%/*}
    if [ -e "$HOME/projects/$repo/.git" ]; then
      case "$repo" in
        *-parallel) worktree="🌳 parallel" ;;
        *-review)   worktree="🌳 review" ;;
        *)          worktree="🌳 default" ;;
      esac
    fi
    ;;
esac

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

# Printable width: drop the SGR sequences, then count astral-plane glyphs twice
# because terminals render emoji double width.
vislen() {
  printf '%s' "$1" \
    | sed $'s/\033\\[[0-9;]*m//g' \
    | jq -Rrs '((./"\n")[0] // "") | length + ([explode[] | select(. >= 128512 or (. >= 127744 and . <= 129782))] | length)'
}

# The row is narrower than $COLUMNS by a fixed amount: the interface's own
# margins plus the `padding` setting, neither of which this script can read.
# Measured at 8 columns; 9 leaves a cell of slack so the row never truncates.
GUTTER=9
if [ -n "$worktree" ] && [ -n "${COLUMNS:-}" ]; then
  target=$((COLUMNS - GUTTER))
  gap=$((target - $(vislen "$out") - $(vislen "$worktree")))
  if [ "$gap" -ge 1 ]; then
    printf '%s%*s%s' "$out" "$gap" "" "$worktree"
    exit 0
  fi
fi

# Too narrow to right align, or no width reported: fall back to an inline segment.
if [ -n "$worktree" ]; then
  [ -n "$out" ] && out="$out · "
  out="$out$worktree"
fi

printf '%s' "$out"
