#!/bin/sh
# Usage: save.sh  (梗概本文 on stdin)
# Normalizes the body to the 梗概 format — removes blank lines and leading
# spaces/tabs/full-width spaces — writes it to story/synopsis.txt, and prints the path.
out=story/synopsis.txt
body=$(cat)
if [ -z "$(printf '%s' "$body" | tr -d '[:space:]')" ]; then
  echo "梗概本文 on stdin is required; nothing written" >&2
  exit 1
fi
mkdir -p "$(dirname "$out")"
printf '%s\n' "$body" | sed -e 's/^[[:space:]　]*//' -e '/^$/d' > "$out"
echo "$out"
