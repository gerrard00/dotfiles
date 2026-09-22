set_title() {
    if [ -n "$TMUX" ]; then
        # Inside tmux - tmux owns the outer title via set-titles-string, so
        # override it for this session instead of sending an escape sequence
        # (DCS passthrough needs allow-passthrough, and tmux would overwrite
        # the title on its next recompute anyway). No argument reverts to the
        # global default.
        if [ -n "$1" ]; then
            tmux set-option set-titles-string "$1"
        else
            tmux set-option -u set-titles-string
        fi
    else
        # Outside tmux - direct escape sequence
        printf '\033]0;%s\007' "$1"
    fi
}
