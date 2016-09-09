autoload -U compinit promptinit colors

compinit
promptinit
colors

# # Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-twilight.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

#setup git stuff
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' actionformats "%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f "
zstyle ':vcs_info:*' formats "%{$fg[blue]%}%b%{$reset_color%}%"

precmd() {
    vcs_info
}

setopt HIST_IGNORE_DUPS

#setup prompt substitution, used by git
setopt PROMPT_SUBST

function zle-line-init zle-keymap-select {
  # TODO: we have extra braces in the escapes
  local NEWLINE=$'\n'
  local PROMPT_SYMBOL
  local FG_COLOR
  local HOST_DISPLAY

  if [[ $KEYMAP == "vicmd" ]]; then
    PROMPT_SYMBOL="€"
    FG_COLOR=green
  else
    PROMPT_SYMBOL="$"
    FG_COLOR=blue
  fi

  # only show host name while in ssh
  if [[ -n "$SSH_CLIENT" ]]; then
    HOST_DISPLAY="[$HOST] "
  fi

  PROMPT="${NEWLINE}%{$fg[${FG_COLOR}]%}${HOST_DISPLAY}%~${NEWLINE}$PROMPT_SYMBOL%{$reset_color%} "
  zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

RPROMPT='${vcs_info_msg_0_}'

if [ -x ~/.aliases ]; then
  . ~/.aliases
fi

#this works, but requries me to enter the passphrase at login
if (( $+commands[keychain] )); then
  eval $(keychain --eval -Q --quiet id_rsa)
fi

#use vi mode
bindkey -v

# full vim editing for command line
autoload edit-command-line; zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\e[01;01m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;01m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline
