#!/bin/sh
# Usage: write.sh
# Prints each plot from draft/.report/plots.tsv as plot, output, report file and notes file,
# and the step to draft them, each Agent ending on check.sh, once every plot's report is
# saved. Leads to report.sh.
set -eu
[ $# -eq 0 ] || { echo "usage: write.sh" >&2; exit 2; }
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
list=draft/.report/plots.tsv
tab=$(printf '\t')
[ -f "$list" ] || { echo "write: no $list; run plots.sh first" >&2; exit 1; }
missing=$(while IFS="$tab" read -r p _ c _; do
  [ -s "$c" ] || printf '%s\n' "$p"
done < "$list")
[ -z "$missing" ] || { printf 'write: no report saved for these plots; launch their Agents again and run this again:\n%s\n' "$missing" >&2; exit 1; }
cat "$list"
prompt write dir=story/plot check="$(dirname -- "$0")/check.sh" report="$(dirname -- "$0")/report.sh"
