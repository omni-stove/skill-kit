#!/bin/sh
# Usage: plot-skeleton.sh <file> --body <text> --length <text> [--intent <text>]
#                         [--prohibited <text>] [--highlights <text>] [--references <text>]
# Writes the plot file from the text given, replacing what is there and creating its
# directory; every heading is always written. --length is one line like 12000字 or
# 3000 words. Text holding a line that starts with `## ` is refused, so only this script
# writes headings. No option sets ## Dialogue: it is empty in a new file and keeps what
# the author wrote in an existing one.
set -eu
usage() {
  echo "usage: plot-skeleton.sh <file> --body <text> --length <text> [--intent <text>] [--prohibited <text>] [--highlights <text>] [--references <text>]" >&2
  exit 2
}
[ $# -ge 1 ] || usage
f=$1; shift
body=''
intent=''
length=''
prohibited=''
highlights=''
references=''
dialogue=''
while [ $# -gt 0 ]; do
  [ $# -ge 2 ] || usage
  case $1 in
    --body) body=$2 ;;
    --intent) intent=$2 ;;
    --length) length=$2 ;;
    --prohibited) prohibited=$2 ;;
    --highlights) highlights=$2 ;;
    --references) references=$2 ;;
    *) usage ;;
  esac
  shift 2
done
[ -n "$body" ] && [ -n "$length" ] || {
  echo "plot-skeleton: give the plot body with --body and the whole plot's length with --length" >&2
  exit 2
}
printf '%s\n' "$length" | awk 'NR > 1 || !/^[0-9]+ *(字|words?) *$/ { exit 1 }' || {
  echo "plot-skeleton: give --length as one line like 12000字 or 3000 words, not: $length" >&2
  exit 2
}
for text in "$body" "$intent" "$length" "$prohibited" "$highlights" "$references"; do
  if printf '%s\n' "$text" | grep -q '^## '; then
    echo "plot-skeleton: remove the lines starting with '## ' from the text; this script writes the headings" >&2
    exit 2
  fi
done
if [ -f "$f" ]; then
  dialogue=$(awk '/^## / { on = ($0 == "## Dialogue"); next } on' "$f")
fi
section() {
  printf '\n## %s\n' "$1"
  [ -z "$2" ] || printf '%s\n' "$2"
}
mkdir -p "$(dirname -- "$f")"
{
  [ -z "$body" ] || printf '%s\n' "$body"
  section Intent "$intent"
  section Length "$length"
  section Prohibited "$prohibited"
  section Highlights "$highlights"
  section Dialogue "$dialogue"
  section References "$references"
} > "$f"
