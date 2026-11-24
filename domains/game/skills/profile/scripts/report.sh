#!/bin/sh
# Usage: report.sh <slug> [log]
# Reads the last [Perf] line of <slug> per section of docs/design/maps/<slug>.json from the log
# (default: the engine's runtime log), and prints per section, by piece id prefix:
#   ok|over <section> <measure>=<value>...
# with over where a measure passes its max in docs/design/perf.json, or "missing <section>" for a
# section with no line; then the step that fixes the section furthest over, or the done step.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "report: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -ge 1 ] && [ $# -le 2 ] || { echo "usage: report.sh <slug> [log]" >&2; exit 2; }
self=$(dirname -- "$0")
layout="docs/design/maps/$1.json"
budget=docs/design/perf.json
log=${2:-$(runtime_log)}
[ -f "$layout" ] || { echo "report: $layout not found — lay the map out first." >&2; exit 1; }
[ -f "$budget" ] || { echo "report: $budget not found — run $self/profile.sh $1 and write the budget first." >&2; exit 1; }
[ -f "$log" ] || { echo "report: log $log not found — run the sampler, then pass the file its log went to." >&2; exit 1; }
secs=$(jq -r '[.pieces[]? | .id // "" | tostring | split("-")[0] | select(. != "")] | unique | join(" ")' "$layout")
max=$(jq -r '(.max // {}) | to_entries | map(select(.value | type == "number") | "\(.key)=\(.value)") | join(" ")' "$budget")
[ -n "$max" ] || { echo "report: $budget has no number under max — set the budget, then rerun." >&2; exit 1; }

status=0
rows=$(grep -E "\[Perf\] $1 " "$log" | awk -v secs="$secs" -v max="$max" '
BEGIN {
  n = split(secs, s, " "); for (i = 1; i <= n; i++) want[s[i]] = 1
  m = split(max, mv, " "); for (i = 1; i <= m; i++) { split(mv[i], kv, "="); lim[kv[1]] = kv[2] + 0 }
}
{
  $0 = substr($0, index($0, "[Perf] "))
  if (!($3 in want)) next
  line[$3] = ""; worst[$3] = 0; st[$3] = "ok"
  for (f = 4; f <= NF; f++) {
    split($f, kv, "="); line[$3] = line[$3] "\t" $f
    if ((kv[1] in lim) && lim[kv[1]] > 0 && kv[2] + 0 > lim[kv[1]]) { st[$3] = "over"; r = kv[2] / lim[kv[1]]; if (r > worst[$3]) worst[$3] = r }
  }
}
END {
  for (i = 1; i <= n; i++) {
    id = s[i]
    if (!(id in st)) { print "missing\t" id; miss = 1; continue }
    printf "%s\t%s%s\n", st[id], id, line[id]
    if (st[id] == "over" && worst[id] > top) { top = worst[id]; topid = id }
  }
  if (topid != "") { print "worst\t" topid; exit 1 }
  exit miss ? 1 : 0
}') || status=$?
[ "$status" -le 1 ] || exit "$status"
printf '%s\n' "$rows" | grep -v '^worst	' || true
worst=$(printf '%s\n' "$rows" | sed -n 's/^worst	//p')

if [ "$status" -eq 0 ]; then
  prompt within
elif [ -z "$worst" ]; then
  prompt missing self="$self" slug="$1"
else
  case $(control_mcp) in
    *computer*) prompt fix-gui ctrl="$(control_mcp)" section="$worst" self="$self" slug="$1" ;;
    *) prompt fix-log section="$worst" self="$self" slug="$1" ;;
  esac
fi
