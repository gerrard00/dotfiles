function pgsql_execfile()
{
  clear
  echo "\n"
  tmpfile="$(mktemp).html"
  nodemon --exec "psql -U postgres -h localhost -p 5433 -d $1 -f $2 --html >> $tmpfile && w3m -dump $tmpfile && echo "

}
