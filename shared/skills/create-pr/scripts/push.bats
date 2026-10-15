#!/usr/bin/env bats
# push.sh — push through push-with-merge, then open.sh or the report by whether a PR exists.

bats_require_minimum_version 1.5.0

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/push.sh"
  KIT="$(cd "$BATS_TEST_DIRNAME/../../../.." && pwd)"
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/.agents/refs" "$repo/bin"
  ln -s "$KIT/shared/refs/push-with-merge.sh" "$repo/.agents/refs/push-with-merge.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  VIEW="$BATS_TEST_TMPDIR/view"
  : > "$CALLS"; : > "$VIEW"
  cat > "$repo/bin/git" <<STUB
#!/usr/bin/env bash
echo "git \$*" >> "$CALLS"
if [ "\$1" = rev-parse ]; then
  case "\$*" in *HEAD^2*) exit 1 ;; esac
  echo my-branch
fi
exit 0
STUB
  cat > "$repo/bin/gh" <<STUB
#!/usr/bin/env bash
echo "gh \$*" >> "$CALLS"
[ -s "$VIEW" ] || exit 1
cat "$VIEW"
STUB
  chmod +x "$repo/bin/git" "$repo/bin/gh"
  PATH="$repo/bin:$PATH"
  cd "$repo"
}

@test "pushes the current branch with -u and points at open.sh when there is no PR" {
  run --separate-stderr "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q '^git push -u origin my-branch$' "$CALLS"
  [[ "$stderr" == *"open.sh"* ]]
}

@test "reports the PR the push updated" {
  echo https://github.com/o/r/pull/1 > "$VIEW"
  run --separate-stderr "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"updated https://github.com/o/r/pull/1"* ]]
  [[ "$stderr" != *"open.sh"* ]]
}

@test "rejects arguments" {
  run "$SCRIPT" x
  [ "$status" -eq 2 ]
}
