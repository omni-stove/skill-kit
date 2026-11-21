#!/usr/bin/env bats
# art.sh — a theme's layout files, the modules they need and the model or swap step.

setup() {
  ART="$BATS_TEST_DIRNAME/art.sh"
  mkdir -p "$BATS_TEST_TMPDIR/repo/docs/design/maps" "$BATS_TEST_TMPDIR/repo/.agents/refs" "$BATS_TEST_TMPDIR/bin"
  cd "$BATS_TEST_TMPDIR/repo" || exit
  printf 'engine_name() { echo Unity; }\nsource_root() { echo Assets; }\nheadless_cmd() { echo unity -batchmode; }\nruntime_log() { echo Editor.log; }\n' > .agents/refs/engine.sh
  printf '#!/bin/sh\n' > "$BATS_TEST_TMPDIR/bin/blender"
  chmod +x "$BATS_TEST_TMPDIR/bin/blender"
  PATH="$BATS_TEST_TMPDIR/bin:$PATH"
}

layout() {
  printf '{"theme":"%s","grid":0.5,"pieces":[{"kind":"%s"},{"kind":"wall"}]}\n' "$2" "$3" > "docs/design/maps/$1.json"
}

@test "fails with the next step when there is no layout file" {
  run sh "$ART"
  [ "$status" -eq 1 ]
  [[ "$output" == *"write a map's layout file there first"* ]]
}

@test "takes the only theme and prints the model and swap steps" {
  layout stage-1 harbor floor
  layout stage-2 harbor ramp
  run sh "$ART"
  [ "$status" -eq 0 ]
  [[ "$output" == *"theme	harbor"* ]]
  [[ "$output" == *"map	docs/design/maps/stage-1.json"* ]]
  [[ "$output" == *"kinds	floor ramp wall"* ]]
  [[ "$output" == *"modules	Assets/Modules/harbor"* ]]
  [[ "$output" == *"Blender Python script"* ]]
  [[ "$output" == *"greybox builder"* ]]
}

@test "lists the themes and unthemed files when more than one could be meant" {
  layout stage-1 harbor floor
  layout arena desert floor
  printf '{"pieces":[]}\n' > docs/design/maps/old.json
  run sh "$ART"
  [ "$status" -eq 0 ]
  [[ "$output" == *"theme	desert"* ]]
  [[ "$output" == *"theme	harbor"* ]]
  [[ "$output" == *"unthemed	docs/design/maps/old.json"* ]]
  [[ "$output" == *"art.sh <theme>"* ]]
}

@test "skips modeling when the theme's modules exist" {
  layout stage-1 harbor floor
  mkdir -p Assets/Modules/harbor && : > Assets/Modules/harbor/wall.fbx
  run sh "$ART" harbor
  [ "$status" -eq 0 ]
  [[ "$output" != *"Blender Python script"* ]]
  [[ "$output" == *"greybox builder"* ]]
}

@test "fails on a theme no layout file names" {
  layout stage-1 harbor floor
  run sh "$ART" desert
  [ "$status" -eq 1 ]
  [[ "$output" == *"no layout file"*"has theme desert"* ]]
}
