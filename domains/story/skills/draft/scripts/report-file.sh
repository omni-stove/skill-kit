#!/bin/sh
# Sourced by source.sh, finish.sh and report.sh for the paths under report/ beside the
# output file:
#   report_file <output file>          the report, report/<stem>.md
#   report_file <output file> <name>   a working file, report/.<stem>.<name>.md
report_file() {
  _d=$(dirname -- "$1")/report
  _d=${_d#./}
  _s=$(basename -- "$1" .txt)
  if [ $# -eq 2 ]; then
    printf '%s/.%s.%s.md\n' "$_d" "$_s" "$2"
  else
    printf '%s/%s.md\n' "$_d" "$_s"
  fi
}
