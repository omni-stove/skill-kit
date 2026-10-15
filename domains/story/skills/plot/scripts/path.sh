#!/bin/sh
# Usage: path.sh [<slug> | <existing plot file>]
# No argument: prints the existing plot files under story/plot/, one per line, in
# natural sort order, then how to develop the plot from them. An existing plot file: the
# check to run on it. <slug> (kebab-case English title, no leading number): prints the
# plot's `Output:` path, with the action to take when it already exists. The path is the existing plot
# with that slug, or else story/plot/NNN-<slug>.md, where NNN is three digits: the
# highest leading number already in story/plot/ rounded up to the next ten (010 when
# there is none).
set -eu
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
dir=story/plot
[ $# -le 1 ] || { echo "usage: path.sh [<slug> | <existing plot file>]" >&2; exit 2; }
if [ $# -eq 1 ] && [ -f "$1" ]; then
  echo "Check: $1"
  prompt check
  exit 0
fi
if [ $# -eq 0 ]; then
  [ -d "$dir" ] && find "$dir" -maxdepth 1 -type f -name '*.md' ! -name '.*' | sort -V
  prompt develop self="$0"
  exit 0
fi
printf '%s' "$1" | grep -Eq '^[a-z][a-z0-9]*(-[a-z0-9]+)*$' \
  || { echo "path: slug must be kebab-case and start with a letter: $1" >&2; exit 1; }
max=0
out=
for f in "$dir"/*.md; do
  [ -f "$f" ] || continue
  name=$(basename -- "$f" .md)
  n=$(printf '%s' "$name" | sed -n 's/^\([0-9][0-9]*\).*/\1/p')
  [ "$name" = "$1" ] || [ "$name" = "$n-$1" ] && [ -z "$out" ] && out=$f
  n=$(printf '%s' "$n" | sed 's/^0*//')
  [ "${n:-0}" -gt "$max" ] && max=${n:-0}
done
if [ -n "$out" ]; then
  echo "Output: $out"
  prompt exists
else
  printf 'Output: %s/%03d-%s.md\n' "$dir" $(( (max / 10 + 1) * 10 )) "$1"
fi
prompt write
