#!/bin/sh
# Usage: next.sh <file>
# Prints the next unprocessed file in <file>'s directory with its line count —
# natural sort, synopsis and dotfiles excluded. When every file is processed,
# prints ALL_DONE and clears the progress record so the next run starts fresh.
dir=$(cd "$(dirname "$1")" && pwd)
state="out/read-through/$(echo "$dir" | tr '/' '_').state"
mkdir -p out/read-through
touch "$state"
next=$(find "$dir" -maxdepth 1 -type f ! -name 'synopsis*' ! -name '.*' | sort -V |
  while IFS= read -r f; do
    grep -Fxq "$(basename "$f")" "$state" || { printf '%s\n' "$f"; break; }
  done)
if [ -n "$next" ]; then
  wc -l "$next"
else
  rm -f "$state"
  echo ALL_DONE
fi
