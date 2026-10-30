#!/bin/sh
# Usage: draft.sh <source file> <output file> <report file>
# Has the Gemini model named by WRITE_DRAFT_MODEL (GEMINI_API_KEY, thinking high)
# write the next Scene of the source from the loaded rules, the report and the
# output so far, and appends it to the output file after a `*` line when the file
# already has text. Prints the check to run next; on failure, says to write the
# Scene in the harness instead.
set -eu
[ $# -eq 3 ] || { echo "usage: draft.sh <source file> <output file> <report file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=$(local_path "$1")
out=$(local_path "$2")
report=$3
scene_check=$(dirname -- "$0")/scene-check.sh
fail() {
  prompt draft-failed model="${WRITE_DRAFT_MODEL:-}" error="$1" file="$src" out="$out" scene_check="$scene_check" >&2
  exit 1
}
[ -f "$src" ] || { echo "draft: no such file: $src" >&2; exit 1; }
[ -f "$report" ] || { echo "draft: no such file: $report" >&2; exit 1; }
[ -n "${WRITE_DRAFT_MODEL:-}" ] || fail "WRITE_DRAFT_MODEL is not set"
[ -n "${GEMINI_API_KEY:-}" ] || fail "GEMINI_API_KEY is not set"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
prompt draft-system rules="$(sh "$(dirname -- "$0")/../refs.sh")" > "$tmp/sys"
so_far=
[ -f "$out" ] && so_far=$(cat "$out")
printf '# Plot\n%s\n\n# Report\n%s\n\n# Written so far\n%s\n' "$(cat "$src")" "$(cat "$report")" "$so_far" > "$tmp/in"
# Through files, not --arg: a long story would pass the exec argument limit.
res=$(jq -n --arg model "$WRITE_DRAFT_MODEL" --rawfile sys "$tmp/sys" --rawfile in "$tmp/in" \
  '{model: $model, system_instruction: $sys, input: $in, generation_config: {thinking_level: "high"}}' |
  curl -sS --max-time 900 \
  -H "x-goog-api-key: $GEMINI_API_KEY" -H 'Content-Type: application/json' \
  -X POST --data-binary @- \
  https://generativelanguage.googleapis.com/v1beta/interactions 2>&1) || fail "$res"
status=$(printf '%s' "$res" | jq -r '.status // empty' 2>/dev/null) || fail "$res"
[ "$status" = completed ] || fail "$res"
text=$(printf '%s' "$res" | jq -r '[.steps[]? | select(.type == "model_output") | .content[]? | select(.type == "text") | .text] | join("")')
[ -n "$text" ] || fail "$res"
if [ -n "$so_far" ] && [ "$(printf '%s\n' "$text" | head -1)" != '*' ]; then
  printf '*\n' >> "$out"
fi
printf '%s\n' "$text" >> "$out"
prompt drafted scene_check="$scene_check" out="$out"
