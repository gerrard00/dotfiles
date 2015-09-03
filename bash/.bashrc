#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

eval $(keychain --eval -Q --quiet --noask  id_rsa)

TERM='rxvt-unicode'
COLORTERM='rxvt-unicode-256color'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    #should be using my.aliases
    alias ls='ls --color=auto'
    alias grep='grep  --color=auto'
fi
