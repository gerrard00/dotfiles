function _get_session_name() 
{
  echo ${${PWD##*/}:gs/\./_/}
}

function work()
{
  tmuxinator start node -n $(_get_session_name)
}

function stopwork()
{
  # kill the current session
  tmux kill-session # -t $(_get_session_name)  
  exit
}
