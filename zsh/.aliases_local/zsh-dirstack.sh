setopt autopushd

DIRBOOKMARKSFILE=~/.zdirbookmarks

# if [[ $#dirstack -eq 0 ]] && [[ -f $DIRBOOKMARKSFILE ]]; then
if [[ -f $DIRBOOKMARKSFILE ]]; then
  dirstack=( ${(f)"$(< $DIRBOOKMARKSFILE)"} )
else
	touch $DIRBOOKMARKSFILE
fi

bookmark() {
	local tmpfile=$(mktemp /tmp/XXXzdirs_tempXXX)
  cat $DIRBOOKMARKSFILE >! $tmpfile
  echo $PWD >> $tmpfile
	sort $tmpfile | uniq  >! $DIRBOOKMARKSFILE
}

bookmark() {
	local tmpfile=$(mktemp /tmp/XXXzdirs_tempXXX)
  cat $DIRBOOKMARKSFILE >! $tmpfile
  echo $PWD >> $tmpfile
	sort $tmpfile | uniq  >! $DIRBOOKMARKSFILE
}

unbookmark() {
	local tmpfile=$(mktemp /tmp/XXXzdirs_tempXXX)
  cat $DIRBOOKMARKSFILE | grep -v "^$PWD$"  >! $tmpfile
	mv $tmpfile $DIRBOOKMARKSFILE
}
