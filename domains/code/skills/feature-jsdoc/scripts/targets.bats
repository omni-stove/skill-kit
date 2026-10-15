#!/usr/bin/env bats
# targets.sh — page and component directories with their role, the scope filter, and a
# direct path.

bats_require_minimum_version 1.5.0

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/targets.sh"
  APP="$BATS_TEST_TMPDIR/app"
  base="$APP/packages/front/src"
  mkdir -p "$base/ui/pages" "$base/ui/components" "$APP/packages/api/src" "$APP/node_modules/pkg/src/ui/pages"
  : > "$base/ui/pages/Home.tsx"
  : > "$base/ui/components/Card.tsx"
  : > "$APP/packages/api/src/index.ts"
  : > "$APP/node_modules/pkg/src/ui/pages/Ignored.tsx"
}

@test "all lists page and component directories with their role" {
  run --separate-stderr "$SCRIPT" "$APP"
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf '%s/packages/front/src/ui/pages\tpage\n%s/packages/front/src/ui/components\tcomponent' "$APP" "$APP")" ]
  [[ "$stderr" == *"one file at a time"* ]]
}

@test "pages and components narrow the list" {
  run --separate-stderr "$SCRIPT" "$APP" pages
  [ "$output" = "$(printf '%s/packages/front/src/ui/pages\tpage' "$APP")" ]
  run --separate-stderr "$SCRIPT" "$APP" components
  [ "$output" = "$(printf '%s/packages/front/src/ui/components\tcomponent' "$APP")" ]
}

@test "a path under the dir is emitted as one path row, and must exist" {
  run --separate-stderr "$SCRIPT" "$APP" packages/front/src/ui/pages/Home.tsx
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf '%s/packages/front/src/ui/pages/Home.tsx\tpath' "$APP")" ]
  run "$SCRIPT" "$APP" packages/front/src/ui/pages/Missing.tsx
  [ "$status" -eq 1 ]
}

@test "a src without .tsx yields nothing, and . strips its prefix" {
  cd "$APP/packages/api"
  run --separate-stderr "$SCRIPT" .
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  cd "$APP"
  run --separate-stderr "$SCRIPT" .
  [ "$output" = "$(printf 'packages/front/src/ui/pages\tpage\npackages/front/src/ui/components\tcomponent')" ]
}

@test "an unknown scope or a missing dir is a usage error" {
  run "$SCRIPT" "$APP" bogus
  [ "$status" -eq 2 ]
  run "$SCRIPT" "$APP/nope"
  [ "$status" -eq 2 ]
}
