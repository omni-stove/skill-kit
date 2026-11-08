#!/bin/sh
# Usage: plots.sh
# Prints each plot file in story/plot/ with the file it is drafted into, in natural
# sort order: story/plot/<x>.md -> draft/<leading number of x, else x>.txt. Then an
# Exists line per output already there, and the step to draft them all.
set -eu
[ $# -eq 0 ] || { echo "usage: plots.sh" >&2; exit 2; }
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
dir=story/plot
out=draft
files=$(find "$dir" -maxdepth 1 -type f -name '*.md' ! -name '.*' 2>/dev/null | sort -V)
[ -n "$files" ] || { echo "plots: no plot files in $dir; write the plots there and run this again" >&2; exit 1; }
pairs=$(printf '%s\n' "$files" | while IFS= read -r f; do
  stem=$(basename -- "$f" .md)
  num=$(printf '%s' "$stem" | sed -n 's/^\([0-9][0-9]*\).*/\1/p')
  printf '%s\t%s\n' "$f" "$out/${num:-$stem}.txt"
done)
dup=$(printf '%s\n' "$pairs" | cut -f2 | sort | uniq -d | head -n 1)
[ -z "$dup" ] || { echo "plots: more than one plot file drafts into $dup; give them different leading numbers and run this again" >&2; exit 1; }
mkdir -p "$out"
printf '%s\n' "$pairs"
exists=$(printf '%s\n' "$pairs" | cut -f2 | while IFS= read -r o; do
  [ ! -f "$o" ] || echo "Exists: $o"
done)
if [ -n "$exists" ]; then
  printf '%s\n' "$exists"
  prompt exists
fi
prompt write dir="$dir"
