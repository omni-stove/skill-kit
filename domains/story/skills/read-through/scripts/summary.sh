#!/bin/sh
# Usage: summary.sh <file>  (overall summary text on stdin)
# Appends the summary to this directory's record,
# out/read-through/<dir key>.impressions.md, under "## Overall Summary",
# and prints the record path. Rejects an empty summary.
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
