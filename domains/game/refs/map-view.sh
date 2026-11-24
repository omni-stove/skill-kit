#!/bin/sh
# Usage: map-view.sh <slug>
# Draws docs/design/maps/<slug>.json as docs/design/maps/<slug>.svg: the top view, the front
# view from -z, the side view from +x and a 3D view from above -x -z, each piece coloured by
# kind, with the spawns and the height metrics. The top view names each beat over its pieces
# and draws each objective with its defending team, every note is the tooltip of its beat,
# piece, objective or spawn, and the backdrop lines sit under the legend. Prints the SVG path as a data line.
set -eu
[ $# -eq 1 ] || { echo "usage: map-view.sh <slug>" >&2; exit 2; }
command -v jq >/dev/null || { echo "view: jq not found — install jq, then rerun." >&2; exit 1; }
in="docs/design/maps/$1.json"
out="docs/design/maps/$1.svg"
[ -f "$in" ] || { echo "view: $in not found — write the layout file first." >&2; exit 1; }
jq -e '(.pieces | type == "array" and length > 0) and all(.pieces[]; (.pos | length) == 3 and (.size | length) == 3)' "$in" >/dev/null \
  || { echo "view: $in needs a non-empty pieces array, each with pos [x, y, z] and size [w, h, d] in numbers — fix it, then rerun." >&2; exit 1; }

jq -r '
def r2: (. * 100 | round) / 100 | tostring;
def esc: tostring | gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub("\""; "&quot;");
def pts: map("\(.[0] | r2),\(.[1] | r2)") | join(" ");
def color: {floor: "#d8d2c4", wall: "#6e6e6e", cover: "#c4884a", ramp: "#73a86f", stairs: "#5d8fba"}[.] // "#b0b0b0";
def sloped: .kind == "ramp" or .kind == "stairs";
# Yaw turns clockwise seen from above, so local +z (forward) lands on (sin, cos) in x, z.
def turned: ((.yaw // 0) * 3.141592653589793 / 180) as $t | {s: ($t | sin), c: ($t | cos)};

[.pieces[] | . as $q | turned as $r
  | {id: (.id // "" | esc), sec: (.id // "" | tostring | split("-")[0]), tip: ((.id // "" | tostring) + " (" + (.kind // "" | tostring) + ")" + (if .note then ": " + (.note | tostring) else "" end) | esc), kind: (.kind // ""), x: .pos[0], y: .pos[1], z: .pos[2], w: .size[0], h: .size[1], d: .size[2], s: $r.s, c: $r.c}
  | . as $p
  | .fp = ([[-1, -1], [1, -1], [1, 1], [-1, 1]]
      | map([$p.x + .[0] * $p.w / 2 * $p.c + .[1] * $p.d / 2 * $p.s, $p.z - .[0] * $p.w / 2 * $p.s + .[1] * $p.d / 2 * $p.c]))
] as $ps
| [(.objectives // [])[] | select((.pos | length) == 3 and (.size | length) == 3) | . as $o | turned as $r
   | {label: ((.id // "" | tostring) + (if (.team // "") != "" then " (" + (.team | tostring) + ")" else "" end) | esc),
      tip: ((.id // "" | tostring) + " " + (.kind // "" | tostring) + (if .note then ": " + (.note | tostring) else "" end) | esc),
      x: .pos[0], z: .pos[2],
      fp: ([[-1, -1], [1, -1], [1, 1], [-1, 1]] | map([$o.pos[0] + .[0] * $o.size[0] / 2 * $r.c + .[1] * $o.size[2] / 2 * $r.s, $o.pos[2] - .[0] * $o.size[0] / 2 * $r.s + .[1] * $o.size[2] / 2 * $r.c]))}] as $ob
| [(.spawns // [])[] | turned as $r | {team: (.team // "" | esc), tip: ((.team // "" | tostring) + (if .note then ": " + (.note | tostring) else "" end) | esc), x: .pos[0], y: .pos[1], z: .pos[2], s: $r.s, c: $r.c}] as $sp
| [(.metrics // {}) | to_entries[] | select((.value | type) == "number" and (.key | test("height|climb|step|jump"; "i"))) | {k: (.key | esc), v: .value}] as $ml
| [(.beats // [])[] | (.id // "" | tostring) as $b | [$ps[] | select(.sec == $b) | .fp[]] as $f | select($f | length > 0)
   | {label: ($b + " " + (.name // "" | tostring) | esc), tip: ([$b + " " + (.name // "" | tostring)] + [(.notes // [])[] | tostring] | join("\n") | esc),
      x: ([$f[][0]] | (min + max) / 2), z: ([$f[][1]] | (min + max) / 2)}] as $bt
| [(.backdrop // [])[] | tostring | esc] as $bd
| (.grid // 1 | if type == "number" and . > 0 then . else 1 end) as $g

| ([$ps[].fp[][0]] + [$ob[].fp[][0]] + [$sp[].x]) as $xs | ([$ps[].fp[][1]] + [$ob[].fp[][1]] + [$sp[].z]) as $zs
| ([$ps[] | .y, .y + .h] + [$sp[].y] + [$ml[].v] + [0]) as $ys
| ($xs | min) as $x0 | ($xs | max) as $x1 | ($zs | min) as $z0 | ($zs | max) as $z1 | ($ys | min) as $y0 | ($ys | max) as $y1
| ([$x1 - $x0, $z1 - $z0, $y1 - $y0, 1] | max) as $span
| (560 / $span) as $S
| def iso($x; $y; $z): [($x - $z) * 0.8660254 * $S, (-($x + $z) * 0.5 - $y) * $S];
  ([$ps[] | . as $p | .fp[] | iso(.[0]; $p.y; .[1]), iso(.[0]; $p.y + $p.h; .[1])] + [$sp[] | iso(.x; .y; .z)]) as $ip
| ($ip | map(.[0]) | min) as $ix0 | ($ip | map(.[1]) | min) as $iy0
| (($ip | map(.[0]) | max) - $ix0) as $iw | (($ip | map(.[1]) | max) - $iy0) as $ih
| (($x1 - $x0) * $S) as $w1 | (($z1 - $z0) * $S) as $dz | (($y1 - $y0) * $S) as $hy
| ([$dz, $iw] | max) as $w2 | ([$dz, $ih] | max) as $h1
| 40 as $m | 20 as $tt
| ($m + $tt) as $r1 | ($r1 + $h1 + $m + $tt) as $r2 | ($m + $w1 + $m) as $c2
| ($c2 + $w2 + $m) as $W | ($r2 + $hy + $m + 6) as $lgy | ($lgy + 14 + ($bd | length) * 16) as $H

| def tx($x): ($x - $x0) * $S; def tz($z): ($z1 - $z) * $S; def tw($z): ($z - $z0) * $S; def ty($y): ($y1 - $y) * $S;
  def frame($ox; $oy; $w; $h; $title):
    "<g transform=\"translate(\($ox | r2),\($oy | r2))\"><text x=\"0\" y=\"-8\" class=\"t\">\($title)</text><rect x=\"0\" y=\"0\" width=\"\($w | r2)\" height=\"\($h | r2)\" class=\"f\"/>";
  def piece($v; $kind; $tip; $shade; $op):
    "<polygon points=\"\($v | pts)\" fill=\"\($kind | color)\" fill-opacity=\"\($op)\" stroke=\"#333\" stroke-width=\"0.6\"><title>\($tip)</title></polygon>"
    + (if $shade > 0 then "<polygon points=\"\($v | pts)\" fill=\"#000\" fill-opacity=\"\($shade)\" pointer-events=\"none\"/>" else "" end);
  def piece($v; $kind; $tip; $shade): piece($v; $kind; $tip; $shade; 1);
  def metrics($w):
    [$ml[] | "<line x1=\"0\" x2=\"\($w | r2)\" y1=\"\(ty(.v) | r2)\" y2=\"\(ty(.v) | r2)\" class=\"ml\"/><text x=\"\($w - 2 | r2)\" y=\"\(ty(.v) - 3 | r2)\" class=\"mt\">\(.k) \(.v)</text>"] | join("");
  def ground($w): if $y0 <= 0 and 0 <= $y1 then "<line x1=\"0\" x2=\"\($w | r2)\" y1=\"\(ty(0) | r2)\" y2=\"\(ty(0) | r2)\" class=\"gl\"/>" else "" end;
  # A sloped piece shows its wedge only when it rises across the view; seen end-on it is a full-height face.
  def elev($a0; $a1; $fh):
    ty(.y) as $b | ty(.y + .h) as $t
    | if sloped and ($fh > 0.7 or $fh < -0.7) then
        (if $fh > 0 then [[$a0, $b], [$a1, $b], [$a1, $t]] else [[$a0, $b], [$a1, $b], [$a0, $t]] end)
      else [[$a0, $b], [$a1, $b], [$a1, $t], [$a0, $t]] end;
  def isop($v): iso($v[0]; $v[1]; $v[2]) | [.[0] - $ix0, .[1] - $iy0];
  def isofaces:
    . as $p
    | [.fp[] | [.[0], $p.y, .[1]]] as $B | [.fp[] | [.[0], $p.y + $p.h, .[1]]] as $T
    | (if sloped then
        [{v: [$B[3], $B[2], $T[2], $T[3]], n: [$p.s, $p.c]},
         {v: [$B[1], $B[2], $T[2]], n: [$p.c, -$p.s]},
         {v: [$B[0], $B[3], $T[3]], n: [-$p.c, $p.s]},
         {v: [$B[0], $B[1], $T[2], $T[3]]}]
      else
        [{v: [$B[3], $B[2], $T[2], $T[3]], n: [$p.s, $p.c]},
         {v: [$B[0], $B[1], $T[1], $T[0]], n: [-$p.s, -$p.c]},
         {v: [$B[1], $B[2], $T[2], $T[1]], n: [$p.c, -$p.s]},
         {v: [$B[0], $B[3], $T[3], $T[0]], n: [-$p.c, $p.s]},
         {v: $T}]
      end)
    | map(select(.n == null or (.n[0] + .n[1]) < -0.001))
    | sort_by(.n == null)
    | map(piece(.v | map(isop(.)); $p.kind; $p.tip; (if .n == null then 0 elif .n[0] < .n[1] then 0.12 else 0.32 end)))
    | join("");

  # Above about 100 lines a grid stops reading as one, so the step grows by whole cells.
  ($g * ((($span / $g) / 100) | ceil | if . < 1 then 1 else . end)) as $gs
  | "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\($W | r2)\" height=\"\($H | r2)\" viewBox=\"0 0 \($W | r2) \($H | r2)\" font-family=\"sans-serif\">"
  + "<style>.t{font-size:13px;font-weight:bold}.f{fill:none;stroke:#999}.g{stroke:#e4e4e4;stroke-width:0.5}.gl{stroke:#555;stroke-width:1}.ml{stroke:#c33;stroke-dasharray:4 3;stroke-width:0.8}.mt{font-size:10px;fill:#c33;text-anchor:end}.sp{fill:#d22;stroke:#fff;stroke-width:1}.st{font-size:10px;fill:#d22}.ar{stroke:#fff;stroke-width:1.5;marker-end:url(#a)}.lg{font-size:11px}.bt{font-size:13px;font-weight:bold;fill:#225;text-anchor:middle;paint-order:stroke;stroke:#fff;stroke-width:3}.ob{fill:#93c;fill-opacity:0.25;stroke:#93c;stroke-width:1.5;stroke-dasharray:4 2}.ot{font-size:11px;font-weight:bold;fill:#62a;text-anchor:middle;paint-order:stroke;stroke:#fff;stroke-width:3}</style>"
  + "<defs><marker id=\"a\" viewBox=\"0 0 10 10\" refX=\"8\" refY=\"5\" markerWidth=\"4\" markerHeight=\"4\" orient=\"auto\"><path d=\"M0,0L10,5L0,10z\" fill=\"#fff\"/></marker></defs>"
  + "<rect width=\"100%\" height=\"100%\" fill=\"#fff\"/>"

  + frame($m; $r1; $w1; $dz; "top (+z up, grid \($gs) m)")
  + ([range(($x0 / $gs | ceil) * $gs; $x1 + 0.0001; $gs) | "<line x1=\"\(tx(.) | r2)\" x2=\"\(tx(.) | r2)\" y1=\"0\" y2=\"\($dz | r2)\" class=\"g\"/>"]
     + [range(($z0 / $gs | ceil) * $gs; $z1 + 0.0001; $gs) | "<line x1=\"0\" x2=\"\($w1 | r2)\" y1=\"\(tz(.) | r2)\" y2=\"\(tz(.) | r2)\" class=\"g\"/>"] | join(""))
  + ($ps | sort_by(.y + .h) | map(
      piece(.fp | map([tx(.[0]), tz(.[1])]); .kind; .tip; 0)
      + (if sloped then
          "<line x1=\"\(tx(.x - .s * .d * 0.3) | r2)\" y1=\"\(tz(.z - .c * .d * 0.3) | r2)\" x2=\"\(tx(.x + .s * .d * 0.3) | r2)\" y2=\"\(tz(.z + .c * .d * 0.3) | r2)\" class=\"ar\"/>"
        else "" end)) | join(""))
  + ($ob | map("<polygon points=\"\(.fp | map([tx(.[0]), tz(.[1])]) | pts)\" class=\"ob\"><title>\(.tip)</title></polygon><text x=\"\(tx(.x) | r2)\" y=\"\(tz(.z) + 4 | r2)\" class=\"ot\">\(.label)</text>") | join(""))
  + ($sp | map("<line x1=\"\(tx(.x) | r2)\" y1=\"\(tz(.z) | r2)\" x2=\"\(tx(.x) + .s * 14 | r2)\" y2=\"\(tz(.z) - .c * 14 | r2)\" stroke=\"#d22\" stroke-width=\"2\"/><circle cx=\"\(tx(.x) | r2)\" cy=\"\(tz(.z) | r2)\" r=\"5\" class=\"sp\"><title>\(.tip)</title></circle><text x=\"\(tx(.x) + 7 | r2)\" y=\"\(tz(.z) + 12 | r2)\" class=\"st\">\(.team)</text>") | join(""))
  + ($bt | map("<text x=\"\(tx(.x) | r2)\" y=\"\(tz(.z) | r2)\" class=\"bt\"><title>\(.tip)</title>\(.label)</text>") | join(""))
  + "</g>"

  + frame($c2; $r1; $iw; $ih; "3D (from above -x -z)")
  + ($ps | sort_by([-(.fp | map(.[0] + .[1]) | max), .y]) | map(isofaces) | join(""))
  + ($sp | map(isop([.x, .y, .z]) as $q | "<circle cx=\"\($q[0] | r2)\" cy=\"\($q[1] | r2)\" r=\"4\" class=\"sp\"/><text x=\"\($q[0] + 6 | r2)\" y=\"\($q[1] - 4 | r2)\" class=\"st\">\(.team)</text>") | join(""))
  + "</g>"

  # Elevations are filled see-through, or the walls nearest the view hide everything behind them.
  + frame($m; $r2; $w1; $hy; "front (from -z)") + ground($w1)
  + ($ps | sort_by([-(.fp | map(.[1]) | max), .y]) | map(
      piece(elev(tx(.fp | map(.[0]) | min); tx(.fp | map(.[0]) | max); .s); .kind; .tip; 0; (if .kind == "wall" then 0.15 else 0.45 end))) | join(""))
  + ($sp | map("<circle cx=\"\(tx(.x) | r2)\" cy=\"\(ty(.y) | r2)\" r=\"4\" class=\"sp\"/>") | join(""))
  + metrics($w1) + "</g>"

  + frame($c2; $r2; $dz; $hy; "side (from +x, +z right)") + ground($dz)
  + ($ps | sort_by([(.fp | map(.[0]) | min), .y]) | map(
      piece(elev(tw(.fp | map(.[1]) | min); tw(.fp | map(.[1]) | max); .c); .kind; .tip; 0; (if .kind == "wall" then 0.15 else 0.45 end))) | join(""))
  + ($sp | map("<circle cx=\"\(tw(.z) | r2)\" cy=\"\(ty(.y) | r2)\" r=\"4\" class=\"sp\"/>") | join(""))
  + metrics($dz) + "</g>"

  + ("<g transform=\"translate(\($m),\($lgy | r2))\">"
     + ([["floor", "wall", "cover", "ramp", "stairs"] | to_entries[] | "<rect x=\"\(.key * 80)\" y=\"-9\" width=\"10\" height=\"10\" fill=\"\(.value | color)\" stroke=\"#333\" stroke-width=\"0.6\"/><text x=\"\(.key * 80 + 14)\" y=\"0\" class=\"lg\">\(.value)</text>"] | join(""))
     + "<circle cx=\"405\" cy=\"-4\" r=\"4\" class=\"sp\"/><text x=\"414\" y=\"0\" class=\"lg\">spawn</text><line x1=\"470\" x2=\"490\" y1=\"-4\" y2=\"-4\" class=\"ml\"/><text x=\"494\" y=\"0\" class=\"lg\">height metric</text><rect x=\"580\" y=\"-9\" width=\"14\" height=\"10\" class=\"ob\"/><text x=\"598\" y=\"0\" class=\"lg\">objective</text>"
     + ($bd | to_entries | map("<text x=\"0\" y=\"\(.key * 16 + 18)\" class=\"lg\">backdrop: \(.value)</text>") | join("")) + "</g>")
  + "</svg>"
' "$in" > "$out"

printf 'svg\t%s\n' "$out"
