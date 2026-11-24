#!/bin/sh
# Usage: heat.sh <slug> [log...]
# Reads the [Play] lines of the logs (default: the engine's runtime log) and draws them over the
# top view of docs/design/maps/<slug>.json as docs/design/playtests/<slug>.svg: deaths, hits and
# stuck points, each death and hit with a line from where it came from. Prints per section, by
# the id prefix of the piece under the point, then for points over no piece as "-":
#   <section> <beat name> deaths=<n> hits=<n> stuck=<n>
# then the SVG path and the weigh step.
set -eu
[ -f .agents/refs/engine.sh ] || { echo "heat: .agents/refs/engine.sh not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit game sync\`, then stop." >&2; exit 1; }
. .agents/refs/engine.sh
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -ge 1 ] || { echo "usage: heat.sh <slug> [log...]" >&2; exit 2; }
command -v jq >/dev/null || { echo "heat: jq not found — install jq, then rerun." >&2; exit 1; }
slug=$1
shift
[ $# -gt 0 ] || set -- "$(runtime_log)"
layout="docs/design/maps/$slug.json"
out="docs/design/playtests/$slug.svg"
[ -f "$layout" ] || { echo "heat: $layout not found — lay the map out first." >&2; exit 1; }
for f in "$@"; do [ -f "$f" ] || { echo "heat: log $f not found — pass the files the playtests logged to." >&2; exit 1; }; done
events=$(grep -hE '\[Play\] (death|hit|stuck) ' "$@" | sed 's/.*\[Play\] //' | awk '
{
  split($2, p, ","); f = "null"
  for (i = 3; i <= NF; i++) if (substr($i, 1, 5) == "from=") { split(substr($i, 6), q, ","); f = "[" q[1] + 0 "," q[2] + 0 "," q[3] + 0 "]" }
  printf "{\"kind\":\"%s\",\"pos\":[%s,%s,%s],\"from\":%s}\n", $1, p[1] + 0, p[2] + 0, p[3] + 0, f
}' | jq -s .)
[ "$(printf '%s' "$events" | jq length)" -gt 0 ] || { echo "heat: no [Play] lines in $* — make the game log them and play first." >&2; exit 1; }
mkdir -p docs/design/playtests

common='
def rad: (. // 0) * 3.141592653589793 / 180;
def abs: if . < 0 then -. else . end;
def under($p): ((.yaw | rad) as $t | ($p[0] - .pos[0]) as $dx | ($p[2] - .pos[2]) as $dz
  | ($dx * ($t | cos) - $dz * ($t | sin)) as $a | ($dx * ($t | sin) + $dz * ($t | cos)) as $b
  | ($a | abs) <= .size[0] / 2 + 0.01 and ($b | abs) <= .size[2] / 2 + 0.01
    and $p[1] >= .pos[1] - 0.5 and $p[1] <= .pos[1] + .size[1] + 0.5);
[.pieces[]? | select((.pos | length) == 3 and (.size | length) == 3)] as $pieces
| def section($p): [$pieces[] | select(under($p)) | .id // "" | tostring | split("-")[0]] | first // "-";
'

jq -r --argjson ev "$events" "$common"'
(.beats // []) as $beats
| [$ev[] | . + {sec: section(.pos)}] | group_by(.sec) | sort_by(.[0].sec == "-") | .[]
| .[0].sec as $s
| "\($s)\t\([$beats[] | select(.id == $s) | .name // ""] | first // "")\tdeaths=\([.[] | select(.kind == "death")] | length)\thits=\([.[] | select(.kind == "hit")] | length)\tstuck=\([.[] | select(.kind == "stuck")] | length)"
' "$layout"

jq -r --argjson ev "$events" "$common"'
def r2: (. * 100 | round) / 100 | tostring;
def esc: tostring | gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub("\""; "&quot;");
def pts: map("\(.[0] | r2),\(.[1] | r2)") | join(" ");
def color: {floor: "#e4e0d6", wall: "#6e6e6e", cover: "#c4884a", ramp: "#b6d3b3", stairs: "#b3c8de"}[.] // "#cccccc";
def fp: (.yaw | rad) as $t | ($t | sin) as $s | ($t | cos) as $c | . as $p
  | [[-1, -1], [1, -1], [1, 1], [-1, 1]]
  | map([$p.pos[0] + .[0] * $p.size[0] / 2 * $c + .[1] * $p.size[2] / 2 * $s, $p.pos[2] - .[0] * $p.size[0] / 2 * $s + .[1] * $p.size[2] / 2 * $c]);
def mark: {death: "#d22", hit: "#e80", stuck: "#26c"}[.];

[$pieces[] | . + {fp: fp}] as $ps
| ([$ps[].fp[][0]] + [$ev[].pos[0]]) as $xs | ([$ps[].fp[][1]] + [$ev[].pos[2]]) as $zs
| ($xs | min) as $x0 | ($xs | max) as $x1 | ($zs | min) as $z0 | ($zs | max) as $z1
| ([$x1 - $x0, $z1 - $z0, 1] | max) as $span | (800 / $span) as $S
| 40 as $m | 24 as $tt
| (($x1 - $x0) * $S) as $w | (($z1 - $z0) * $S) as $d
| ($m + $w + $m) as $W | ($m + $tt + $d + $m + 20) as $H
| def tx($x): ($x - $x0) * $S; def tz($z): ($z1 - $z) * $S;
  [(.beats // [])[] | (.id // "" | tostring) as $b | [$ps[] | select((.id // "" | tostring | split("-")[0]) == $b) | .fp[]] as $f | select($f | length > 0)
   | {label: ($b + " " + (.name // "" | tostring) | esc), x: ([$f[][0]] | (min + max) / 2), z: ([$f[][1]] | (min + max) / 2)}] as $bt

| "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\($W | r2)\" height=\"\($H | r2)\" viewBox=\"0 0 \($W | r2) \($H | r2)\" font-family=\"sans-serif\">"
  + "<style>.t{font-size:13px;font-weight:bold}.f{fill:none;stroke:#999}.lg{font-size:11px}.bt{font-size:13px;font-weight:bold;fill:#225;text-anchor:middle;paint-order:stroke;stroke:#fff;stroke-width:3}</style>"
  + "<rect width=\"100%\" height=\"100%\" fill=\"#fff\"/>"
  + "<g transform=\"translate(\($m),\($m + $tt))\"><text x=\"0\" y=\"-8\" class=\"t\">playtest (top, +z up, \($ev | length) events)</text><rect x=\"0\" y=\"0\" width=\"\($w | r2)\" height=\"\($d | r2)\" class=\"f\"/>"
  + ($ps | sort_by(.pos[1] + .size[1]) | map("<polygon points=\"\(.fp | map([tx(.[0]), tz(.[1])]) | pts)\" fill=\"\(.kind | color)\" stroke=\"#999\" stroke-width=\"0.5\"><title>\(.id // "" | esc) (\(.kind // "" | esc))</title></polygon>") | join(""))
  + ($ev | map(select(.from != null) | "<line x1=\"\(tx(.from[0]) | r2)\" y1=\"\(tz(.from[2]) | r2)\" x2=\"\(tx(.pos[0]) | r2)\" y2=\"\(tz(.pos[2]) | r2)\" stroke=\"\(.kind | mark)\" stroke-opacity=\"0.35\" stroke-width=\"1\"/>") | join(""))
  + ($ev | sort_by(.kind != "hit") | map("<circle cx=\"\(tx(.pos[0]) | r2)\" cy=\"\(tz(.pos[2]) | r2)\" r=\"\(if .kind == "hit" then 4 else 6 end)\" fill=\"\(.kind | mark)\" fill-opacity=\"\(if .kind == "hit" then 0.3 else 0.6 end)\"><title>\(.kind) \(.pos | tostring)\(if .from then " from " + (.from | tostring) else "" end)</title></circle>") | join(""))
  + ($bt | map("<text x=\"\(tx(.x) | r2)\" y=\"\(tz(.z) | r2)\" class=\"bt\">\(.label)</text>") | join(""))
  + "</g>"
  + "<g transform=\"translate(\($m),\($H - 14 | r2))\">"
  + ([["death", "hit", "stuck"] | to_entries[] | "<circle cx=\"\(.key * 70 + 5)\" cy=\"-4\" r=\"5\" fill=\"\(.value | mark)\" fill-opacity=\"0.6\"/><text x=\"\(.key * 70 + 14)\" y=\"0\" class=\"lg\">\(.value)</text>"] | join(""))
  + "<line x1=\"215\" x2=\"240\" y1=\"-4\" y2=\"-4\" stroke=\"#d22\" stroke-opacity=\"0.5\"/><text x=\"244\" y=\"0\" class=\"lg\">from</text></g>"
  + "</svg>"
' "$layout" > "$out"

printf 'svg\t%s\n' "$out"
prompt weigh svg="$out" layout="$layout" self="$(dirname -- "$0")" slug="$slug"
