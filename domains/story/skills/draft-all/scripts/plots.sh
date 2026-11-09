#!/bin/sh
# Usage: plots.sh [--overwrite | --keep]
# Pairs each plot file in story/plot/, in natural sort order, with the file it is drafted
# into: story/plot/<x>.md -> draft/<leading number of x, else x>.txt. With outputs already
# there and neither option, prints an Exists line per output and the step to choose one.
# Otherwise lists the plots to draft in draft/.report/plots.tsv, --keep leaving out those
# with an output, as plot, output, report file and notes file, then prints each plot with
# its report file and the step to check them, which leads to write.sh.
set -eu
mode=
case $#:${1:-} in
  0:) ;;
  1:--overwrite | 1:--keep) mode=$1 ;;
  *) echo "usage: plots.sh [--overwrite | --keep]" >&2; exit 2 ;;
esac
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
dir=story/plot
out=draft
work=$out/.report
tab=$(printf '\t')
files=$(find "$dir" -maxdepth 1 -type f -name '*.md' ! -name '.*' 2>/dev/null | sort -V)
[ -n "$files" ] || { echo "plots: no plot files in $dir; write the plots there and run this again" >&2; exit 1; }
pairs=$(printf '%s\n' "$files" | while IFS= read -r f; do
  stem=$(basename -- "$f" .md)
  num=$(printf '%s' "$stem" | sed -n 's/^\([0-9][0-9]*\).*/\1/p')
  printf '%s\t%s\n' "$f" "$out/${num:-$stem}.txt"
done)
dup=$(printf '%s\n' "$pairs" | cut -f2 | sort | uniq -d | head -n 1)
[ -z "$dup" ] || { echo "plots: more than one plot file drafts into $dup; give them different leading numbers and run this again" >&2; exit 1; }
exists=$(printf '%s\n' "$pairs" | cut -f2 | while IFS= read -r o; do
  [ ! -f "$o" ] || echo "Exists: $o"
done)
if [ -z "$mode" ] && [ -n "$exists" ]; then
  printf '%s\n' "$exists"
  prompt exists plots="$0"
  exit 0
fi
rm -rf "$work"
mkdir -p "$work"
printf '%s\n' "$pairs" | while IFS="$tab" read -r p o; do
  if [ "$mode" = --keep ] && [ -f "$o" ]; then
    continue
  fi
  k=$(basename -- "$o" .txt)
  printf '%s\t%s\t%s\t%s\n' "$p" "$o" "$work/$k.check.md" "$work/$k.notes.md"
done > "$work/plots.tsv"
[ -s "$work/plots.tsv" ] || { rm -rf "$work"; echo "plots: every plot already has a draft, so none is left to draft" >&2; exit 1; }
cut -f1,3 "$work/plots.tsv"
prompt check others="$(dirname -- "$0")/../../../refs/others.sh" write="$(dirname -- "$0")/write.sh"
