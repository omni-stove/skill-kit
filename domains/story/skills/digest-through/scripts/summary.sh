#!/bin/sh
# Usage: summary.sh <directory | file in it>  (overall understanding on stdin)
# Appends the overall understanding to this directory's record,
# out/digest-through/<dir key>.md, under "## Overall", and prints the record
# path. Rejects an empty summary.
set -eu
[ $# -eq 1 ] || { echo "usage: summary.sh <directory | file>  (summary on stdin)" >&2; exit 2; }
if [ -d "$1" ]; then dir=$(cd "$1" && pwd)
elif [ -f "$1" ]; then dir=$(cd "$(dirname -- "$1")" && pwd)
else echo "summary: no such file or directory: $1" >&2; exit 1; fi
key=$(echo "$dir" | tr '/' '_')
record="out/digest-through/$key.md"
mkdir -p out/digest-through
summary=$(cat)
if [ -z "$(printf '%s' "$summary" | tr -d '[:space:]')" ]; then
  echo "an overall understanding on stdin is required; nothing written" >&2
  exit 1
fi
printf '## Overall\n\n%s\n' "$summary" >> "$record"
echo "$record"
