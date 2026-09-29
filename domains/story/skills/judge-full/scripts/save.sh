#!/bin/sh
# Usage: save.sh <manuscript-path> <label> < report
# Writes the report read from stdin to
# out/judge-full/<manuscript name>-<label>-<epoch>.md and prints the path written.
base=$(basename "$1")
mkdir -p out/judge-full
path="out/judge-full/${base%.*}-$2-$(date +%s).md"
cat > "$path"
printf '%s\n' "$path"
