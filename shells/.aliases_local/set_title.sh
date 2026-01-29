set_title() {
    if [ -n "$TMUX" ]; then
        # Inside tmux - use passthrough
        printf '\033Ptmux;\033\033]0;%s\007\033\\' "$1"
    else
        # Outside tmux - direct escape sequence
        printf '\033]0;%s\007' "$1"
    fi
}
