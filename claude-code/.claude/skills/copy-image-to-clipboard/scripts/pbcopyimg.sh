#!/bin/bash
# Copy an image file to the macOS clipboard.
# Usage: pbcopyimg.sh <image-file>
# Supported: png, jpg, jpeg, tif, tiff, gif, pdf
set -euo pipefail

[[ -f "${1:-}" ]] || { echo "usage: pbcopyimg.sh <image-file>" >&2; exit 1; }

abs="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
ext="$(printf '%s' "${1##*.}" | tr '[:upper:]' '[:lower:]')"

case "$ext" in
  png)       class="PNGf" ;;
  jpg|jpeg)  class="JPEG" ;;
  tif|tiff)  class="TIFF" ;;
  gif)       class="GIFf" ;;
  pdf)       class="PDF " ;;
  *) echo "pbcopyimg.sh: unsupported type: .$ext" >&2; exit 1 ;;
esac

osascript -e "set the clipboard to (read (POSIX file \"$abs\") as «class ${class}»)"
echo "copied $abs to clipboard"
