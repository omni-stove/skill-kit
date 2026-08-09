#!/bin/sh
# Usage: next.sh <file>
# Prints the next unprocessed .txt file in <file>'s directory with its line
# count — natural sort, synopsis and dotfiles excluded. When every file is
# processed, prints ALL_DONE and clears the progress record so the next run
# starts fresh.
dir=$(cd "$(dirname "$1")" && pwd)
key=$(echo "$dir" | tr '/' '_')
state="out/read-through/$key.state"
record="out/read-through/$key.impressions.md"
last="out/read-through/$key.last"
mkdir -p out/read-through
touch "$state"
# fresh run: drop the previous run's impressions record
[ -s "$state" ] || : > "$record"
next=$(find "$dir" -maxdepth 1 -type f -name '*.txt' ! -name 'synopsis*' ! -name '.*' | sort -V |
  while IFS= read -r f; do
    grep -Fxq "$(basename "$f")" "$state" || { printf '%s\n' "$f"; break; }
  done)
if [ -n "$next" ]; then
  wc -l "$next"
else
  rm -f "$state" "$last"
  echo ALL_DONE
fi
