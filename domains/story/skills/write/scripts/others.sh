#!/bin/sh
# Usage: others.sh <file>   (a plot file, or the story file itself)
# Prints the other plot and story files around the source, one per number, in
# order: the story file where a number has one, else its plot file. A plot file
# pairs with a story file as source.sh maps it: plot/<x>.md -> ../<leading
# number of x, else x>.txt. The source and its own pair are left out.
set -eu
[ $# -eq 1 ] || { echo "usage: others.sh <file>" >&2; exit 2; }
f=$1
[ -f "$f" ] || { echo "others: no such file: $f" >&2; exit 1; }
dir=$(dirname -- "$f")
base=$(basename -- "$f")
key() {
  stem=$(basename -- "$1")
  stem=${stem%.*}
  num=$(printf '%s' "$stem" | sed -n 's/^\([0-9][0-9]*\).*/\1/p')
  printf '%s' "${num:-$stem}"
}
case $f in
  *.txt) story=$dir; plot=$dir/plot; own=${base%.txt} ;;
  *)
    [ "$(basename -- "$dir")" = plot ] || exit 0
    story=$(dirname -- "$dir"); plot=$dir; own=$(key "$f") ;;
esac
{
  for md in "$plot"/*.md; do
    [ -f "$md" ] || continue
    k=$(key "$md")
    [ "$k" = "$own" ] && continue
    [ -f "$story/$k.txt" ] || printf '%s\t%s\n' "$k" "$md"
  done
  for txt in "$story"/*.txt; do
    [ -f "$txt" ] || continue
    k=$(basename -- "$txt" .txt)
    [ "$k" = "$own" ] || printf '%s\t%s\n' "$k" "$txt"
  done
} | sort | cut -f2 | sed 's|^\./||'
