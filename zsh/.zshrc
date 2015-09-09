autoload -U compinit promptinit colors

compinit
promptinit
colors

#setup spectrum to support custom colors
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

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-monokai.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
