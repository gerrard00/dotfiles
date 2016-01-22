function work() {
	i3-msg "append_layout ~/.i3/layouts/work.json"

	urxvt -cd "$target_directory"&
	urxvt -cd "$target_directory"&

	vim
}
