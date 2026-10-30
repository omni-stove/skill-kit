#!/bin/sh
# Usage: check.sh <source file> <output file> [<report file>]
# Fixes the output file's format through format.sh. With WRITE_CHECK_MODEL and
# GEMINI_API_KEY set, has that Gemini model (thinking high) list findings, in the
# shape of check-schema.json, on the line-numbered output against the style rules,
# given the source, the report, README.md and the files the source's 参照 names,
# and prints the findings whose
# text is on the line they name, with a rule and a basis, and whose quote, where
# they cite a file, is in that file; the rest are dropped. Without the model, or
# when it fails, prints the checks it covers and the narration lines ending on
# だった。 instead. Then prints the hand-off to reply with.
set -eu
[ $# -eq 2 ] || [ $# -eq 3 ] || { echo "usage: check.sh <source file> <output file> [<report file>]" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=$(local_path "$1")
f=$(local_path "$2")
report=${3:-}
[ -f "$src" ] || { echo "check: no such file: $src" >&2; exit 1; }
[ -f "$f" ] || { echo "check: no such file: $f" >&2; exit 1; }
[ -z "$report" ] || [ -f "$report" ] || { echo "check: no such file: $report" >&2; exit 1; }
format=.agents/refs/format.sh
[ -f "$format" ] || format=$(dirname -- "$0")/../../../refs/format.sh
style=.agents/refs/japanese-web-novel-style.md
[ -f "$style" ] || style=$(dirname -- "$0")/../../../refs/japanese-web-novel-style.md
sh "$format" "$f" > /dev/null
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Leaves the model's findings in $tmp/found and the kept ones in $tmp/kept;
# fails with the reason on stderr when the model gives no findings list.
check() {
  [ -n "${WRITE_CHECK_MODEL:-}" ] || { echo "WRITE_CHECK_MODEL is not set" >&2; return 1; }
  [ -n "${GEMINI_API_KEY:-}" ] || { echo "GEMINI_API_KEY is not set" >&2; return 1; }
  prompt check-system rules="$(cat "$style")" > "$tmp/sys"
  {
    printf '%s\n' "$src" "$report" README.md
    sed -n '/^## 参照/,/^## /s/^- @//p' "$src"
  } | awk 'NF && !seen[$0]++' | while IFS= read -r p; do
    [ -f "$p" ] && [ "$p" != "$f" ] && printf '%s\n' "$p"
  done > "$tmp/files"
  {
    printf '=== %s (line number, tab, line)\n' "$f"
    awk '{ print NR "\t" $0 }' "$f"
    while IFS= read -r p; do
      printf '\n=== %s\n' "$p"
      cat "$p"
    done < "$tmp/files"
  } > "$tmp/in"
  printf '%s\n' "$f" >> "$tmp/files"
  while IFS= read -r p; do
    jq -n --arg p "$p" --rawfile c "$p" '{($p): $c}'
  done < "$tmp/files" | jq -s add > "$tmp/cited"
  # Through files, not --arg: a long story would pass the exec argument limit.
  res=$(jq -n --arg model "$WRITE_CHECK_MODEL" --rawfile sys "$tmp/sys" --rawfile in "$tmp/in" \
    --slurpfile schema "$(dirname -- "$0")/check-schema.json" \
    '{model: $model, system_instruction: $sys, input: $in, generation_config: {thinking_level: "high"},
      response_format: {type: "text", mime_type: "application/json", schema: $schema[0]}}' |
    curl -sS --max-time 110 \
    -H "x-goog-api-key: $GEMINI_API_KEY" -H 'Content-Type: application/json' \
    -X POST --data-binary @- \
    https://generativelanguage.googleapis.com/v1beta/interactions 2>&1) || { printf '%s\n' "$res" >&2; return 1; }
  [ "$(printf '%s' "$res" | jq -r '.status // empty' 2>/dev/null)" = completed ] || { printf '%s\n' "$res" >&2; return 1; }
  printf '%s' "$res" | jq -r '[.steps[]? | select(.type == "model_output") | .content[]? | select(.type == "text") | .text] | join("")' |
    jq -R -s 'try (fromjson | .findings) catch null' > "$tmp/found"
  [ "$(jq -r 'type' "$tmp/found")" = array ] || { echo "no findings list in: $res" >&2; return 1; }
  jq --rawfile out "$f" --slurpfile cited "$tmp/cited" '
    ($out | split("\n")) as $lines | $cited[0] as $files
    | def str: type == "string" and . != "";
    [.[] | select(type == "object") | . as $x
      | select(($x.line | type) == "number" and $x.line == ($x.line | floor)
          and $x.line >= 1 and $x.line <= ($lines | length))
      | select(($x.text | str) and ($lines[$x.line - 1] | contains($x.text)))
      | select(($x.rule | str) and ($x.basis | str))
      | select(if $x.kind == "contradiction" or $x.file != null
          then ($x.file | str) and ($files[$x.file] != null) and ($x.quote | str) and ($files[$x.file] | contains($x.quote))
          else true end)]
    | sort_by(.line)
  ' "$tmp/found" > "$tmp/kept"
}

if check 2> "$tmp/err"; then
  prompt check-findings
  jq -r '.[] | "\(.line): \(.text) [\(.rule)] \(.basis)" + (if .file then " — \(.file):「\(.quote)」" else "" end)' "$tmp/kept"
else
  [ -z "${WRITE_CHECK_MODEL:-}" ] || echo "check: $WRITE_CHECK_MODEL failed: $(cat "$tmp/err")" >&2
  prompt checks-local
  datta=$(grep -n 'だった。' "$f" | grep -vE '^[0-9]+:[「『]' || true)
  if [ -n "$datta" ]; then
    prompt datta
    printf '%s\n' "$datta"
  fi
fi
prompt check-hand-off
