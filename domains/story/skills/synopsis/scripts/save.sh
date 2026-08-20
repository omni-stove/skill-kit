#!/bin/sh
# Usage: save.sh <story_synopsis path>  (梗概本文 on stdin)
# Normalizes the body to the 梗概 format — removes blank lines and leading
# spaces/tabs/full-width spaces — writes it to the path, and prints the path.
body=$(cat)
if [ -z "$(printf '%s' "$body" | tr -d '[:space:]')" ]; then
  echo "梗概本文 on stdin is required; nothing written" >&2
  exit 1
fi
mkdir -p "$(dirname "$1")"
printf '%s\n' "$body" | sed -e 's/^[[:space:]　]*//' -e '/^$/d' > "$1"
echo "$1"
