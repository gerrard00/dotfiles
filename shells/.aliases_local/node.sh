
# is this messing up nvm
node_deps() (

local folder_path=$1
local pattern=$2
local package_file

  # Check if package-lock.json exists
  if [[ -f "$folder_path/package-lock.json" ]]; then
    package_file="$folder_path/package-lock.json"
    # Check if package.json exists
  elif [[ -f "$folder_path/package.json" ]]; then
    package_file="$folder_path/package.json"
  else
    # Neither package-lock.json nor package.json exists
    echo -e "\xf0\x9f\x98\xa2" >&2  # Print sad face emoji to stderr
    # exit 1
  fi

  # Extract dependencies matching the pattern from the chosen package file
  local dependencies
  if [[ "$package_file" == *".lock.json" ]]; then
    dependencies=$(jq -r ".dependencies | to_entries[] | select(.key | test(\"$pattern\")) | \"\(.key) \(.value.version)\"" "$package_file")
  else
    dependencies=$(jq -r ".dependencies | to_entries[] | select(.key | test(\"$pattern\")) | \"\(.key) \(.value)\"" "$package_file")
  fi

  # Display the matching dependencies
  if [[ -n $dependencies ]]; then
    echo "Matching dependencies in $package_file:"
    echo "$dependencies"
  else
    echo "No matching dependencies found."
  fi
)
