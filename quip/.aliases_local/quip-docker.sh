function dcer
{
  command docker compose exec rails "$@"
}

function psql_quip {
  docker compose exec postgres psql -U postgres -d quip_development
}

function dc_recognize_path {
  dcer bundle exec rails runner "puts(Rails.application.routes.recognize_path('$1').to_yaml)"
}
