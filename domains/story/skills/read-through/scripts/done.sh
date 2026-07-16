#!/bin/sh
# Usage: done.sh <file>
# Records the file as processed in its directory's read-through progress.
dir=$(cd "$(dirname "$1")" && pwd)
state="out/read-through/$(echo "$dir" | tr '/' '_').state"
mkdir -p out/read-through
basename "$1" >> "$state"
