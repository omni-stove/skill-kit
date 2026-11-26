# What every map figure draws its colours, legend labels and legend with, read from the
# map-style file passed as --slurpfile st.
def r2: (. * 100 | round) / 100 | tostring;
def esc: tostring | gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub("\""; "&quot;");
def style: $ARGS.named.st[0];
def col($g; $k): style[$g][$k].color // "#999999";
def lab($g; $k): style[$g][$k].label // $k;
# SVG text is not measured before layout, so a wide glyph is counted at the font size.
def tw: [explode[] | if . > 255 then 11 else 6.5 end] | add // 0;
def sw_area($c): "<rect x=\"0\" y=\"-9\" width=\"10\" height=\"10\" fill=\"\($c)\" stroke=\"#333\" stroke-width=\"0.6\"/>";
def sw_dot($c): "<circle cx=\"5\" cy=\"-4\" r=\"4.5\" fill=\"\($c)\" stroke=\"#fff\" stroke-width=\"1\"/>";
def sw_line($c): "<line x1=\"0\" x2=\"12\" y1=\"-4\" y2=\"-4\" stroke=\"\($c)\" stroke-width=\"2\"/>";
# Lays out [{sw, label}] in rows no wider than $w, as {svg, h}.
def legend($w):
  reduce .[] as $i ({x: 0, y: 0, s: ""};
    (28 + ($i.label | tw)) as $iw
    | (if .x > 0 and .x + $iw > $w then .x = 0 | .y += 18 else . end)
    | .s += "<g transform=\"translate(\(.x | r2),\(.y))\">\($i.sw)<text x=\"16\" y=\"0\" class=\"lg\">\($i.label | esc)</text></g>"
    | .x += $iw)
  | {svg: .s, h: (.y + 18)};
def ov($a; $b):
  (([$a[2], $b[2]] | min) - ([$a[0], $b[0]] | max)) as $w | (([$a[3], $b[3]] | min) - ([$a[1], $b[1]] | max)) as $h
  | if $w > 0 and $h > 0 then $w * $h else 0 end;
# Places each [{raw, cx, cy, x0, y0, x1, y1}] label, in px, inside the frame $fw by $fh, where
# the area it covers of the $obs boxes [{b, k}], times k, and of the labels placed before it,
# plus twice its distance from its centre (cx, cy), is least; the search reaches past its box
# (x0..x1, y0..y1) into open ground. Adds x and y, the text's middle and baseline.
def place($obs; $fw; $fh):
  reduce .[] as $l ({o: $obs, out: []};
    (($l.raw | tw) * 12 / 11 + 4) as $w
    | ([$l.x0 - 150, 0] | max) as $sx0 | ([$l.x1 + 150, $fw] | min) as $sx1
    | ([$l.y0 - 150, 0] | max) as $sy0 | ([$l.y1 + 150, $fh] | min) as $sy1
    | ([($sx1 - $sx0) / 50, ($sy1 - $sy0) / 50, 4] | max) as $step
    | [.o[] | select(.b[0] < $sx1 and .b[2] > $sx0 and .b[1] < $sy1 and .b[3] > $sy0)] as $near
    | ([range($sy0 + 12; $sy1 - 4 + 0.01; $step) as $y | range($sx0 + $w / 2; $sx1 - $w / 2 + 0.01; $step) as $x | [$x, $y]]
       | map([.[0] - $w / 2, .[1] - 12, .[0] + $w / 2, .[1] + 4] as $b
           | {p: ., b: $b, n: ([$near[] | ov($b; .b) * .k] | add // 0), d: ((.[0] - $l.cx) * (.[0] - $l.cx) + (.[1] - 4 - $l.cy) * (.[1] - 4 - $l.cy))})
       | min_by(.n + 2 * (.d | sqrt))) as $c
    | if $c == null then .out += [$l + {x: $l.cx, y: $l.cy}]
      else .o += [{b: $c.b, k: 50}] | .out += [$l + {x: $c.p[0], y: $c.p[1]}] end)
  | .out;
# Lists each section [{raw, name}] as its id and name, one line from y 0 every 16 px.
def beatlist: to_entries | map("<text x=\"0\" y=\"\(.key * 16)\" class=\"lg\"><tspan font-weight=\"bold\">\(.value.raw | esc)</tspan> \(.value.name | esc)</text>") | join("");
# A thin line from a label placed off its box to the box's centre, so it still reads as that section's.
def leader($c):
  if .x < .x0 or .x > .x1 or .y - 4 < .y0 or .y - 4 > .y1 then
    "<line x1=\"\(.x | r2)\" y1=\"\(.y - 4 | r2)\" x2=\"\(.cx | r2)\" y2=\"\(.cy | r2)\" stroke=\"\($c)\" stroke-width=\"1\" stroke-opacity=\"0.6\"/><circle cx=\"\(.cx | r2)\" cy=\"\(.cy | r2)\" r=\"2.5\" fill=\"\($c)\"/>"
  else "" end;
