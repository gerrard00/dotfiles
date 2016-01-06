autoload -U compinit promptinit colors

compinit
promptinit
colors

#setup spectrum to support custom colors
# TODO: this won't be needed if I switch to zpresto, just use their spectrum module
source ~/.zsh_lib/spectrum.zsh 

#setup git stuff
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' actionformats "%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f "
zstyle ':vcs_info:*' formats "%{$fg[blue]%}%b%{$reset_color%}%"

precmd() {
    vcs_info
}

#setup prompt substitution, used by git
setopt PROMPT_SUBST

PROMPT="
%{$FG[044]%}%~%{$reset_color%}
$ "

RPROMPT='${vcs_info_msg_0_}'

setopt HIST_IGNORE_DUPS

#nvm use is too slow on my beaters
if [ -s ~/.nvm/nvm.sh ]; then
  . ~/.nvm/nvm.sh
  #nvm use node
fi

if [ -x ~/.aliases ]; then
	. ~/.aliases
fi

#this works, but requries me to enter the passphrase at login 
eval $(keychain --eval -Q --quiet id_rsa)

#use vi mode
bindkey -v

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\e[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline
