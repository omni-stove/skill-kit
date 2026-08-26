#!/bin/sh
# Usage: done.sh <file>  (digest text on stdin)
# Appends the digest to this directory's record, out/digest-through/<dir
# key>.md, records the file as digested, and prints the record path. Rejects an
# empty digest, so a file can only be marked done together with a digest
# written for it.
set -eu
[ $# -eq 1 ] || { echo "usage: done.sh <file>  (digest on stdin)" >&2; exit 2; }
dir=$(cd "$(dirname -- "$1")" && pwd)
key=$(echo "$dir" | tr '/' '_')
state="out/digest-through/$key.state"
record="out/digest-through/$key.md"
mkdir -p out/digest-through
digest=$(cat)
if [ -z "$(printf '%s' "$digest" | tr -d '[:space:]')" ]; then
  echo "a digest on stdin is required; file not recorded" >&2
  exit 1
fi
printf '## %s\n\n%s\n\n' "$(basename -- "$1")" "$digest" >> "$record"
basename -- "$1" >> "$state"
echo "$record"
