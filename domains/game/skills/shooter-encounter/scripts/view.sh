#!/bin/sh
# Usage: view.sh <slug>
# Draws docs/design/encounters/<slug>.json over the top view of docs/design/maps/<slug>.json as
# docs/design/encounters/<slug>.svg: each encounter's trigger, entry, exit and intensity, each
# enemy's spawn, hold and range numbered by wave, a melee enemy as an arrow from its spawn to
# where it meets the player, and the route between encounters, with a pacing chart of each
# encounter's intensity and its ranged and melee enemies in route order. Prints a warn line per
# unknown enemy type, missing trigger, spawn or hold over no floor, ramp or stairs, missing
# surround for melee enemies, wave whose melee holds crowd past the surround, encounter without
# an intensity, and last encounter that is not the hardest, then the SVG path and the review step.
# Colours and legend labels come from docs/design/map-style.json, kept by map-style.sh.
set -eu
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
[ $# -eq 1 ] || { echo "usage: view.sh <slug>" >&2; exit 2; }
command -v jq >/dev/null || { echo "view: jq not found — install jq, then rerun." >&2; exit 1; }
layout="docs/design/maps/$1.json"
in="docs/design/encounters/$1.json"
out="docs/design/encounters/$1.svg"
[ -f "$layout" ] || { echo "view: $layout not found — lay the map out first." >&2; exit 1; }
[ -f "$in" ] || { echo "view: $in not found — write the encounter file first." >&2; exit 1; }
jq -e '(.encounters | type == "array" and length > 0) and all(.encounters[]; (.entry | length) == 3 and (.exit | length) == 3 and all(.waves[]?.enemies[]?; (.pos | length) == 3 and (.hold | length) == 3))' "$in" >/dev/null \
  || { echo "view: $in needs a non-empty encounters array, each with entry and exit [x, y, z] and each enemy with pos and hold [x, y, z] — fix it, then rerun." >&2; exit 1; }

common='
def rad: (. // 0) * 3.141592653589793 / 180;
def abs: if . < 0 then -. else . end;
def walkable: .kind == "floor" or .kind == "ramp" or .kind == "stairs";
# Undoes the clockwise yaw so the point can be tested against the unrotated box.
def over($p): ((.yaw | rad) as $t | ($p[0] - .pos[0]) as $dx | ($p[2] - .pos[2]) as $dz
  | ($dx * ($t | cos) - $dz * ($t | sin)) as $a | ($dx * ($t | sin) + $dz * ($t | cos)) as $b
  | ($a | abs) <= .size[0] / 2 + 0.01 and ($b | abs) <= .size[2] / 2 + 0.01
    and $p[1] >= .pos[1] - 0.01 and $p[1] <= .pos[1] + .size[1] + 0.01);
($layout[0].pieces // []) as $pieces
| def grounded($p): any($pieces[] | select(walkable); over($p));
  def melee($types): $types[.type].attack == "melee";
'

jq -r --slurpfile layout "$layout" "$common"'
(.enemies // {}) as $types
| .surround as $sr
| (if $sr == null and any(.encounters[].waves[]?.enemies[]?; melee($types)) then "warn\t-\tno surround for the melee enemies" else empty end),
  ([.encounters[] | .intensity | numbers] as $is | .encounters[-1] as $l
   | if ($l.intensity | type) == "number" and ($is | max) > $l.intensity then "warn\t\($l.id)\tthe last encounter is not the hardest (intensity \($l.intensity) of \($is | max))" else empty end),
  (.encounters[] | select((.intensity | type) != "number") | "warn\t\(.id)\tno intensity"),
  (.encounters[] | .id as $e
| (if .trigger == null then "warn\t\($e)\tno trigger" else empty end),
  (.waves // [] | to_entries[] | (.key + 1) as $w | .value.enemies[]?
    | (if $types[.type] == null then "warn\t\($e) wave \($w)\ttype \(.type) is not in enemies" else empty end),
      (if grounded(.pos) then empty else "warn\t\($e) wave \($w)\t\(.type) pos \(.pos | tostring) is over no floor, ramp or stairs" end),
      (if grounded(.hold) then empty else "warn\t\($e) wave \($w)\t\(.type) hold \(.hold | tostring) is over no floor, ramp or stairs" end)),
  (if $sr == null then empty else .waves // [] | to_entries[] | (.key + 1) as $w
    | [.value.enemies[]? | select(melee($types)) | .hold] as $hs
    | ([$hs[] | . as $a | {at: $a, n: [$hs[] | select(((.[0] - $a[0]) * (.[0] - $a[0]) + (.[2] - $a[2]) * (.[2] - $a[2])) <= $sr.radius * $sr.radius)] | length}] | max_by(.n)) as $c
    | if $c != null and $c.n > $sr.enemies then "warn\t\($e) wave \($w)\t\($c.n) melee enemies within \($sr.radius) m of \($c.at | tostring), over surround \($sr.enemies)" else empty end end))
' "$in"

refs="$(dirname -- "$0")/../../../refs"
style=$(sh "$refs/map-style.sh" "$layout")
jq -r -L "$refs" --slurpfile st "$style" --slurpfile layout "$layout" 'include "map-style";'"$common"'
def pts: map("\(.[0] | r2),\(.[1] | r2)") | join(" ");
def color: col("pieces"; .);
def fp: (.yaw | rad) as $t | ($t | sin) as $s | ($t | cos) as $c | . as $p
  | [[-1, -1], [1, -1], [1, 1], [-1, 1]]
  | map([$p.pos[0] + .[0] * $p.size[0] / 2 * $c + .[1] * $p.size[2] / 2 * $s, $p.pos[2] - .[0] * $p.size[0] / 2 * $s + .[1] * $p.size[2] / 2 * $c]);

(.enemies // {}) as $types
| [$pieces[] | select((.pos | length) == 3 and (.size | length) == 3) | . + {fp: fp}] as $ps
| .encounters as $es
| ([$es[] | .entry, .exit, (.waves[]?.enemies[]? | .pos, .hold)]
   + [$es[] | .trigger | select(. != null) | [.pos[0] - .size[0] / 2, 0, .pos[2] - .size[2] / 2], [.pos[0] + .size[0] / 2, 0, .pos[2] + .size[2] / 2]]) as $pts
| ([$ps[].fp[][0]] + [$pts[][0]]) as $xs | ([$ps[].fp[][1]] + [$pts[][2]]) as $zs
| ($xs | min) as $x0 | ($xs | max) as $x1 | ($zs | min) as $z0 | ($zs | max) as $z1
| ([$x1 - $x0, $z1 - $z0, 1] | max) as $span | (800 / $span) as $S
| 40 as $m | 24 as $tt
| (($x1 - $x0) * $S) as $w | (($z1 - $z0) * $S) as $d
| ($m + $tt + $d + $m + $tt) as $cy | 110 as $ch
| ($es | length) as $n | ([$es[] | [.waves[]?.enemies[]?] | length] + [1] | max) as $nmax
| ([$w, $n * 90] | max) as $cw | ($m + $cw + $m) as $W
| col("teams"; "enemy") as $en | col("teams"; "player") as $pl | col("marks"; "trigger") as $tg
| ([{sw: "<rect x=\"0\" y=\"-10\" width=\"11\" height=\"11\" fill=\"\($en)\"/><text x=\"5.5\" y=\"-1.5\" class=\"wn\">1</text>", label: (lab("teams"; "enemy") + " spawn, by wave")},
    {sw: "<circle cx=\"5\" cy=\"-4\" r=\"5\" fill=\"#fff\" stroke=\"\($en)\" stroke-width=\"2\"/>", label: "hold"},
    {sw: "<line x1=\"0\" x2=\"12\" y1=\"-4\" y2=\"-4\" stroke=\"\($en)\" stroke-width=\"2\"/>", label: "melee: where it meets the player"},
    {sw: "<circle cx=\"5\" cy=\"-4\" r=\"5\" fill=\"\($pl)\"/>", label: (lab("teams"; "player") + " entry")},
    {sw: "<circle cx=\"5\" cy=\"-4\" r=\"5\" fill=\"#fff\" stroke=\"\($pl)\" stroke-width=\"2.5\"/>", label: (lab("teams"; "player") + " exit")},
    {sw: "<line x1=\"0\" x2=\"12\" y1=\"-4\" y2=\"-4\" class=\"rt\"/>", label: "route"},
    {sw: "<rect x=\"0\" y=\"-9\" width=\"12\" height=\"10\" class=\"tr\"/>", label: lab("marks"; "trigger")},
    {sw: sw_area(col("marks"; "intensity")), label: lab("marks"; "intensity")},
    {sw: "<rect x=\"0\" y=\"-9\" width=\"10\" height=\"10\" fill=\"\($en)\" fill-opacity=\"0.45\"/>", label: "ranged"},
    {sw: sw_area($en), label: "melee"}]
   + [$ps | map(.kind // "" | tostring) | unique[] | select(. != "") | {sw: sw_area(col("pieces"; .)), label: lab("pieces"; .)}]
   | legend($W - 2 * $m)) as $lg
| ($cy + $ch + 40 + $lg.h) as $H
| def tx($x): ($x - $x0) * $S; def tz($z): ($z1 - $z) * $S;
  def at($p): "cx=\"\(tx($p[0]) | r2)\" cy=\"\(tz($p[2]) | r2)\"";

  "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\($W | r2)\" height=\"\($H | r2)\" viewBox=\"0 0 \($W | r2) \($H | r2)\" font-family=\"sans-serif\">"
  + "<style>.t{font-size:13px;font-weight:bold}.f{fill:none;stroke:#999}.tr{fill:\($tg);fill-opacity:0.12;stroke:\($tg);stroke-dasharray:5 3}.rt{stroke:\($pl);stroke-width:2;stroke-dasharray:2 4;fill:none}.ee{stroke:\($pl);stroke-width:2.5}.lb{font-size:12px;font-weight:bold;fill:\($pl);paint-order:stroke;stroke:#fff;stroke-width:3}.lg{font-size:11px}.wn{font-size:8px;font-weight:bold;fill:#fff;text-anchor:middle;pointer-events:none}.hn{font-size:7px;font-weight:bold;text-anchor:middle;pointer-events:none}</style>"
  + "<defs><marker id=\"m\" viewBox=\"0 0 10 10\" refX=\"16\" refY=\"5\" markerWidth=\"5\" markerHeight=\"5\" orient=\"auto\"><path d=\"M0,0L10,5L0,10z\" fill=\"\($en)\"/></marker></defs>"
  + "<rect width=\"100%\" height=\"100%\" fill=\"#fff\"/>"
  + "<g transform=\"translate(\($m),\($m + $tt))\"><text x=\"0\" y=\"-8\" class=\"t\">encounters (top, +z up)</text><rect x=\"0\" y=\"0\" width=\"\($w | r2)\" height=\"\($d | r2)\" class=\"f\"/>"
  + "<clipPath id=\"c\"><rect x=\"0\" y=\"0\" width=\"\($w | r2)\" height=\"\($d | r2)\"/></clipPath>"
  + ($ps | sort_by(.pos[1] + .size[1]) | map("<polygon points=\"\(.fp | map([tx(.[0]), tz(.[1])]) | pts)\" fill=\"\(.kind | color)\" fill-opacity=\"0.45\" stroke=\"#999\" stroke-width=\"0.5\"><title>\(.id // "" | esc) (\(.kind // "" | esc))</title></polygon>") | join(""))
  + ([range(0; ($es | length) - 1) as $i | $es[$i].exit as $a | $es[$i + 1].entry as $b
      | "<line x1=\"\(tx($a[0]) | r2)\" y1=\"\(tz($a[2]) | r2)\" x2=\"\(tx($b[0]) | r2)\" y2=\"\(tz($b[2]) | r2)\" class=\"rt\"/>"] | join(""))
  + ($es | map(
      (.id // "" | esc) as $e
      | (if .trigger then .trigger as $t
          | "<rect x=\"\(tx($t.pos[0] - $t.size[0] / 2) | r2)\" y=\"\(tz($t.pos[2] + $t.size[2] / 2) | r2)\" width=\"\($t.size[0] * $S | r2)\" height=\"\($t.size[2] * $S | r2)\" class=\"tr\"><title>\($e) trigger</title></rect>"
        else "" end)
      + (.waves // [] | to_entries | map($en as $c | (.key + 1) as $n | (.value.start // "" | esc) as $st | .value.enemies[]?
          | (($types[.type].range // 0) | if type == "number" then . else 0 end) as $rg
          | (.type // "" | esc) as $ty
          | if melee($types) then
            "<line x1=\"\(tx(.pos[0]) | r2)\" y1=\"\(tz(.pos[2]) | r2)\" x2=\"\(tx(.hold[0]) | r2)\" y2=\"\(tz(.hold[2]) | r2)\" stroke=\"\($c)\" stroke-width=\"2\" marker-end=\"url(#m)\"/>"
            + "<rect x=\"\(tx(.pos[0]) - 5.5 | r2)\" y=\"\(tz(.pos[2]) - 5.5 | r2)\" width=\"11\" height=\"11\" fill=\"\($c)\"><title>\($e) wave \($n) (\($st)): \($ty) spawn</title></rect><text x=\"\(tx(.pos[0]) | r2)\" y=\"\(tz(.pos[2]) + 3 | r2)\" class=\"wn\">\($n)</text>"
            + "<circle \(at(.hold)) r=\"6\" fill=\"#fff\" stroke=\"\($c)\" stroke-width=\"2\"><title>\($e) wave \($n): \($ty) meets the player</title></circle><text x=\"\(tx(.hold[0]) | r2)\" y=\"\(tz(.hold[2]) + 2.5 | r2)\" class=\"hn\" fill=\"\($c)\">\($n)</text>"
          else
          (if $rg > 0 then "<circle \(at(.hold)) r=\"\($rg * $S | r2)\" clip-path=\"url(#c)\" fill=\"\($c)\" fill-opacity=\"0.05\" stroke=\"\($c)\" stroke-opacity=\"0.3\" stroke-width=\"0.6\"/>" else "" end)
          + "<line x1=\"\(tx(.pos[0]) | r2)\" y1=\"\(tz(.pos[2]) | r2)\" x2=\"\(tx(.hold[0]) | r2)\" y2=\"\(tz(.hold[2]) | r2)\" stroke=\"\($c)\" stroke-width=\"1\" stroke-dasharray=\"3 2\"/>"
          + "<rect x=\"\(tx(.pos[0]) - 5.5 | r2)\" y=\"\(tz(.pos[2]) - 5.5 | r2)\" width=\"11\" height=\"11\" fill=\"\($c)\"><title>\($e) wave \($n) (\($st)): \($ty) spawn</title></rect><text x=\"\(tx(.pos[0]) | r2)\" y=\"\(tz(.pos[2]) + 3 | r2)\" class=\"wn\">\($n)</text>"
          + "<circle \(at(.hold)) r=\"5\" fill=\"#fff\" stroke=\"\($c)\" stroke-width=\"2\"><title>\($e) wave \($n): \($ty) hold</title></circle><text x=\"\(tx(.hold[0]) | r2)\" y=\"\(tz(.hold[2]) + 2.5 | r2)\" class=\"hn\" fill=\"\($c)\">\($n)</text>" end) | join(""))
      + "<line x1=\"\(tx(.entry[0]) | r2)\" y1=\"\(tz(.entry[2]) | r2)\" x2=\"\(tx(.exit[0]) | r2)\" y2=\"\(tz(.exit[2]) | r2)\" class=\"rt\" stroke-opacity=\"0.4\"/>"
      + "<circle \(at(.entry)) r=\"6\" fill=\"\($pl)\"><title>\($e) entry</title></circle>"
      + "<circle \(at(.exit)) r=\"6\" fill=\"#fff\" class=\"ee\"><title>\($e) exit</title></circle>"
      + "<text x=\"\(tx(.entry[0]) + 9 | r2)\" y=\"\(tz(.entry[2]) - 8 | r2)\" class=\"lb\">\($e) ★\(.intensity // "?" | esc)</text>") | join(""))
  + "</g>"
  + "<g transform=\"translate(\($m),\($cy | r2))\"><text x=\"0\" y=\"-8\" class=\"t\">pacing (route order: intensity, then ranged and melee enemies)</text><rect x=\"0\" y=\"0\" width=\"\($cw | r2)\" height=\"\($ch | r2)\" class=\"f\"/>"
  + ([$es | to_entries[] | (.key * ($cw / $n)) as $x0 | .value as $e
      | ($e.intensity // 0 | if type == "number" then . else 0 end) as $in
      | [$e.waves[]?.enemies[]? | if melee($types) then "melee" else "ranged" end] as $ks
      | ([$ks[] | select(. == "ranged")] | length) as $nr | ([$ks[] | select(. == "melee")] | length) as $nm
      | ($ch - 10) as $bh
      | "<rect x=\"\($x0 + 10 | r2)\" y=\"\($ch - $in / 5 * $bh | r2)\" width=\"18\" height=\"\($in / 5 * $bh | r2)\" fill=\"\(col("marks"; "intensity"))\"><title>\($e.id // "" | esc) intensity \($in)</title></rect>"
      + "<rect x=\"\($x0 + 32 | r2)\" y=\"\($ch - $nr / $nmax * $bh | r2)\" width=\"18\" height=\"\($nr / $nmax * $bh | r2)\" fill=\"\($en)\" fill-opacity=\"0.45\"><title>\($e.id // "" | esc) \($nr) ranged</title></rect>"
      + "<rect x=\"\($x0 + 32 | r2)\" y=\"\($ch - ($nr + $nm) / $nmax * $bh | r2)\" width=\"18\" height=\"\($nm / $nmax * $bh | r2)\" fill=\"\($en)\"><title>\($e.id // "" | esc) \($nm) melee</title></rect>"
      + "<text x=\"\($x0 + 10 | r2)\" y=\"\($ch + 14 | r2)\" class=\"lg\">\($e.id // "" | esc)</text><text x=\"\($x0 + 10 | r2)\" y=\"\($ch + 28 | r2)\" class=\"lg\">★\($in) \($nr + $nm) enemies</text>"] | join(""))
  + "</g>"
  + "<g transform=\"translate(\($m),\($cy + $ch + 52 | r2))\">" + $lg.svg + "</g>"
  + "</svg>"
' "$in" > "$out"

printf 'svg\t%s\n' "$out"
prompt view svg="$out" self="$(dirname -- "$0")" slug="$1"
