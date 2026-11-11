#!/bin/sh
# Usage: report.sh
# Builds draft/report.md from draft/.report/: the outputs written, the plots left undrafted
# (no notes file, or no output), the outputs short of their ## Length, then each written
# plot's notes. Removes draft/.report/ and prints the summary and the step to reply with it.
set -eu
[ $# -eq 0 ] || { echo "usage: report.sh" >&2; exit 2; }
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
work=draft/.report
list=$work/plots.tsv
report=draft/report.md
tab=$(printf '\t')
nl='
'
[ -f "$list" ] || { echo "report: no $list; run plots.sh first" >&2; exit 1; }
written=
undrafted=
short=
body=$work/body
: > "$body"
while IFS="$tab" read -r p o _ n; do
  if [ ! -s "$n" ] || [ ! -f "$o" ]; then
    undrafted=$undrafted$p$nl
    continue
  fi
  written=$written$o$nl
  s=$(sh "$(dirname -- "$0")/../../../refs/length.sh" "$p" "$o")
  [ -z "$s" ] || short="$short$o $s$nl"
  { printf '\n## %s (%s)\n\n' "$o" "$p"; cat "$n"; } >> "$body"
done < "$list"
section() {
  [ -z "$2" ] || printf '%s:\n%s' "$1" "$2"
}
summary=$(section Written "$written"; section Undrafted "$undrafted"; section Short "$short")
{ printf '# Draft report\n\n%s\n' "$summary"; cat "$body"; } > "$report"
rm -rf "$work"
printf 'Report: %s\n%s\n' "$report" "$summary"
prompt report
