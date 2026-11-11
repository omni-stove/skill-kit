#!/usr/bin/env bats
# remote-issue scripts — argument checks, the label on creation or the waits, and the parent link.

bats_require_minimum_version 1.5.0

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
  "issue view")
    case "\$*" in
      *url*) echo "https://github.com/o/r/issues/\$3" ;;
      *) echo "\${ISSUE_STATE:-OPEN}" ;;
    esac ;;
  "issue list") echo '[{"number":1,"title":"old bug","labels":[{"name":"bug"}],"body":"","url":"u1"},{"number":2,"title":"idea","labels":[{"name":"question"}],"body":"x","url":"u2"},{"number":4,"title":"held","labels":[],"body":"親: #3\\n待ち: #1\\nラベル: \`bug\`（待ちのIssueがマージされたら付ける）","url":"u4"}]' | jq -r "\${@: -1}" ;;
  "api repos/{owner}/{repo}/issues/7") echo 123 ;;
  "api repos/{owner}/{repo}/issues/3/sub_issues") echo '[{"title":"child","labels":[{"name":"implementation"}],"body":"親: #3","html_url":"u7"},{"title":"next","labels":[],"body":"親: #3\\n待ち: #7 #8\\nラベル: \`implementation\`（待ちのIssueがマージされたら付ける）\\n\\nbody","html_url":"u9"}]' | jq -r "\${@: -1}" ;;
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
  run "$CREATE" --parent 3 --after x bug t b
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

@test "create.sh --after files the issue unlabeled, naming the waits and the label to add" {
  run "$CREATE" --parent 3 --after 5,6 implementation "Title" "Body"
  [ "$status" -eq 0 ]
  [ "$output" = "https://github.com/o/r/issues/7" ]
  ! grep -q -- '--label' "$CALLS" || false
  grep -q '待ち: #5 #6' "$CALLS"
  grep -q 'ラベル: `implementation`' "$CALLS"
  grep -q 'issues/3/sub_issues' "$CALLS"
}

@test "parent.sh creates an unlabeled parent and prints its number" {
  run --separate-stderr "$PARENT" "Parent" "Body"
  [ "$status" -eq 0 ]
  [ "$output" = "7" ]
  [[ "$stderr" == *"create.sh --parent 7"* ]]
  [[ "$stderr" == *"report.sh 7"* ]]
  ! grep -q -- '--label' "$CALLS" || false
}

@test "parent.sh reuses an open issue by commenting, and refuses a closed one" {
  run --separate-stderr "$PARENT" --issue 5 "Plan"
  [ "$status" -eq 0 ]
  [ "$output" = "5" ]
  [[ "$stderr" == *"create.sh --parent 5"* ]]
  grep -q 'issue comment 5' "$CALLS"
  ISSUE_STATE=CLOSED run "$PARENT" --issue 5 "Plan"
  [ "$status" -eq 1 ]
}

@test "similar.sh marks the issues already labeled for the worker, first" {
  run --separate-stderr "$BATS_TEST_DIRNAME/similar.sh" cache layer
  [ "$status" -eq 0 ]
  grep -q -- '--search cache layer --state open' "$CALLS"
  [ "${lines[0]}" = "$(printf 'covers\t1\tbug\told bug\tu1')" ]
  [ "${lines[1]}" = "$(printf 'covers\t4\t\theld\tu4')" ]
  [ "${lines[2]}" = "$(printf 'similar\t2\tquestion\tidea\tu2')" ]
  [[ "$stderr" == *"parent.sh"* ]]
  run "$BATS_TEST_DIRNAME/similar.sh"
  [ "$status" -eq 2 ]
}

@test "report.sh prints the parent URL and the children, the waiting ones with their label and waits" {
  run --separate-stderr "$BATS_TEST_DIRNAME/report.sh" 3
  [ "$status" -eq 0 ]
  [[ "$output" == *"https://github.com/o/r/issues/3"* ]]
  [[ "$output" == *"$(printf 'implementation\tchild\tu7')"* ]]
  [[ "$output" == *"$(printf 'later:implementation\tnext\tu9\t#7 #8')"* ]]
  run "$BATS_TEST_DIRNAME/report.sh" x
  [ "$status" -eq 2 ]
}
