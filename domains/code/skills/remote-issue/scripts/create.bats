#!/usr/bin/env bats
# remote-issue scripts — argument checks, the label on creation, and the parent link.

setup() {
  CREATE="$BATS_TEST_DIRNAME/create.sh"
  PARENT="$BATS_TEST_DIRNAME/parent.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  : > "$CALLS"
  cat > "$BATS_TEST_TMPDIR/gh" <<STUB
#!/usr/bin/env bash
echo "gh \$*" >> "$CALLS"
case "\$1 \$2" in
  "issue create") echo "https://github.com/o/r/issues/7" ;;
  "issue view") echo "\${ISSUE_STATE:-OPEN}" ;;
  "api repos/{owner}/{repo}/issues/7") echo 123 ;;
esac
STUB
  chmod +x "$BATS_TEST_TMPDIR/gh"
  export GH_CMD="$BATS_TEST_TMPDIR/gh"
}

@test "create.sh rejects a missing parent or an unknown label" {
  run "$CREATE" bug t b
  [ "$status" -eq 2 ]
  run "$CREATE" --parent 3 chore t b
  [ "$status" -eq 2 ]
}

@test "create.sh files the issue with its label, a parent line, and links it as a sub-issue" {
  run "$CREATE" --parent 3 implementation "Title" "Body"
  [ "$status" -eq 0 ]
  [ "$output" = "https://github.com/o/r/issues/7" ]
  grep -q -- '--label implementation' "$CALLS"
  grep -q '親: #3' "$CALLS"
  grep -q 'issues/3/sub_issues' "$CALLS"
}

@test "parent.sh creates an unlabeled parent and prints its number" {
  run "$PARENT" "Parent" "Body"
  [ "$status" -eq 0 ]
  [ "$output" = "7" ]
  ! grep -q -- '--label' "$CALLS"
}

@test "parent.sh reuses an open issue by commenting, and refuses a closed one" {
  run "$PARENT" --issue 5 "Plan"
  [ "$status" -eq 0 ]
  [ "$output" = "5" ]
  grep -q 'issue comment 5' "$CALLS"
  ISSUE_STATE=CLOSED run "$PARENT" --issue 5 "Plan"
  [ "$status" -eq 1 ]
}
