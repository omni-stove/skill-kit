#!/bin/sh
# Usage: paths.sh <base> <slug>...   (one kebab-case slug per confirmed segment, in order)
# Prints one output path per slug: story/plot/NNN-<base>-<slug>.md. NNN is three digits
# stepping by 10, starting after the highest leading number already in story/plot/
# rounded up to the next ten (010 when there is none).
set -eu
dir=story/plot
[ $# -ge 2 ] || { echo "usage: paths.sh <base> <slug>..." >&2; exit 2; }
for s in "$@"; do
  printf '%s' "$s" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' \
    || { echo "paths: not kebab-case: $s" >&2; exit 1; }
done
base=$1; shift
max=0
for f in "$dir"/[0-9]*.md; do
  [ -f "$f" ] || continue
  n=$(basename -- "$f" | sed -n 's/^\([0-9][0-9]*\).*/\1/p' | sed 's/^0*//')
  [ "${n:-0}" -gt "$max" ] && max=${n:-0}
done
n=$(( (max / 10 + 1) * 10 ))
for s in "$@"; do
  printf '%s/%03d-%s-%s.md\n' "$dir" "$n" "$base" "$s"
  n=$((n + 10))
done
