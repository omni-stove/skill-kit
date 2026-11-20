#!/bin/sh
# Usage: check.sh <source file> <output file> [<report file>]
# Prints the checks guard-scan's scan.sh --whole gives for the output file, then the
# hand-off to reply with.
set -eu
[ $# -eq 2 ] || [ $# -eq 3 ] || { echo "usage: check.sh <source file> <output file> [<report file>]" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=$(local_path "$1")
f=$(local_path "$2")
report=${3:-}
[ -f "$src" ] || { echo "check: no such file: $src" >&2; exit 1; }
[ -f "$f" ] || { echo "check: no such file: $f" >&2; exit 1; }
[ -z "$report" ] || [ -f "$report" ] || { echo "check: no such file: $report" >&2; exit 1; }
sh "$(dirname -- "$0")/../../../refs/guard-scan/scripts/scan.sh" --whole "$f"
prompt check-hand-off
