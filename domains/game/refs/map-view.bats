#!/usr/bin/env bats
# map-view.sh — a layout file drawn as one SVG of the top, front, side and 3D views.

setup() {
  VIEW="$BATS_TEST_DIRNAME/map-view.sh"
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
  svg=$(cat docs/design/maps/arena.svg)
  for t in "top (" "3D (" "front (" "side ("; do [[ "$svg" == *">$t"* ]]; done
  [[ "$svg" == *'class="lg">red</text>'* ]]
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

@test "names each beat over its pieces and puts the notes and the backdrop in the SVG" {
  layout '{"beats":[{"id":"s1","name":"gap <1>","notes":["teach attack"]},{"id":"s9","name":"lost","notes":[]}],
    "backdrop":["armies to the horizon"],
    "spawns":[{"team":"ally","pos":[0,0,0],"yaw":0,"note":"captain"}],
    "pieces":[{"id":"s1-floor","kind":"floor","pos":[0,0,0],"size":[4,0.2,4]},
              {"id":"s1-wall","kind":"wall","pos":[0,0,2],"size":[4,2,0.5],"note":"falls at runtime"},
              {"id":"c1-floor","kind":"floor","pos":[0,0,10],"size":[4,0.2,4]}]}'
  run sh "$VIEW" arena
  [ "$status" -eq 0 ]
  svg=$(cat docs/design/maps/arena.svg)
  [[ "$svg" == *"teach attack</title>s1</text>"* ]]
  [[ "$svg" == *'<tspan font-weight="bold">s1</tspan> gap &lt;1></text>'* ]]
  [[ "$svg" != *"lost"* ]]
  [[ "$svg" == *"<title>s1-wall (wall): falls at runtime</title>"* ]]
  [[ "$svg" == *"<title>ally: captain</title>"* ]]
  [[ "$svg" == *"backdrop: armies to the horizon"* ]]
  ! command -v xmllint >/dev/null || xmllint --noout docs/design/maps/arena.svg
}

@test "draws each objective in the top view with its defending team" {
  layout '{"objectives":[{"id":"site-a","kind":"site","team":"blue","pos":[3,0,3],"size":[4,1,4],"note":"plant"}],
    "pieces":[{"id":"ground","kind":"floor","pos":[0,-0.2,0],"size":[10,0.2,10]}]}'
  run sh "$VIEW" arena
  [ "$status" -eq 0 ]
  grep -q 'class="ob"><title>site-a site: plant</title>' docs/design/maps/arena.svg
  grep -q '>site-a (blue)</text>' docs/design/maps/arena.svg
}

@test "colours each spawn by its team from the repo's map-style file and lists each team in the legend" {
  mkdir -p docs/design
  printf '%s\n' '{"teams":{"enemy":{"color":"#123456","label":"敵"}}}' > docs/design/map-style.json
  layout '{"spawns":[{"team":"enemy","pos":[0,0,0],"yaw":0},{"team":"player","pos":[2,0,0],"yaw":0},{"team":"drone","pos":[3,0,0],"yaw":0}],
    "pieces":[{"id":"ground","kind":"floor","pos":[0,-0.2,0],"size":[10,0.2,10]}]}'
  run sh "$VIEW" arena
  [ "$status" -eq 0 ]
  svg=$(cat docs/design/maps/arena.svg)
  [[ "$svg" == *'fill="#123456" class="sp"'* ]]
  [[ "$svg" == *'class="lg">敵</text>'* ]]
  [[ "$svg" == *'class="lg">player</text>'* ]]
  [ "$(jq -r .teams.enemy.label docs/design/map-style.json)" = "敵" ]
  [ "$(jq -r .teams.player.color docs/design/map-style.json)" = "#1f5fd6" ]
  [ "$(jq -r .teams.drone.color docs/design/map-style.json)" = "$(jq -r '.palette[0]' "$BATS_TEST_DIRNAME/map-style.json")" ]
  [[ "$svg" == *'class="lg">drone</text>'* ]]
  ! command -v xmllint >/dev/null || xmllint --noout docs/design/maps/arena.svg
}

@test "map-style.sh refuses a style file that is not JSON" {
  mkdir -p docs/design
  echo '{' > docs/design/map-style.json
  run sh "$BATS_TEST_DIRNAME/map-style.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"is not valid JSON"* ]]
}

@test "moves a section's name off the spawn at its centre" {
  layout '{"beats":[{"id":"s1","name":"yard","notes":["x"]}],
    "spawns":[{"team":"enemy","pos":[0,0,0],"yaw":0}],
    "pieces":[{"id":"s1-floor","kind":"floor","pos":[0,0,0],"size":[20,0.2,20]}]}'
  run sh "$VIEW" arena
  [ "$status" -eq 0 ]
  cx=$(grep -o '<circle cx="[^"]*" cy="[^"]*" r="5"' docs/design/maps/arena.svg | head -1 | awk -F'"' '{print $2, $4}')
  grep -o '<text x="[^"]*" y="[^"]*" class="bt">' docs/design/maps/arena.svg | awk -F'"' -v c="$cx" '
    { split(c, p, " "); dx = $2 - p[1]; dy = $4 - p[2]; if (dx < 0) dx = -dx; exit !(dx > 30 || dy > 10 || dy < -18) }'
}
