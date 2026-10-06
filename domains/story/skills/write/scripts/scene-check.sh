#!/bin/sh
# Usage: scene-check.sh <output file>
# Fixes the output file's format through format.sh, then prints the checks
# to run over the file before each hand-off, then the
# narration lines with a negative sentence ending (ない。, なかった。), the
# narration lines with a sentence ending on だった。, and the lines format.sh
# finds against the format rules.
set -eu
[ $# -eq 1 ] || { echo "usage: scene-check.sh <output file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
set -- "$(local_path "$1")"
f=$1
[ -f "$f" ] || { echo "scene-check: no such file: $f" >&2; exit 1; }
format=.agents/refs/format.sh
[ -f "$format" ] || format=$(dirname -- "$0")/../../../refs/format.sh
fmt=$(sh "$format" "$f")
cat <<'EOF'
Read the whole output file and fix each hit in place; you judge what is a hit.

- Sweep for sentences that look back — a past-time word, a replayed line of dialogue, a summary of an event the reader has already read, a comparison of the present with an earlier event, a rewording, summing-up, or explanation of the sentence before — and cut whole each one that hands the reader nothing new.
- Where narration says a thing is absent, did not happen, or is not so, outside what the loaded rules admit, cut it; where an assertion follows it, state the assertion alone.
- Rewrite, from what is known at that point, narration or dialogue that draws on an answer the story gives only later.
- Restore a dropped object, subject, referent, or action where the lines before it do not supply it.
- Where the same wording appears twice, keep one; an echo stays only when the source file names it.
EOF
neg=$(grep -nE '(ない|なかった)。' "$f" | grep -vE '^[0-9]+:[「『]' || true)
if [ -n "$neg" ]; then
  cat <<'EOF'
- Run the absence check above on each negative narration sentence in the lines listed below.

EOF
  printf '%s\n' "$neg"
fi
datta=$(grep -n 'だった。' "$f" | grep -vE '^[0-9]+:[「『]' || true)
if [ -n "$datta" ]; then
  cat <<'EOF'
- Bring the sentences ending on だった, listed below, within the loaded rules' limits.

EOF
  printf '%s\n' "$datta"
fi
if [ -n "$fmt" ]; then
  cat <<'EOF'
- Bring the lines listed below, under the format rule each breaks, within the loaded rules.

EOF
  printf '%s\n' "$fmt"
fi
