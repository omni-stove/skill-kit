#!/usr/bin/env bats
# open.sh — the gh pr create call, the body built from the sections, and the URL passed through.

bats_require_minimum_version 1.5.0

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/open.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  BODY="$BATS_TEST_TMPDIR/body"
  : > "$CALLS"
  cat > "$BATS_TEST_TMPDIR/gh" <<STUB
#!/usr/bin/env bash
echo "gh \$*" >> "$CALLS"
prev=""
for a in "\$@"; do
  [ "\$prev" = --body-file ] && cat "\$a" > "$BODY"
  prev="\$a"
done
echo "https://github.com/o/r/pull/1"
STUB
  chmod +x "$BATS_TEST_TMPDIR/gh"
  PATH="$BATS_TEST_TMPDIR:$PATH"
}

@test "rejects too few or too many sections" {
  run "$SCRIPT" title purpose approach
  [ "$status" -eq 2 ]
  run "$SCRIPT" title p a v r extra
  [ "$status" -eq 2 ]
}

@test "creates the PR against main, assigned to @me, with the body file" {
  run --separate-stderr "$SCRIPT" '[chore] title' 'Closes #7' 'null guard' 'open the list page'
  [ "$status" -eq 0 ]
  [ "$output" = "https://github.com/o/r/pull/1" ]
  [[ "$stderr" == *"report the PR URL"* ]]
  grep -q 'gh pr create --base main --title \[chore\] title --assignee @me --body-file' "$CALLS"
}

@test "the body carries the four sections and not the title" {
  run "$SCRIPT" '[chore] title' 'Closes #7' 'null guard' 'open the list page' 'edge values'
  grep -q '^## 目的$' "$BODY"
  grep -q 'Closes #7' "$BODY"
  grep -q 'null guard' "$BODY"
  grep -q 'open the list page' "$BODY"
  grep -q 'edge values' "$BODY"
  ! grep -q 'title' "$BODY"
}

@test "an empty review-points section gets the default" {
  run "$SCRIPT" t p a v
  grep -q '特になし' "$BODY"
}

@test "a literal \\n stays as text" {
  run "$SCRIPT" t 'Closes #7\nrefs #8' a v
  grep -qF 'Closes #7\nrefs #8' "$BODY"
  ! grep -q '^refs #8$' "$BODY"
}

@test "a section that starts with a bullet is text, not a flag" {
  run "$SCRIPT" t p a v $'- risk one\n- risk two'
  [ "$status" -eq 0 ]
  grep -q '^- risk two$' "$BODY"
}

@test "--base, --draft and --label pass through to gh" {
  run "$SCRIPT" --base develop --draft --label App:x --label auto t p a v
  [ "$status" -eq 0 ]
  grep -q -- '--base develop' "$CALLS"
  grep -q -- '--draft' "$CALLS"
  grep -q -- '--label App:x --label auto' "$CALLS"
}
