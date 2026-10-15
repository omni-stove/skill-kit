#!/bin/sh
# Usage: summary.sh <file>  (overall summary text on stdin)
# Appends the summary to this directory's record,
# out/read-through/<dir key>.impressions.md, under "## Overall Summary",
# and prints the record path and the closing action. Rejects an empty summary.
. "$(dirname -- "$0")/../../../refs/local-path.sh"
set -- "$(local_path "$1")"
dir=$(cd "$(dirname "$1")" && pwd)
key=$(echo "$dir" | tr '/' '_')
record="out/read-through/$key.impressions.md"
mkdir -p out/read-through
summary=$(cat)
if [ -z "$(printf '%s' "$summary" | tr -d '[:space:]')" ]; then
  echo "an overall summary on stdin is required; nothing written" >&2
  exit 1
fi
printf '## Overall Summary\n\n%s\n' "$summary" >> "$record"
echo "$record"
echo "Output that record path and the summary."
