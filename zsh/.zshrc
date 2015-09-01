autoload -U compinit promptinit
compinit
promptinit

PROMPT='%~ %% '

setopt HIST_IGNORE_DUPS

. ~/.nvm/nvm.sh
