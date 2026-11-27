#!/bin/sh
# Usage: write.sh <source file> <output file> <report file>
# Prints the step to have one Agent write the whole output from the source and the
# report alone, once the report is saved, which leads to check.sh.
set -eu
[ $# -eq 3 ] || { echo "usage: write.sh <source file> <output file> <report file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
f=$(local_path "$1")
out=$(local_path "$2")
report=$3
[ -f "$f" ] || { echo "write: no such file: $f" >&2; exit 1; }
[ -s "$report" ] || { echo "write: the report $report is missing or empty; wait for the Agent's report, save it there, and run this again" >&2; exit 1; }
prompt write check="$(dirname -- "$0")/check.sh" file="$f" out="$out" report="$report"
