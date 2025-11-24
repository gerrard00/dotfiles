postgres_log_all() {
  local container_name="postgres-15"
  local conf_file="/var/lib/postgresql/data/postgresql.conf"

  echo "Checking if log_statement is already set to 'all' in $container_name..."

  # Check whether it's already set
  local grep_result
  grep_result=$(docker exec -i "$container_name" bash -c "grep -qxF \"log_statement = 'all'\" $conf_file" 2>/dev/null)

  if [[ -z "$grep_result" ]]; then
    echo "Enabling full SQL statement logging..."
    docker exec -i "$container_name" bash -c "echo \"log_statement = 'all'\" >> $conf_file && kill -s SIGHUP 1"
  else
    echo "log_statement is already set to 'all'. Skipping modification."
  fi
}
