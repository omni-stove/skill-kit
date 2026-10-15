#!/bin/sh
# Usage: files.sh <directory | file>
# For a directory, prints its .txt files one per line, in natural sort order —
# synopsis and dotfiles excluded. For a file, prints that file alone. Then prints the
# evaluation to run on them.
set -eu
[ $# -eq 1 ] || { echo "usage: files.sh <directory | file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
set -- "$(local_path "$1")"
if [ -f "$1" ]; then
  files=$(cd "$(dirname -- "$1")" && pwd | tr -d '\n'; printf '/%s' "$(basename -- "$1")")
elif [ -d "$1" ]; then
  dir=$(cd "$1" && pwd)
  files=$(find "$dir" -maxdepth 1 -type f -name '*.txt' ! -name 'synopsis*' ! -name '.*' | sort -V)
else
  echo "files: no such file or directory: $1" >&2; exit 1
fi
printf '%s\n' "$files" | grep . || true
prompt evaluate
[ "$(printf '%s\n' "$files" | grep -c .)" -gt 1 ] && prompt wrap-up
prompt rewrite
