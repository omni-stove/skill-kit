#!/bin/sh
# Usage: source.sh
# Prints the files the outline draws on — README.md, the character, world and item
# files, story/timeline.md, story/synopsis.txt and the plot files under story/plot/,
# each when present — then story/outline.md when it exists, then how to build it.
set -eu
. "$(dirname -- "$0")/../../../refs/prompt.sh"
[ $# -eq 0 ] || { echo "usage: source.sh" >&2; exit 2; }
out=story/outline.md
echo "== read =="
[ -f README.md ] && echo README.md
for d in characters world items; do
  [ -d "$d" ] && find "$d" -type f -name '*.md' ! -name '.*' | sort
done
for f in story/timeline.md story/synopsis.txt; do
  [ -f "$f" ] && echo "$f"
done
[ -d story/plot ] && find story/plot -maxdepth 1 -type f -name '*.md' ! -name '.*' | sort -V
if [ -f "$out" ]; then
  echo "$out"
  prompt exists out="$out"
fi
prompt develop out="$out"
