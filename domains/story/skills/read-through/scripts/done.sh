#!/bin/sh
# Usage: done.sh <file>  (impression text on stdin)
# Appends the impression to this directory's record,
# out/read-through/<dir key>.impressions.md, and records the file as processed.
# Rejects an impression under 3 lines or identical
# to the previous file's, so a file can only be marked done together with a
# review written for it. Prints the next.sh call for the next file.
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
set -- "$(local_path "$1")"
dir=$(cd "$(dirname "$1")" && pwd)
key=$(echo "$dir" | tr '/' '_')
state="out/read-through/$key.state"
record="out/read-through/$key.impressions.md"
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
printf '%s' "$impression" > "$last"
printf '## %s\n\n%s\n\n' "$(basename "$1")" "$impression" >> "$record"
basename "$1" >> "$state"
prompt done next="$(dirname -- "$0")/next.sh" file="$1"
