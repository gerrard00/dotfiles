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
%{$FG[242]%}%~%{$reset_color%}
$ "

RPROMPT='${vcs_info_msg_0_}'

setopt HIST_IGNORE_DUPS

. ~/.nvm/nvm.sh

if [ -x ~/.aliases ]; then
	. ~/.aliases
fi
