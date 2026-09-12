#!/bin/sh
# Usage: source.sh <project-id> <plot title | plot/<title>.md | <chapter>.md | file path>
# Prints the resolved source path as a `Source:` line, the output file the
# source is written to (<story dir>/<leading number of the source filename>.txt,
# the whole stem when it has no leading number), and the action to take on
# that output — read it and ask whether to resume when it already exists.
set -eu
[ $# -eq 2 ] || { echo "usage: source.sh <project-id> <source>" >&2; exit 2; }
pid=$1
given=$2
if [ -f "$given" ]; then src=$given
else
  name=$(basename -- "$given" .md)
  case $given in
    plot/*) src=$(.agents/refs/path "$pid" story_plot_file "$name") ;;
    *.md)   src=$(.agents/refs/path "$pid" story_body_file "$name") ;;
    *)      src=$(.agents/refs/path "$pid" story_plot_file "$name") ;;
  esac
fi
[ -f "$src" ] || { echo "source: no such file: $src" >&2; exit 1; }
stem=$(basename -- "$src")
stem=${stem%.*}
num=$(printf '%s' "$stem" | sed -n 's/^\([0-9][0-9]*\).*/\1/p')
out="$(.agents/refs/path "$pid" story)/${num:-$stem}.txt"
echo "Source: $src"
echo "Output: $out"
if [ -f "$out" ]; then
  echo "The output file exists. Read it, ask \"Continue from where you left off, or start over?\", and wait for the response."
else
  echo "The output file does not exist yet. Start from the first Scene."
fi
