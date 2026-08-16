#!/bin/sh
# Usage: done.sh <file>  (impression text on stdin)
# Appends the impression to the run's record (the path noted in the .record
# file by next.sh; opened here if missing), records the file as processed,
# and prints the record path. Rejects an impression under 3 lines or identical
# to the previous file's, so a file can only be marked done together with a
# review written for it.
dir=$(cd "$(dirname "$1")" && pwd)
key=$(echo "$dir" | tr '/' '_')
state="out/read-through/$key.state"
recordref="out/read-through/$key.record"
last="out/read-through/$key.last"
mkdir -p out/read-through
impression=$(cat)
if [ "$(printf '%s\n' "$impression" | grep -c .)" -lt 3 ]; then
  echo "an impression of 3+ lines is required on stdin; file not recorded" >&2
  exit 1
fi
if [ -f "$last" ] && [ "$impression" = "$(cat "$last")" ]; then
  echo "impression is identical to the previous file's; file not recorded" >&2
  exit 1
fi
[ -s "$recordref" ] || printf '%s\n' "out/read-through/$key-$(date +%s).impressions.md" > "$recordref"
record=$(cat "$recordref")
printf '%s' "$impression" > "$last"
printf '## %s\n\n%s\n\n' "$(basename "$1")" "$impression" >> "$record"
basename "$1" >> "$state"
echo "$record"
