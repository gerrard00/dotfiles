# setup fzf keybindings (NOTE: not tab completions)

if [ "$(uname)" = "Darwin" ]; then
  # source /opt/homebrew/Cellar/fzf/0.33.0/shell/key-bindings.zsh
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
else
  source /usr/share/fzf/key-bindings.zsh
fi


# set ag as the file list generator for fzf instead of find to get .gitignore honored
export FZF_DEFAULT_COMMAND='ag --hidden -g'
# export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

# from: https://github.com/junegunn/fzf/wiki/examples#opening-files

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local files

  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0 --preview="cat {}"))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
fo() {
  local out file key
  IFS=$'\n' out=($(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e --preview="cat {}"))
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
}

# GAL: custom, use ag twice for in file search
fa() {
  # echo $@
  # couldn't get this to work with rg for now
  local files=($(ag --nobreak --nonumbers --noheading -l $1 | fzf --preview="ag $1 -C {}"))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}
