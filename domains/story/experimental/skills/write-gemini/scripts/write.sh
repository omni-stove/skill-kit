#!/bin/sh
# Usage: write.sh <plot file>
# Sends the plot file's text alone, with no system instruction, rules or references,
# to the Gemini model named by WRITE_GEMINI_MODEL (default gemini-4-neon; GEMINI_API_KEY,
# thinking high) through the Interactions API, and writes the reply to the output write
# would use with .gemini before .txt: plot/<x>.md -> ../<leading number of x, else
# x>.gemini.txt; plot.md -> index.gemini.txt beside it; another .md -> <stem>.gemini.txt
# beside it. Then prints what to tell the user.
set -eu
[ $# -eq 1 ] || { echo "usage: write.sh <plot file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../../shared/refs/prompt.sh"
f=$(local_path "$1")
[ -f "$f" ] || { echo "write-gemini: no such file: $f" >&2; exit 1; }
[ -n "${GEMINI_API_KEY:-}" ] || { echo "write-gemini: GEMINI_API_KEY is not set; ask the user to export it and run this again" >&2; exit 1; }
model=${WRITE_GEMINI_MODEL:-gemini-4-neon}
dir=$(dirname -- "$f")
stem=$(basename -- "$f")
stem=${stem%.*}
case $(basename -- "$dir") in
  plot)
    num=$(printf '%s' "$stem" | sed -n 's/^\([0-9][0-9]*\).*/\1/p')
    out="$(dirname -- "$dir")/${num:-$stem}.gemini.txt" ;;
  *)
    [ "$stem" = plot ] && stem=index
    out="$dir/$stem.gemini.txt" ;;
esac
out=${out#./}
# Through a file, not --arg: a long plot would pass the exec argument limit.
res=$(jq -n --arg model "$model" --rawfile in "$f" \
  '{model: $model, input: $in, generation_config: {thinking_level: "high"}}' |
  curl -sS --max-time 590 \
  -H "x-goog-api-key: $GEMINI_API_KEY" -H 'Content-Type: application/json' \
  -X POST --data-binary @- \
  https://generativelanguage.googleapis.com/v1beta/interactions 2>&1) || { echo "write-gemini: $model failed: $res" >&2; exit 1; }
[ "$(printf '%s' "$res" | jq -r '.status // empty' 2>/dev/null)" = completed ] || { echo "write-gemini: $model failed: $res" >&2; exit 1; }
text=$(printf '%s' "$res" | jq -r '[.steps[]? | select(.type == "model_output") | .content[]? | select(.type == "text") | .text] | join("")')
[ -n "$text" ] || { echo "write-gemini: $model returned no text: $res" >&2; exit 1; }
printf '%s\n' "$text" > "$out"
prompt written model="$model" out="$out"
