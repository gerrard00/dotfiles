function _get_session_name()
{
  # note: the equal sign tells tmux to match the name exactly
  echo ${${PWD##*/}:gs/\./_/}
}

function work()
{
  local type="${1:-default}"
  echo "doing $type"
  local session_name=$(_get_session_name)

  # kill any already attached clients
  # workaround for the fact that iterm2 can't detach from sessions
  # on window close since zprezto sets nohup
  client_cnt=$(tmux list-clients -t "=$session_name" 2>/dev/null | wc -l)
  if [ $client_cnt -ge 1 ]; then
    tmux detach-client  -s "=$session_name"
  fi

  tmuxinator start "$type" -n $session_name
}

function stopwork()
{
  # kill the current session
  tmux kill-session -t "=$(_get_session_name)"
  exit
}
