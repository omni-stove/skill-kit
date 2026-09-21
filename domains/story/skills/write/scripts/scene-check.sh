#!/bin/sh
# Usage: scene-check.sh <output file>
# Prints the checks to run over the output file before each hand-off, then the
# lines whose sentences end on a look or voice (目だった, 顔だった, ...).
set -eu
[ $# -eq 1 ] || { echo "usage: scene-check.sh <output file>" >&2; exit 2; }
f=$1
[ -f "$f" ] || { echo "scene-check: no such file: $f" >&2; exit 1; }
cat <<'EOF'
Read the whole output file and fix each hit in place; you judge what is a hit.

- Sweep for sentences that look back — a past-time word, a replayed line of dialogue, a summary of an event the reader has already read, a comparison of the present with an earlier event, a rewording, summing-up, or explanation of the sentence before — and cut whole each one that hands the reader nothing new.
- Where narration denies one thing to set up what it then asserts, state the assertion alone; the denial stays only where the reader or the POV expected the denied thing.
- Rewrite, from what is known at that point, narration or dialogue that draws on an answer the story gives only later.
- Restore a dropped object, subject, referent, or action where the lines before it do not supply it.
- Where the same wording appears twice, keep one; an echo stays only when the source file names it.
EOF
hits=$(grep -nE '(目|顔|表情|声|口調)だった。' "$f" || true)
[ -n "$hits" ] || exit 0
cat <<'EOF'
- Bring the sentences that rest on a look or voice, listed below, within the loaded rules' limit.

EOF
printf '%s\n' "$hits"
