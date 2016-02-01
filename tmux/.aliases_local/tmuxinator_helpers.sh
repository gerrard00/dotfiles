function work()
{
  local project_name=${${PWD##*/}:s/\./_/}

  tmuxinator start node -n $project_name
}

function stopwork()
{
  local project_name=${${PWD##*/}:s/\./_/}
  tmux kill-session -t $project_name
  exit
}
