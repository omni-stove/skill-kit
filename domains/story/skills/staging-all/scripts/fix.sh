#!/bin/sh
# Usage: fix.sh <file>
# Prints the fix rules, then how to apply them to the selected findings in the file.
set -eu
[ $# -eq 1 ] || { echo "usage: fix.sh <file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
set -- "$(local_path "$1")"
[ -f "$1" ] || { echo "fix: no such file: $1" >&2; exit 1; }
cat "$(dirname -- "$0")/../../../refs/fix-rules.md"
echo
prompt fix target="$1"
