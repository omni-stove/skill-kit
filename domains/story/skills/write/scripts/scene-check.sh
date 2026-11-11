#!/bin/sh
# Usage: scene-check.sh <source file> <output file> [<report file>]
# Fixes the output file's format through format.sh, then prints the checks to run
# over the file before each hand-off, the narration lines setting a thing against
# a denied alternative (ではなく, ではない。, というより and the like), the narration
# lines describing a voice or sound (低い声, 声は平らだった and the like), the narration
# lines with a negative sentence ending (ない。, なかった。), the lines format.sh finds against the format rules,
# and the hand-off to reply with, which runs check.sh on the same arguments once
# the source has no Scene left, or on y when the source is the output file itself.
set -eu
[ $# -eq 2 ] || [ $# -eq 3 ] || { echo "usage: scene-check.sh <source file> <output file> [<report file>]" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=$(local_path "$1")
f=$(local_path "$2")
[ -f "$src" ] || { echo "scene-check: no such file: $src" >&2; exit 1; }
[ -f "$f" ] || { echo "scene-check: no such file: $f" >&2; exit 1; }
format=.agents/refs/format.sh
[ -f "$format" ] || format=$(dirname -- "$0")/../../../refs/format.sh
fmt=$(sh "$format" --guard "$f")
prompt checks
contrast=$(grep -nE 'ではな(く|い。|かった。)|というより|でも.*でもなく|のとは違(う|った)。|わけ(では|でも|じゃ)な' "$f" | grep -vE '^[0-9]+:(「|『)' || true)
if [ -n "$contrast" ]; then
  prompt contrast
  printf '%s\n' "$contrast"
fi
# Blanks words that only look like a described voice or sound before matching.
sound=$(awk '!/^(「|『)/ {
  s = $0
  gsub(/笑い声|銃声|本音|また(声|音)|みな声/, "", s)
  if (s ~ /(い|な|た)(声|音)|(声|音)は|声の(高さ|低さ|調子)|声が(尖|小さ|大き|遠|低|高|細|太|硬|弱|平|震|かす|掠|上ず|裏返)/) print NR ":" $0
}' "$f")
if [ -n "$sound" ]; then
  prompt sound
  printf '%s\n' "$sound"
fi
# ではない。 and ではなかった。 are on the contrast list already.
neg=$(awk '!/^(「|『)/ {
  s = $0
  gsub(/ではな(い|かった)。/, "", s)
  if (s ~ /(ない|なかった)。/) print NR ":" $0
}' "$f")
if [ -n "$neg" ]; then
  prompt negative
  printf '%s\n' "$neg"
fi
if [ -n "$fmt" ]; then
  prompt format
  printf '%s\n' "$fmt"
fi
check="$(dirname -- "$0")/check.sh \"$src\" \"$f\""
[ $# -eq 2 ] || check="$check \"$3\""
if [ "$src" = "$f" ]; then
  prompt hand-off-revise check="$check"
else
  prompt hand-off check="$check"
fi
