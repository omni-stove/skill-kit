#!/bin/sh
# Usage: opening.sh <story-dir>
# Prints the manuscript's opening files in natural sort order — synopsis and
# dotfiles excluded — stopping at whichever running character total lands
# closest to 10,000.
total=0
find "$1" -maxdepth 1 -type f ! -name 'synopsis*' ! -name '.*' | sort -V |
while IFS= read -r f; do
  next=$((total + $(wc -m < "$f")))
  here=$((10000 - total)); [ "$here" -lt 0 ] && here=$((-here))
  there=$((10000 - next)); [ "$there" -lt 0 ] && there=$((-there))
  [ "$total" -gt 0 ] && [ "$there" -ge "$here" ] && break
  printf '%s\n' "$f"
  total=$next
done
