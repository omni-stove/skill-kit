#!/bin/sh
# Usage: draft.sh <plot file> <output file> <report file>
# Prints the step to draft the whole plot into the output, once the Agent's
# report on the plot is saved.
set -eu
[ $# -eq 3 ] || { echo "usage: draft.sh <plot file> <output file> <report file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
f=$(local_path "$1")
out=$(local_path "$2")
report=$3
[ -f "$f" ] || { echo "draft: no such file: $f" >&2; exit 1; }
[ -s "$report" ] || { echo "draft: the report $report is missing or empty; wait for the Agent to save it there and run this again" >&2; exit 1; }
prompt draft gaps="$(dirname -- "$0")/gaps.sh" file="$f" out="$out" report="$report"
