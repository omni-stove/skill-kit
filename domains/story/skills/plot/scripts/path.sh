#!/bin/sh
# Usage: path.sh [<slug>]
# No argument: prints the existing plot files under story/plot/, one per line, in
# natural sort order. <slug> (kebab-case English title, no leading number): prints the
# plot's `Output:` path and the action to take on it.
set -eu
dir=story/plot
[ $# -le 1 ] || { echo "usage: path.sh [<slug>]" >&2; exit 2; }
if [ $# -eq 0 ]; then
  [ -d "$dir" ] || exit 0
  find "$dir" -maxdepth 1 -type f -name '*.md' ! -name '.*' | sort -V
  exit 0
fi
printf '%s' "$1" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$' \
  || { echo "path: slug must be kebab-case and start with a letter: $1" >&2; exit 1; }
out="$dir/$1.md"
echo "Output: $out"
if [ -f "$out" ]; then
  echo "The output file exists. Confirm the overwrite with the author before editing it."
else
  echo "The output file does not exist yet."
fi
