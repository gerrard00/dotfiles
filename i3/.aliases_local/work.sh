function i3work() {
	i3-msg "append_layout ~/.i3/layouts/work.json"

	urxvt &
	urxvt &

	vim
}
