#!/bin/sh
# Usage: source.sh <plot file>
# Prints the output file the plot is drafted into and the step to report on the
# plot into the check file under report/, which leads to draft.sh. Clears any
# working files an earlier run left there.
# Output, from where the plot sits: plot/<x>.md -> ../<leading number of x,
# else x>.txt; plot.md -> index.txt beside it; another .md -> <stem>.txt beside it.
# Then prints a Reference line for each file references.sh gives.
set -eu
[ $# -eq 1 ] || { echo "usage: source.sh <plot file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
. "$(dirname -- "$0")/report-file.sh"
f=$(local_path "$1")
[ -f "$f" ] || { echo "source: no such file: $f" >&2; exit 1; }
case $f in
  *.md) ;;
  *) echo "source: $f is not a plot file; give the plot/<x>.md the story file is written from" >&2; exit 1 ;;
esac
dir=$(dirname -- "$f")
stem=$(basename -- "$f" .md)
case $(basename -- "$dir") in
  plot)
    num=$(printf '%s' "$stem" | sed -n 's/^\([0-9][0-9]*\).*/\1/p')
    out="$(dirname -- "$dir")/${num:-$stem}.txt" ;;
  *)
    [ "$stem" = plot ] && stem=index
    out="$dir/$stem.txt" ;;
esac
out=${out#./}
check=$(report_file "$out" check)
mkdir -p "$(dirname -- "$check")"
rm -f "$check" "$(report_file "$out" notes)"
echo "Output: $out"
prompt scope others="$(dirname -- "$0")/../../../refs/others.sh" file="$f"
sh "$(dirname -- "$0")/../../../refs/references.sh" "$f" | sed 's/^/Reference: /'
[ ! -f "$out" ] || prompt exists
prompt report file="$f" draft="$(dirname -- "$0")/draft.sh" out="$out" check="$check"
