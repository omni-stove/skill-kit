#!/bin/sh
# Usage: done.sh <file>  (impression text on stdin)
# Records the file as processed and appends the impression to the run's
# record. Rejects an empty impression so a file can only be marked done
# together with its review.
dir=$(cd "$(dirname "$1")" && pwd)
key=$(echo "$dir" | tr '/' '_')
state="out/read-through/$key.state"
record="out/read-through/$key.impressions.md"
mkdir -p out/read-through
impression=$(cat)
if [ -z "$impression" ]; then
  echo "impression required on stdin; file not recorded" >&2
  exit 1
fi
printf '## %s\n\n%s\n\n' "$(basename "$1")" "$impression" >> "$record"
basename "$1" >> "$state"
