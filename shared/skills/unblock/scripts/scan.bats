#!/usr/bin/env bats
# unblock scan.sh — which sub-issues get their label from their blockers, the manual ones, and --force.

bats_require_minimum_version 1.5.0

setup() {
  SCAN="$BATS_TEST_DIRNAME/scan.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  : > "$CALLS"
  cat > "$BATS_TEST_TMPDIR/gh" <<STUB
#!/usr/bin/env bash
echo "gh \$*" >> "$CALLS"
issue() { echo "{\"number\":\$1,\"state\":\"\$2\",\"labels\":\$3,\"type\":\$4,\"title\":\"t\$1\",\"html_url\":\"u\$1\"}"; }
reply() { case "\$*" in
  *"issues?state=open"*) echo '[{"number":3,"sub_issues_summary":{"total":9,"completed":1}},{"number":4,"sub_issues_summary":{"total":1,"completed":1}},{"number":5,"pull_request":{},"sub_issues_summary":{"total":1,"completed":0}}]' ;;
  *"issues/3/sub_issues"*) echo "[\$(issue 10 open '[]' null),\$(issue 11 open '[]' '{"name":"Bug"}'),\$(issue 12 open '[]' null),\$(issue 13 open '[{"name":"implementation"}]' null),\$(issue 14 open '[]' null),\$(issue 15 closed '[]' null),\$(issue 16 open '[{"name":"manual"}]' null),\$(issue 17 open '[{"name":"manual"}]' null),\$(issue 18 open '[{"name":"manual"}]' null)]" ;;
  *"issues/10/dependencies"*) echo '[{"number":1,"state":"closed","state_reason":"completed"},{"number":2,"state":"closed","state_reason":"completed"}]' ;;
  *"issues/11/dependencies"*) echo '[{"number":1,"state":"closed","state_reason":"completed"},{"number":5,"state":"open","state_reason":null}]' ;;
  *"issues/12/dependencies"*) echo '[{"number":6,"state":"closed","state_reason":"not_planned"}]' ;;
  *"issues/14/dependencies"*) echo '[]' ;;
  *"issues/16/dependencies"*) echo '[]' ;;
  *"issues/17/dependencies"*) echo '[{"number":5,"state":"open","state_reason":null}]' ;;
  *"issues/18/dependencies"*) echo '[{"number":1,"state":"closed","state_reason":"completed"},{"number":6,"state":"closed","state_reason":"not_planned"}]' ;;
  *"issues/12 "*) issue 12 open '[]' null ;;
  *"issues/13 "*) issue 13 open '[{"name":"implementation"}]' null ;;
  *"issues/16 "*) issue 16 open '[{"name":"manual"}]' null ;;
esac; }
out=\$(reply "\$@")
while [ \$# -gt 0 ] && [ "\$1" != --jq ]; do shift; done
if [ -n "\$out" ]; then echo "\$out" | jq -r "\$2"; fi
STUB
  chmod +x "$BATS_TEST_TMPDIR/gh"
  export GH_CMD="$BATS_TEST_TMPDIR/gh"
}

@test "scan.sh labels the sub-issues whose blockers all completed and lists the rest" {
  run --separate-stderr "$SCAN"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$(printf 'labeled\t10\timplementation\tt10\tu10\t')" ]
  [ "${lines[1]}" = "$(printf 'waiting\t11\tbug\tt11\tu11\t#5')" ]
  [ "${lines[2]}" = "$(printf 'dropped\t12\timplementation\tt12\tu12\t#6')" ]
  [ "${lines[3]}" = "$(printf 'unlinked\t14\timplementation\tt14\tu14\t')" ]
  [ "${lines[4]}" = "$(printf 'yours\t16\tmanual\tt16\tu16\t')" ]
  [ "${lines[5]}" = "$(printf 'waiting\t17\tmanual\tt17\tu17\t#5')" ]
  [ "${lines[6]}" = "$(printf 'yours\t18\tmanual\tt18\tu18\t#6')" ]
  [ "${#lines[@]}" -eq 7 ]
  grep -q 'issue edit 10 --add-label implementation' "$CALLS"
  [ "$(grep -c 'issue edit' "$CALLS")" -eq 1 ]
  ! grep -q 'issues/4/sub_issues\|issues/5/sub_issues' "$CALLS" || false
  [[ "$stderr" == *"scan.sh --force"* ]]
}

@test "scan.sh scans only the named parents" {
  run --separate-stderr "$SCAN" 3
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 7 ]
  ! grep -q 'issues?state=open' "$CALLS" || false
}

@test "scan.sh --force labels the named open unlabeled issues and refuses others" {
  run --separate-stderr "$SCAN" --force 12
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'labeled\t12\timplementation\tt12\tu12\t')" ]
  grep -q 'issue edit 12 --add-label implementation' "$CALLS"
  ! grep -q 'dependencies' "$CALLS" || false
  run "$SCAN" --force 13
  [ "$status" -eq 1 ]
  run "$SCAN" --force 16
  [ "$status" -eq 1 ]
  ! grep -q 'issue edit 16' "$CALLS" || false
  run "$SCAN" --force
  [ "$status" -eq 2 ]
  run "$SCAN" extra
  [ "$status" -eq 2 ]
}
