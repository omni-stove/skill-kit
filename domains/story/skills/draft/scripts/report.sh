#!/bin/sh
# Usage: report.sh <plot file> <output file>
# Builds report/<stem>.md beside the output from the saved notes, with a Short line when
# the output is under the plot's ## Length. Removes the working files, then prints the
# report's path, any Short line, and the step to reply with them.
set -eu
[ $# -eq 2 ] || { echo "usage: report.sh <plot file> <output file>" >&2; exit 2; }
. "$(dirname -- "$0")/../../../refs/local-path.sh"
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
. "$(dirname -- "$0")/report-file.sh"
f=$(local_path "$1")
out=$(local_path "$2")
[ -f "$f" ] || { echo "report: no such file: $f" >&2; exit 1; }
[ -f "$out" ] || { echo "report: no such file: $out; save the draft there and run this again" >&2; exit 1; }
notes=$(report_file "$out" notes)
[ -s "$notes" ] || { echo "report: the notes $notes are missing or empty; save them there and run this again" >&2; exit 1; }
report=$(report_file "$out")
short=$(sh "$(dirname -- "$0")/../../../refs/length.sh" "$f" "$out")
{
  printf '# Draft report: %s (%s)\n\n' "$out" "$f"
  [ -z "$short" ] || printf 'Short: %s\n\n' "$short"
  cat "$notes"
} > "$report"
rm -f "$(report_file "$out" check)" "$notes"
printf 'Report: %s\n' "$report"
[ -z "$short" ] || printf 'Short: %s\n' "$short"
prompt reply
