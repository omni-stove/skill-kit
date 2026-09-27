#!/bin/sh
# Usage: synopsis.sh <synopsis-path> <limit>
# Prints the synopsis's character count, newlines excluded, over its limit, then its text.
[ $# -eq 2 ] || { echo "usage: synopsis.sh <synopsis-path> <limit>" >&2; exit 2; }
printf '%s/%s字\n\n' "$(tr -d '\n' < "$1" | LC_ALL=C.UTF-8 wc -m | tr -d ' ')" "$2"
cat "$1"
