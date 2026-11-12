#!/usr/bin/env bats
# unblock scan.sh — which waiting issues get their label, and --force.

bats_require_minimum_version 1.5.0

setup() {
  SCAN="$BATS_TEST_DIRNAME/scan.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  : > "$CALLS"
  cat > "$BATS_TEST_TMPDIR/gh" <<STUB
#!/usr/bin/env bash
echo "gh \$*" >> "$CALLS"
case "\$1 \$2" in
  "issue list") echo '[
    {"number":10,"title":"ready","labels":[],"body":"親: #3\\n待ち: #1 #2\\nラベル: \`implementation\`（待ちのIssueがマージされたら付ける）","url":"u10"},
    {"number":11,"title":"blocked","labels":[],"body":"親: #3\\n待ち: #1 #5\\nラベル: \`bug\`（待ちのIssueがマージされたら付ける）","url":"u11"},
    {"number":12,"title":"orphan","labels":[],"body":"親: #3\\n待ち: #6\\nラベル: \`implementation\`（待ちのIssueがマージされたら付ける）","url":"u12"},
    {"number":13,"title":"started","labels":[{"name":"implementation"}],"body":"待ち: #1\\nラベル: \`implementation\`","url":"u13"},
    {"number":14,"title":"plain","labels":[],"body":"no waits","url":"u14"}]' | jq -r "\${@: -1}" ;;
  "issue view")
    case "\$3" in
      1|2) echo "CLOSED COMPLETED" ;;
      5) echo "OPEN null" ;;
      6) echo "CLOSED NOT_PLANNED" ;;
    esac ;;
esac
STUB
  chmod +x "$BATS_TEST_TMPDIR/gh"
  export GH_CMD="$BATS_TEST_TMPDIR/gh"
}

@test "scan.sh labels the issues whose waits all completed and lists the rest" {
  run --separate-stderr "$SCAN"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "$(printf 'labeled\t10\timplementation\tready\tu10\t')" ]
  [ "${lines[1]}" = "$(printf 'waiting\t11\tbug\tblocked\tu11\t#5')" ]
  [ "${lines[2]}" = "$(printf 'dropped\t12\timplementation\torphan\tu12\t#6')" ]
  [ "${#lines[@]}" -eq 3 ]
  grep -q 'issue edit 10 --add-label implementation' "$CALLS"
  [ "$(grep -c 'issue edit' "$CALLS")" -eq 1 ]
  [[ "$stderr" == *"scan.sh --force"* ]]
}

@test "scan.sh --force labels the named waiting issues and refuses others" {
  run --separate-stderr "$SCAN" --force 12
  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'labeled\t12\timplementation\torphan\tu12\t')" ]
  grep -q 'issue edit 12 --add-label implementation' "$CALLS"
  ! grep -q 'issue view' "$CALLS" || false
  run "$SCAN" --force 14
  [ "$status" -eq 1 ]
  run "$SCAN" --force
  [ "$status" -eq 2 ]
  run "$SCAN" extra
  [ "$status" -eq 2 ]
}
