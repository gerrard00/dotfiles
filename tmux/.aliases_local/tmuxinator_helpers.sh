function _get_session_name() 
{
  echo ${${PWD##*/}:gs/\./_/}
}

function work()
{
  let session_name=$(_get_session_name)

  # kill any already attached clients
  # workaround for the fact that iterm2 can't detach from sessions
  # on window close since zprezto sets nohup
  tmux detach-client  -s $session_name
  # attach or start the named session
  tmuxinator start node -n $session_name
}

function stopwork()
{
  # kill the current session
  tmux kill-session -t $(_get_session_name)  
  exit
}
