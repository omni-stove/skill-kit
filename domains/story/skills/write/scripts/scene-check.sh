#!/bin/sh
# Usage: scene-check.sh <output file>
# Fixes the output file's format through format.sh, then prints the checks
# to run over the file before each hand-off, then the
# narration lines with a negative sentence ending (ない。, なかった。), the
# narration lines with a sentence ending on だった。, the lines format.sh
# finds against the format rules, and the hand-off to reply with.
set -eu
[ $# -eq 1 ] || { echo "usage: scene-check.sh <output file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
set -- "$(local_path "$1")"
f=$1
[ -f "$f" ] || { echo "scene-check: no such file: $f" >&2; exit 1; }
format=.agents/refs/format.sh
[ -f "$format" ] || format=$(dirname -- "$0")/../../../refs/format.sh
fmt=$(sh "$format" "$f")
prompt checks
neg=$(grep -nE '(ない|なかった)。' "$f" | grep -vE '^[0-9]+:[「『]' || true)
if [ -n "$neg" ]; then
  prompt negative
  printf '%s\n' "$neg"
fi
datta=$(grep -n 'だった。' "$f" | grep -vE '^[0-9]+:[「『]' || true)
if [ -n "$datta" ]; then
  prompt datta
  printf '%s\n' "$datta"
fi
if [ -n "$fmt" ]; then
  prompt format
  printf '%s\n' "$fmt"
fi
prompt hand-off
