#!/bin/sh
# Usage: opening.sh <story-dir>
# Prints the manuscript's opening files in natural sort order — synopsis and
# dotfiles excluded — up to and including the file that carries the running
# character total past 15,000.
total=0
find "$1" -maxdepth 1 -type f ! -name 'synopsis*' ! -name '.*' | sort -V |
while IFS= read -r f; do
  [ "$total" -ge 15000 ] && break
  printf '%s\n' "$f"
  total=$((total + $(wc -m < "$f")))
done
