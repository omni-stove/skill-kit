#!/bin/sh
# Usage: report.sh <slug> [log]
# Reads the last [Objective] line per objective of docs/design/maps/<slug>.json and every [Take]
# line from the log (default: the engine's runtime log), and prints per objective:
#   ok|fail <id> <team>=<s>... gap=<s> rotate=<s> takes=<team>:<n>,...
# where gap is how much sooner the defending team arrives than the next team, or for a contested
# objective how far apart the teams arrive; fail where gap is under the objective file's lead or
# over its even, or where a team cannot reach it. Prints "missing <id>" for an objective with no
# [Objective] line, then the step that fixes, plays or weighs.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "report: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -ge 1 ] && [ $# -le 2 ] || { echo "usage: report.sh <slug> [log]" >&2; exit 2; }
self=$(dirname -- "$0")
layout="docs/design/maps/$1.json"
file="docs/design/objectives/$1.json"
log=${2:-$(runtime_log)}
[ -f "$layout" ] || { echo "report: $layout not found — lay the map out first." >&2; exit 1; }
[ -f "$file" ] || { echo "report: $file not found — run $self/objectives.sh $1 first." >&2; exit 1; }
[ -f "$log" ] || { echo "report: log $log not found — build the greybox, then pass the file its log went to." >&2; exit 1; }
os=$(jq -r '[.objectives[]? | select(.id) | "\(.id):\(.team // "")"] | join(" ")' "$layout")
[ -n "$os" ] || { echo "report: $layout has no objective with an id — place the objectives first." >&2; exit 1; }
lead=$(jq -r '.lead // empty' "$file")
even=$(jq -r '.even // empty' "$file")
[ -n "$lead" ] && [ -n "$even" ] || { echo "report: $file needs lead and even — set them, then rerun." >&2; exit 1; }

status=0
grep -E '\[(Objective|Take)\] ' "$log" | awk -v os="$os" -v lead="$lead" -v even="$even" '
BEGIN { n = split(os, a, " "); for (i = 1; i <= n; i++) { c = index(a[i], ":"); id[i] = substr(a[i], 1, c - 1); def[id[i]] = substr(a[i], c + 1); want[id[i]] = 1 } }
{
  i = index($0, "[Objective] "); if (!i) i = index($0, "[Take] ")
  $0 = substr($0, i)
  if (!($2 in want)) next
  if ($1 == "[Take]") {
    for (f = 3; f <= NF; f++) { split($f, kv, "="); if (kv[1] == "team") { tk[$2, kv[2]]++; if (!((kv[2]) in seenteam)) { seenteam[kv[2]] = 1; teams[++nt] = kv[2] } } }
    next
  }
  seen[$2] = 1; times[$2] = ""; rot[$2] = "-"
  for (f = 3; f <= NF; f++) {
    split($f, kv, "=")
    if (kv[1] == "rotate") rot[$2] = kv[2]
    else times[$2] = times[$2] " " kv[1] "=" kv[2]
  }
}
END {
  for (i = 1; i <= n; i++) {
    o = id[i]
    if (!(o in seen)) { print "missing\t" o; bad = 1; continue }
    m = split(substr(times[o], 2), tv, " "); cut = 0; own = ""; lo = ""; hi = ""; other = ""; out = ""
    for (j = 1; j <= m; j++) {
      split(tv[j], kv, "="); t = kv[2] + 0; out = out "\t" tv[j]
      if (kv[2] == "-") cut = 1
      if (kv[1] == def[o]) own = t
      else if (other == "" || t < other) other = t
      if (lo == "" || t < lo) lo = t
      if (hi == "" || t > hi) hi = t
    }
    if (def[o] != "") { gap = (own == "" || other == "") ? 0 : other - own; st = gap < lead + 0 ? "fail" : "ok" }
    else { gap = hi - lo; st = gap > even + 0 ? "fail" : "ok" }
    if (cut) st = "fail"
    if (st == "fail") bad = 1
    tks = ""
    for (j = 1; j <= nt; j++) tks = tks (tks == "" ? "" : ",") teams[j] ":" (tk[o, teams[j]] + 0)
    printf "%s\t%s%s\tgap=%s\trotate=%s\ttakes=%s\n", st, o, out, gap, rot[o], (tks == "" ? "-" : tks)
  }
  exit bad
}' || status=$?
[ "$status" -le 1 ] || exit "$status"

if [ "$status" -eq 1 ]; then
  prompt fix layout="$layout" self="$self" slug="$1"
elif grep -q '\[Take\] ' "$log"; then
  prompt weigh layout="$layout" self="$self" slug="$1"
else
  prompt match source_root="$(source_root)"
  case $(control_mcp) in
    *computer*) prompt play-gui ctrl="$(control_mcp)" self="$self" slug="$1" ;;
    *) prompt play-log self="$self" slug="$1" ;;
  esac
fi
