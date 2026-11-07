#!/bin/sh
# Usage: gaps.sh <plot file> <output file> <report file>
# Prints the step to fill the passages marked in the saved draft from the
# author's answers, which leads to finish.sh.
set -eu
[ $# -eq 3 ] || { echo "usage: gaps.sh <plot file> <output file> <report file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
f=$(local_path "$1")
out=$(local_path "$2")
report=$3
[ -f "$f" ] || { echo "gaps: no such file: $f" >&2; exit 1; }
[ -f "$out" ] || { echo "gaps: no such file: $out; save the draft there and run this again" >&2; exit 1; }
prompt gaps finish="$(dirname -- "$0")/finish.sh" file="$f" out="$out" report="$report"
