run-e2e() {
  local changed
  changed=($(git diff --name-only origin/main -- 'tests/e2e/**/*.spec.ts'))

  if (( ${#changed[@]} == 0 )); then
    echo "✅ No changed E2E test files since origin/main."
    return 0
  fi

  echo "🔍 Running Jest on changed E2E tests since origin/main:"
  printf '  %s\n' "${changed[@]}"
  echo ""

  node -r dotenv/config ./node_modules/.bin/jest "${changed[@]}" \
    --watch
    --detectOpenHandles \
    --runInBand \
    --forceExit \
    --showSeed \
    --dotenv_config_path=.env.test
}
