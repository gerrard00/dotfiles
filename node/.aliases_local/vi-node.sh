if type rlwrap > /dev/null; then
  function vi-node() {
    NODE_NO_READLINE=1 EDITOR=vi rlwrap node
  }
fi
