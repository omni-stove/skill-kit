#!/bin/sh
# Usage: pairs.sh <directory | file in it>
# Prints one tab-separated line per .txt file in the directory, in natural
# sort order — synopsis and dotfiles excluded:
#   <file> <TAB> <next file, or "-" for the last one>
set -eu
[ $# -eq 1 ] || { echo "usage: pairs.sh <directory | file>" >&2; exit 2; }
if [ -d "$1" ]; then dir=${1%/}
elif [ -f "$1" ]; then dir=$(dirname -- "$1")
else echo "pairs: no such file or directory: $1" >&2; exit 1; fi
find "$dir" -maxdepth 1 -type f -name '*.txt' ! -name 'synopsis*' ! -name '.*' | sort -V |
awk 'NR > 1 { printf "%s\t%s\n", prev, $0 } { prev = $0 } END { if (NR) printf "%s\t-\n", prev }'
