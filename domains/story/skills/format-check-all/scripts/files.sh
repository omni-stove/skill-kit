#!/bin/sh
# Usage: files.sh <directory | file in it>
# Prints the directory's .txt files one per line, in natural sort order —
# synopsis and dotfiles excluded — then how to check them.
set -eu
[ $# -eq 1 ] || { echo "usage: files.sh <directory | file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
set -- "$(local_path "$1")"
if [ -d "$1" ]; then dir=$(cd "$1" && pwd)
elif [ -f "$1" ]; then dir=$(cd "$(dirname -- "$1")" && pwd)
else echo "files: no such file or directory: $1" >&2; exit 1; fi
files=$(find "$dir" -maxdepth 1 -type f -name '*.txt' ! -name 'synopsis*' ! -name '.*' | sort -V)
printf '%s\n' "$files" | grep . || true
if [ "$(printf '%s\n' "$files" | grep -c .)" -eq 1 ]; then
  prompt one file="$files"
else
  prompt many
fi
