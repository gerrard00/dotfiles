bindump() {
  node -e "const raw = ($1).toString(2); console.log(raw.padStart(8, '0'));"
}
