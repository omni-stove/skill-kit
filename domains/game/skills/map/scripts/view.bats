#!/usr/bin/env bats
# view.sh — a layout file drawn as one SVG of the top, front, side and 3D views.

setup() {
  VIEW="$BATS_TEST_DIRNAME/view.sh"
  mkdir -p "$BATS_TEST_TMPDIR/repo/docs/design/maps"
  cd "$BATS_TEST_TMPDIR/repo" || exit
}

layout() { printf '%s\n' "$1" > docs/design/maps/arena.json; }

@test "fails with the next step when the layout file is missing" {
  run sh "$VIEW" arena
  [ "$status" -eq 1 ]
  [[ "$output" == *"write the layout file first"* ]]
}

@test "fails on a piece without pos and size" {
  layout '{"pieces":[{"id":"a","kind":"floor","pos":[0,0,0]}]}'
  run sh "$VIEW" arena
  [ "$status" -eq 1 ]
  [[ "$output" == *"pos [x, y, z] and size [w, h, d]"* ]]
}

@test "writes one SVG with the four views, the spawns and the height metrics" {
  layout '{"grid":1,"metrics":{"cover_height":1.2,"passage_width":3},
    "spawns":[{"team":"red","pos":[0,0,-4],"yaw":0}],
    "pieces":[{"id":"ground","kind":"floor","pos":[0,-0.2,0],"size":[10,0.2,10]},
              {"id":"r<1>","kind":"ramp","pos":[2,0,2],"size":[2,1,3],"yaw":90}]}'
  run sh "$VIEW" arena
  [ "$status" -eq 0 ]
  [[ "$output" == *"svg	docs/design/maps/arena.svg"* ]]
  [[ "$output" == *"view.sh arena"* ]]
  [[ "$output" == *"build.sh arena"* ]]
  svg=$(cat docs/design/maps/arena.svg)
  for t in "top (" "3D (" "front (" "side ("; do [[ "$svg" == *">$t"* ]]; done
  [[ "$svg" == *">red</text>"* ]]
  [[ "$svg" == *"cover_height 1.2"* ]]
  [[ "$svg" != *"passage_width"* ]]
  [[ "$svg" == *"<title>r&lt;1> (ramp)</title>"* ]]
  ! command -v xmllint >/dev/null || xmllint --noout docs/design/maps/arena.svg
}

@test "turns a piece clockwise by its yaw in the top view" {
  layout '{"pieces":[{"id":"w","kind":"wall","pos":[0,0,0],"size":[4,1,2]},
                     {"id":"t","kind":"wall","pos":[0,0,0],"size":[4,1,2],"yaw":90},
                     {"id":"r","kind":"ramp","pos":[0,0,0],"size":[2,1,2],"yaw":90}]}'
  sh "$VIEW" arena >/dev/null
  # 4 x 2 seen from above spans 4 m across; turned 90 degrees it spans 2 m across and 4 m down.
  pts() { grep -o "<polygon points=\"[^\"]*\"[^>]*><title>$1 " docs/design/maps/arena.svg | head -n 1 | sed 's/.*points="\([^"]*\)".*/\1/'; }
  span() { pts "$1" | tr ' ' '\n' | cut -d, -f"$2" | sort -n | sed -n '1p;$p' | paste -sd' ' - | awk '{ printf "%.0f", $2 - $1 }'; }
  [ "$(span w 1)" -eq "$(span t 2)" ]
  [ "$(span w 2)" -eq "$(span t 1)" ]
  [ "$(span w 1)" -eq "$(( $(span w 2) * 2 ))" ]
  # Yaw 90 sends the ramp's rise to +x, rightward in the top view.
  grep -o '<line x1="[^"]*" y1="[^"]*" x2="[^"]*" y2="[^"]*" class="ar"' docs/design/maps/arena.svg \
    | awk -F'"' '{ exit !($6 > $2 && $8 == $4) }'
}
