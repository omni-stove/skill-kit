#!/bin/sh
# Usage: save.sh <file>  (report text on stdin)
# Writes the report to this file's record, out/staging/<file key>.md,
# keeping only the latest run's report, and prints the record path and how to fix.
set -eu
[ $# -eq 1 ] || { echo "usage: save.sh <file>  (report on stdin)" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
set -- "$(local_path "$1")"
[ -f "$1" ] || { echo "save: no such file: $1" >&2; exit 1; }
path=$(cd "$(dirname -- "$1")" && pwd)/$(basename -- "$1")
key=$(echo "$path" | tr '/' '_')
mkdir -p out/staging
record="out/staging/$key.md"
cat > "$record"
echo "$record"
prompt saved fix="$(dirname -- "$0")/fix.sh" target="$1"
