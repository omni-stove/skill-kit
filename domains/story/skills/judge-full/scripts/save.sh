#!/bin/sh
# Usage: save.sh <manuscript-path> <report>
# Writes the report to out/<manuscript name>-judge-full-<epoch>.md and prints
# the path written.
base=$(basename "$1")
mkdir -p out
path="out/${base%.*}-judge-full-$(date +%s).md"
printf '%s\n' "$2" > "$path"
printf '%s\n' "$path"
