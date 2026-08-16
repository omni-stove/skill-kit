#!/bin/sh
# Usage: next.sh <file>
# Prints the next unprocessed .txt file in <file>'s directory with its line
# count — natural sort, synopsis and dotfiles excluded. A fresh run opens a
# new record, out/read-through/<dir key>-<epoch>.impressions.md, and notes its
# path in the .record file so done.sh appends to the same one; earlier runs'
# records are kept. When every file is processed, prints ALL_DONE and clears
# the progress record so the next run starts fresh.
dir=$(cd "$(dirname "$1")" && pwd)
key=$(echo "$dir" | tr '/' '_')
state="out/read-through/$key.state"
recordref="out/read-through/$key.record"
last="out/read-through/$key.last"
mkdir -p out/read-through
touch "$state"
# fresh run: open a new timestamped record for this run's impressions
if [ ! -s "$state" ]; then
  record="out/read-through/$key-$(date +%s).impressions.md"
  printf '%s\n' "$record" > "$recordref"
  : > "$record"
fi
next=$(find "$dir" -maxdepth 1 -type f -name '*.txt' ! -name 'synopsis*' ! -name '.*' | sort -V |
  while IFS= read -r f; do
    grep -Fxq "$(basename "$f")" "$state" || { printf '%s\n' "$f"; break; }
  done)
if [ -n "$next" ]; then
  wc -l "$next"
else
  rm -f "$state" "$last" "$recordref"
  echo ALL_DONE
fi
