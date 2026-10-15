#!/usr/bin/env bats
# collect.sh — each @feature block with its path, generated and node_modules skipped.

bats_require_minimum_version 1.5.0

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/collect.sh"
  APP="$BATS_TEST_TMPDIR/app"
  mkdir -p "$APP/src/ui/pages" "$APP/src/generated" "$APP/node_modules/pkg"
  cat > "$APP/src/ui/pages/Home.tsx" <<'TSX'
import React from "react";
/**
 * @feature Home
 * @behavior Shows the list
 */
export const Home = () => null;
TSX
  printf '/** @feature Ignored */\n' > "$APP/src/generated/Gen.tsx"
  printf '/** @feature Ignored */\n' > "$APP/node_modules/pkg/index.tsx"
  printf 'export const x = 1;\n' > "$APP/src/ui/pages/Plain.tsx"
}

@test "prints the block under its path and skips generated and node_modules" {
  run --separate-stderr "$SCRIPT" "$APP"
  [ "$status" -eq 0 ]
  [[ "$output" == *"===== $APP/src/ui/pages/Home.tsx ====="* ]]
  [[ "$output" == *"@feature Home"* ]]
  [[ "$output" == *"@behavior Shows the list"* ]]
  [[ "$output" != *"import React"* ]]
  [[ "$output" != *"Ignored"* ]]
  [[ "$output" != *"Plain.tsx"* ]]
  [[ "$stderr" == *"outline the tour"* ]]
}

@test "fails when there is no @feature at all" {
  rm "$APP/src/ui/pages/Home.tsx"
  run "$SCRIPT" "$APP"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no @feature JSDoc"* ]]
}

@test "needs an existing directory" {
  run "$SCRIPT"
  [ "$status" -eq 2 ]
  run "$SCRIPT" "$APP/missing"
  [ "$status" -eq 2 ]
}
