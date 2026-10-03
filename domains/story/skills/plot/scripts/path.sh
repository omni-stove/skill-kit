#!/bin/sh
# Usage: path.sh [<slug>]
# No argument: prints the existing plot files under story/plot/, one per line, in
# natural sort order. <slug> (kebab-case English title, no leading number): prints the
# plot's `Output:` path and the action to take on it. The path is the existing plot
# with that slug, or else story/plot/NNN-<slug>.md, where NNN is three digits: the
# highest leading number already in story/plot/ rounded up to the next ten (010 when
# there is none).
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
  echo "The output file exists. Confirm the overwrite with the author before editing it."
else
  printf 'Output: %s/%03d-%s.md\n' "$dir" $(( (max / 10 + 1) * 10 )) "$1"
  echo "The output file does not exist yet."
fi
