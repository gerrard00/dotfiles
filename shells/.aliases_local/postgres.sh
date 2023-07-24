postgres_log_all() {
  local conf_file="/var/lib/postgresql/data/postgresql.conf"
  local grep_result=$(docker-compose exec -T postgres bash -c "grep -qxF \"log_statement = 'all'\" $conf_file")

  if [[ -z "$grep_result" ]]; then
    docker-compose exec -T postgres bash -c "echo \"log_statement = 'all'\" >> $conf_file && kill -s SIGHUP 1"
  else
    echo "log_statement is already set to 'all'. Skipping modification."
  fi
}
