#!/usr/bin/env bats
# reply-review-thread.sh — the reply posted on the comment, then the thread resolved.

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/reply-review-thread.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  : > "$CALLS"
  cat > "$BATS_TEST_TMPDIR/gh" <<STUB
#!/usr/bin/env bash
echo "gh \$*" >> "$CALLS"
case "\$*" in
  *"/replies"*) echo '{"id":9,"html_url":"https://github.com/o/r/pull/3#discussion_r9"}' | jq -r "\${@: -1}" ;;
  "repo view --json owner"*) echo o ;;
  "repo view --json name"*) echo r ;;
  *"query(\$threadId"*) echo "PullRequestReviewThread|o|r|3|false|true|a.ts|1" ;;
  *"mutation"*) echo "resolved T a.ts:1 isResolved=true" ;;
esac
STUB
  chmod +x "$BATS_TEST_TMPDIR/gh"
  export GH_CMD="$BATS_TEST_TMPDIR/gh"
}

@test "posts the reply on the comment and resolves the thread" {
  run "$SCRIPT" 3 T 42 "done in abc123"
  [ "$status" -eq 0 ]
  grep -q 'pulls/3/comments/42/replies -f body=done in abc123' "$CALLS"
  grep -q 'mutation' "$CALLS"
  [[ "$output" == *"replied 9"* ]]
  [[ "$output" == *"resolved T"* ]]
}

@test "rejects a missing argument, a non-numeric id or an empty body" {
  run "$SCRIPT" 3 T 42
  [ "$status" -eq 2 ]
  run "$SCRIPT" 3 T x "body"
  [ "$status" -eq 2 ]
  run "$SCRIPT" 3 T 42 ""
  [ "$status" -eq 2 ]
}
