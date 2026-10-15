#!/bin/sh
# Usage: paths.sh <base> <slug>...   (one kebab-case slug per confirmed segment, in order)
# Prints one output path per slug: story/plot/NNN-<base>-<slug>.md. NNN is three digits
# stepping by 10, starting after the highest leading number already in story/plot/
# rounded up to the next ten (010 when there is none). Then how to fill them.
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
cat <<'NEXT'
Create each plot file at its path above, in order. Rewrite its segment as a plot skeleton by
the loaded plot format, the project's world setting, and the character information — never
a verbatim copy. Keep concrete narrative or dialogue worth keeping in the 地の文 / 会話
sections, pulled from the source file when present; invent no new lines. Aim for 3-8
paragraphs per file by segment density. Cross-reference adjacent segments for continuity:
how the scene begins from the previous, how it leads to the next. Apply the loaded plot
format rules exactly to the plot body, 地の文, 会話, and 参照 sections. Then present the
created files and ask whether any needs adjustment or further splitting/merging.
NEXT
