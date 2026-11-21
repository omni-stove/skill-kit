#!/bin/sh
# Usage: report.sh <slug> [log]
# Reads the last [Spawn] line per respawn point of docs/design/maps/<slug>.json and every
# [Respawn] line from the log (default: the engine's runtime log), and prints per point:
#   ok|fail <id> enemy_time=<s> seen_by=<ids> respawns=<n> spawn_kills=<n>
# with fail where enemy_time is under the spawn file's min_enemy_time or any spawn sees it,
# or "missing <id>" for a point with no [Spawn] line; then the step that fixes, plays or weighs.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "report: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -ge 1 ] && [ $# -le 2 ] || { echo "usage: report.sh <slug> [log]" >&2; exit 2; }
self=$(dirname -- "$0")
layout="docs/design/maps/$1.json"
file="docs/design/spawns/$1.json"
log=${2:-$(runtime_log)}
[ -f "$layout" ] || { echo "report: $layout not found — lay the map out first." >&2; exit 1; }
[ -f "$file" ] || { echo "report: $file not found — run $self/spawns.sh $1 first." >&2; exit 1; }
[ -f "$log" ] || { echo "report: log $log not found — build the greybox, then pass the file its log went to." >&2; exit 1; }
ids=$(jq -r '[.spawns[]? | select(.use == "respawn") | .id // empty] | join(" ")' "$layout")
[ -n "$ids" ] || { echo "report: $layout has no spawn with use respawn and an id — place the respawn points first." >&2; exit 1; }
min=$(jq -r '.min_enemy_time // empty' "$file")
kill=$(jq -r '.spawn_kill // empty' "$file")
[ -n "$min" ] && [ -n "$kill" ] || { echo "report: $file needs min_enemy_time and spawn_kill — set them, then rerun." >&2; exit 1; }

status=0
grep -E '\[(Spawn|Respawn)\] ' "$log" | awk -v ids="$ids" -v min="$min" -v kill="$kill" '
BEGIN { n = split(ids, a, " "); for (i = 1; i <= n; i++) want[a[i]] = 1 }
{
  i = index($0, "[Spawn] "); if (!i) i = index($0, "[Respawn] ")
  $0 = substr($0, i)
  if (!($2 in want)) next
  for (f = 3; f <= NF; f++) {
    split($f, kv, "=")
    if ($1 == "[Spawn]" && kv[1] == "enemy_time") t[$2] = kv[2]
    if ($1 == "[Spawn]" && kv[1] == "seen_by") s[$2] = kv[2]
    if ($1 == "[Respawn]" && kv[1] == "died_after") { r[$2]++; if (kv[2] + 0 < kill + 0) k[$2]++ }
  }
  if ($1 == "[Spawn]") seen[$2] = 1
}
END {
  for (i = 1; i <= n; i++) {
    id = a[i]
    if (!(id in seen)) { print "missing\t" id; bad = 1; continue }
    st = (t[id] + 0 < min + 0 || s[id] != "-") ? "fail" : "ok"
    if (st == "fail") bad = 1
    printf "%s\t%s\tenemy_time=%s\tseen_by=%s\trespawns=%d\tspawn_kills=%d\n", st, id, t[id], s[id], r[id], k[id]
  }
  exit bad
}' || status=$?
[ "$status" -le 1 ] || exit "$status"

if [ "$status" -eq 1 ]; then
  prompt fix layout="$layout" self="$self" slug="$1"
elif grep -q '\[Respawn\] ' "$log"; then
  prompt weigh layout="$layout" spawns="$file" self="$self" slug="$1"
else
  prompt select spawns="$file" source_root="$(source_root)" self="$self" slug="$1"
  case $(control_mcp) in
    *computer*) prompt play-gui ctrl="$(control_mcp)" self="$self" slug="$1" ;;
    *) prompt play-log self="$self" slug="$1" ;;
  esac
fi
