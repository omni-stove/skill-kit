#!/bin/sh
# Usage: save.sh <directory | file in it>  (report text on stdin)
# Writes the report to this directory's record, out/proofread/<dir key>.md,
# keeping only the latest run's report, and prints the record path and the closing step.
set -eu
[ $# -eq 1 ] || { echo "usage: save.sh <directory | file>  (report on stdin)" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
set -- "$(local_path "$1")"
if [ -d "$1" ]; then dir=$(cd "$1" && pwd)
elif [ -f "$1" ]; then dir=$(cd "$(dirname -- "$1")" && pwd)
else echo "save: no such file or directory: $1" >&2; exit 1; fi
key=$(echo "$dir" | tr '/' '_')
mkdir -p out/proofread
record="out/proofread/$key.md"
cat > "$record"
echo "$record"
prompt saved
