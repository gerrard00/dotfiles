function _get_session_name()
{
  # note: the equal sign tells tmux to match the name exactly
  echo ${${PWD##*/}:gs/\./_/}
}

function work()
{
  local session_name=$(_get_session_name)

  # kill any already attached clients
  # workaround for the fact that iterm2 can't detach from sessions
  # on window close since zprezto sets nohup
  client_cnt=$(tmux list-clients -t "=$session_name" 2>/dev/null | wc -l)
  if [ $client_cnt -ge 1 ]; then
    tmux detach-client  -s "=$session_name"
  fi

  # attach or start the named session
  tmuxinator start node -n "$session_name"
}

function stopwork()
{
  # kill the current session
  tmux kill-session -t "=$(_get_session_name)"
  exit
}

function dbresults()
{
  local session_name=$(_get_session_name)
  local dbresults_session_name="$session_name"_dbresults
  echo $session_name
  echo $dbresults_session_name
  tmux new-session -d -s $dbresults_session_name
  tmux select-window -t "$dbresults_session_name":0
  # tmux kill-window -t 0
  # tmux link-window -s "$session_name":results -t "$dbresults_session_name":1
  # tmux link-window -s "$session_name":results -t "$dbresults_session_name"
  tmux link-window -s "$session_name":results
}
