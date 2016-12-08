function curl-post-json() {
  local url=$1
  local jsonFile=$2

  curl -H "Content-Type: application/json" -X POST -d @$jsonFile $url
}

