#!/usr/bin/env bats
# delegate scripts — argument checks, the label on creation or the blockers, manual issues, and the parent link.

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
  "issue list") echo '[{"number":1,"title":"old bug","labels":[{"name":"bug"}],"url":"u1"},{"number":2,"title":"idea","labels":[{"name":"question"}],"url":"u2"},{"number":4,"title":"held","labels":[],"url":"u4"},{"number":8,"title":"by hand","labels":[{"name":"manual"}],"url":"u8"}]' ;;
  "api --paginate") echo 4 ;;
  "api repos/{owner}/{repo}/issues/7") echo 123 ;;
  "api repos/{owner}/{repo}/issues/5") echo 125 ;;
  "api repos/{owner}/{repo}/issues/6") echo 126 ;;
  "api repos/{owner}/{repo}/issues/3/sub_issues") echo '[{"number":7,"title":"child","labels":[{"name":"implementation"}],"type":null,"html_url":"u7"},{"number":9,"title":"next","labels":[],"type":{"name":"Bug"},"html_url":"u9"},{"number":10,"title":"key","labels":[{"name":"manual"}],"type":null,"html_url":"u10"}]' | jq -r "\${@: -1}" ;;
  "api repos/{owner}/{repo}/issues/9/dependencies/blocked_by") echo '#7 #8' ;;
  "api repos/{owner}/{repo}/issues/10/dependencies/blocked_by") echo '#7' ;;
esac
STUB
  chmod +x "$BATS_TEST_TMPDIR/gh"
  export GH_CMD="$BATS_TEST_TMPDIR/gh"
}

@test "create.sh rejects a missing parent or an unknown label" {
  run "$CREATE" bug t --task T --check C
  [ "$status" -eq 2 ]
  run "$CREATE" --parent 3 chore t --task T --check C
  [ "$status" -eq 2 ]
  run "$CREATE" --parent 3 --after x bug t --task T --check C
  [ "$status" -eq 2 ]
  run "$CREATE" --parent 3 bug t --task T
  [ "$status" -eq 2 ]
  run "$CREATE" --parent 3 bug t b
  [ "$status" -eq 2 ]
}

@test "create.sh files the issue with its label, a parent line, and links it as a sub-issue" {
  run "$CREATE" --parent 3 implementation "Title" --task T --check C
  [ "$status" -eq 0 ]
  [ "$output" = "https://github.com/o/r/issues/7" ]
  grep -q -- '--label implementation' "$CALLS"
  grep -q -- '--body 親: #3' "$CALLS"
  grep -qx '## やること' "$CALLS"
  grep -qx '## 確認方法' "$CALLS"
  grep -q 'issues/3/sub_issues' "$CALLS"
}

@test "create.sh --after files the issue unlabeled, blocked by the waits, a bug typed Bug" {
  run "$CREATE" --parent 3 --after 5,6 implementation "Title" --task T --check C
  [ "$status" -eq 0 ]
  [ "$output" = "https://github.com/o/r/issues/7" ]
  ! grep -q -- '--label' "$CALLS" || false
  grep -q 'issues/3/sub_issues' "$CALLS"
  grep -q 'issues/7/dependencies/blocked_by -F issue_id=125' "$CALLS"
  grep -q 'issues/7/dependencies/blocked_by -F issue_id=126' "$CALLS"
  ! grep -q 'type=Bug' "$CALLS" || false
  run "$CREATE" --parent 3 --after 5 bug "Title" --task T --check C
  [ "$status" -eq 0 ]
  grep -q 'PATCH repos/{owner}/{repo}/issues/7 -f type=Bug' "$CALLS"
}

@test "create.sh files a manual issue labeled, creating the label, even when it waits" {
  run "$CREATE" --parent 3 --after 5 manual "Title" --task T --check C
  [ "$status" -eq 0 ]
  grep -q 'label create manual' "$CALLS"
  grep -q -- '--label manual' "$CALLS"
  grep -q 'issues/7/dependencies/blocked_by -F issue_id=125' "$CALLS"
  ! grep -q 'type=Bug' "$CALLS" || false
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
  [ "${lines[2]}" = "$(printf 'covers\t8\tmanual\tby hand\tu8')" ]
  [ "${lines[3]}" = "$(printf 'similar\t2\tquestion\tidea\tu2')" ]
  [[ "$stderr" == *"parent.sh"* ]]
  run "$BATS_TEST_DIRNAME/similar.sh"
  [ "$status" -eq 2 ]
}

@test "report.sh prints the parent URL and the children, the waiting ones with their label and waits" {
  run --separate-stderr "$BATS_TEST_DIRNAME/report.sh" 3
  [ "$status" -eq 0 ]
  [[ "$output" == *"https://github.com/o/r/issues/3"* ]]
  [[ "$output" == *"$(printf 'implementation\tchild\tu7')"* ]]
  [[ "$output" == *"$(printf 'later:bug\tnext\tu9\t#7 #8')"* ]]
  [[ "$output" == *"$(printf 'manual\tkey\tu10\t#7')"* ]]
  run "$BATS_TEST_DIRNAME/report.sh" x
  [ "$status" -eq 2 ]
}
