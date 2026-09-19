#!/bin/sh
# Usage: scene-check.sh
# Prints the checks to run over the output file before each hand-off.
cat <<'EOF'
Read the whole output file and fix each hit in place; you judge what is a hit.

- Sweep for sentences that look back — a past-time word, a replayed line of dialogue, a summary of an event the reader has already read, a comparison of the present with an earlier event, a rewording, summing-up, or explanation of the sentence before — and cut whole each one that hands the reader nothing new.
- Where narration denies one thing to set up what it then asserts, state the assertion alone; the denial stays only where the reader or the POV expected the denied thing.
- Rewrite, from what is known at that point, narration or dialogue that draws on an answer the story gives only later.
- Restore a dropped object, subject, referent, or action where the lines before it do not supply it.
- Where the same wording appears twice, keep one; an echo stays only when the source file names it.
EOF
