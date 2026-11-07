#!/bin/sh
# Usage: paths.sh <base> <slug>...   (one kebab-case slug per confirmed segment, in order)
# Writes the plot file skeleton to one path per slug and prints the path:
# story/plot/NNN-<base>-<slug>.md. NNN is three digits stepping by 10, starting after the highest leading number already in story/plot/
# rounded up to the next ten (010 when there is none). Then how to fill them.
set -eu
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
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
  set -- "$@" "$(printf '%s/%03d-%s-%s.md' "$dir" "$n" "$base" "$s")"
  shift
  n=$((n + 10))
done
printf '%s\n' "$@"
prompt paths
sh "$(dirname -- "$0")/../../../refs/plot-skeleton.sh" "$@"
