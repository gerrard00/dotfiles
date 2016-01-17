function work() {
	i3-msg "append_layout ~/dotfiles/i3/.i3/layouts/programming.json"

	urxvt -cd "$target_directory"&
	urxvt -cd "$target_directory"&

	vim
}
