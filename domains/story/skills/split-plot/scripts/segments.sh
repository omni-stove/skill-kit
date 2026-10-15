#!/bin/sh
# Usage: segments.sh <source file>
# Tries each splitter on the source — Markdown headings, horizontal rules, top-level bullet
# items, blank-line-separated blocks, explicit scene markers — and prints, per splitter,
# the number of segments it yields and the first line of each (text before the first
# heading, bullet or marker is no segment), then the step that picks one.
set -eu
[ $# -eq 1 ] || { echo "usage: segments.sh <source file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
set -- "$(local_path "$1")"
[ -f "$1" ] || { echo "segments: no such file: $1" >&2; exit 1; }

# $1 = splitter name, $2 = "start" (a matching line opens a segment) or "sep" (a matching
# line separates segments), $3 = the line pattern.
split() {
  awk -v name="$1" -v mode="$2" -v pat="$3" '
    function flush() { if (open) { n++; titles[n] = title; open = 0 } }
    {
      if ($0 ~ pat) {
        flush()
        if (mode == "start") { open = 1; title = $0; seen = 1 }
        next
      }
      if ($0 ~ /^[[:space:]]*$/) next
      if (!open && (mode == "sep" || seen)) { open = 1; title = $0 }
    }
    END {
      flush()
      printf "== %s (%d) ==\n", name, n
      for (i = 1; i <= n; i++) printf "%d\t%s\n", i, titles[i]
    }'
}
f=$1
split headings start '^##+ ' <"$f"
split rules sep '^[[:space:]]*(---+|[*][*][*]+)[[:space:]]*$' <"$f"
split bullets start '^(- |[*] |[0-9]+[.] )' <"$f"
split blocks sep '^[[:space:]]*$' <"$f"
split markers start '^(# ?シーン|【.*】|■)' <"$f"
prompt segments
