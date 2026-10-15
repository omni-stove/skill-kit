#!/bin/sh
# Usage: bundle.sh <directory | file in it>
# Writes the directory's .txt files — natural sort order, synopsis and dotfiles
# excluded — into one bundle at out/dupcheck-all/<dir key>.txt, every line
# prefixed "<filename>:<line number><TAB>", replacing the previous run's bundle.
# Prints the bundle path and its line count, then how to check it.
set -eu
[ $# -eq 1 ] || { echo "usage: bundle.sh <directory | file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
set -- "$(local_path "$1")"
if [ -d "$1" ]; then dir=$(cd "$1" && pwd)
elif [ -f "$1" ]; then dir=$(cd "$(dirname -- "$1")" && pwd)
else echo "bundle: no such file or directory: $1" >&2; exit 1; fi
key=$(echo "$dir" | tr '/' '_')
mkdir -p out/dupcheck-all
bundle="out/dupcheck-all/$key.txt"
: > "$bundle"
find "$dir" -maxdepth 1 -type f -name '*.txt' ! -name 'synopsis*' ! -name '.*' | sort -V |
while IFS= read -r f; do
  awk -v n="$(basename -- "$f")" '{ printf "%s:%d\t%s\n", n, FNR, $0 }' "$f" >> "$bundle"
done
printf '%s\t%s lines\n' "$bundle" "$(wc -l < "$bundle" | tr -d ' ')"
prompt next
