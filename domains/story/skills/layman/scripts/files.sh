#!/bin/sh
# Usage: files.sh <directory | file>
# For a directory, prints its .txt files one per line, in natural sort order —
# synopsis and dotfiles excluded. For a file, prints that file alone. Then prints the
# evaluation to run on them.
set -eu
[ $# -eq 1 ] || { echo "usage: files.sh <directory | file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
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
several=$([ "$(printf '%s\n' "$files" | grep -c .)" -gt 1 ] && echo 1 || echo 0)
cat <<'NEXT'

Evaluate each file above in that order, one at a time, judging only from the text itself,
never from project settings, character files, or world-building documents.

Stance: zero domain knowledge (medicine, aerospace, law, military, IT, etc.), high-school
common sense only. Skip anything readable without specialist knowledge, and passages
that work as atmosphere even if technically opaque. Flag only what a layman cannot
follow: specialist terms without explanation, opaque acronyms/loanwords, implicit
prerequisite knowledge, insider procedures, uncontextualized numbers/units, unexplained
industry conventions.

Per-file output:

# Layman Evaluation — <filename>

## Overall
<one line>

## Hard passages
### L<line>「<quoted passage>」
- Blocks: <reason>
- Impact: <consequence>

With nothing to flag, the heading and "No layman-blocking passages." alone.

NEXT
[ "$several" -eq 1 ] && cat <<'NEXT'
Wrap-up output after the last file:

# Overall Summary
- Hardest files: <list>
- Recurring opaque terms: <list>
- Cross-file patterns: <list>

NEXT
cat <<'NEXT'
Reply "suggest [filename]" for rewrite proposals.

Rewrite flow: "suggest [filename]" → propose rewrites as below; "approve [numbers]" → edit
the file in place, touching only the approved passages, and report the changed lines.

## Rewrite proposals — <filename>

### <n>. L<line>
Original: 「<quoted passage>」
Proposal: 「<rewritten passage>」
Reason: <justification>

Reply "approve" to apply, or "approve <numbers>" for a subset.
NEXT
