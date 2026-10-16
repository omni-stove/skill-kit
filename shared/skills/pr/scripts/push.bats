#!/usr/bin/env bats
# push.sh — merge the base, push through push-with-merge, then open.sh or the report by whether
# a PR exists.

bats_require_minimum_version 1.5.0

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/push.sh"
  KIT="$(cd "$BATS_TEST_DIRNAME/../../../.." && pwd)"
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/.agents/refs" "$repo/bin"
  ln -s "$KIT/shared/refs/push-with-merge.sh" "$repo/.agents/refs/push-with-merge.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  VIEW="$BATS_TEST_TMPDIR/view"
  BASE="$BATS_TEST_TMPDIR/base"
  BEHIND="$BATS_TEST_TMPDIR/behind"
  CONFLICT="$BATS_TEST_TMPDIR/conflict"
  : > "$CALLS"; : > "$VIEW"; : > "$BASE"
  cat > "$repo/bin/git" <<STUB
#!/usr/bin/env bash
echo "git \$*" >> "$CALLS"
if [ "\$1" = rev-parse ]; then
  case "\$*" in *HEAD^2*) exit 1 ;; esac
  echo my-branch
fi
[ "\$1" = merge-base ] && [ -e "$BEHIND" ] && exit 1
[ "\$1" = merge ] && [ -e "$CONFLICT" ] && exit 1
exit 0
STUB
  cat > "$repo/bin/gh" <<STUB
#!/usr/bin/env bash
echo "gh \$*" >> "$CALLS"
case "\$*" in
  *baseRefName*) [ -s "$BASE" ] || exit 1; cat "$BASE" ;;
  *) [ -s "$VIEW" ] || exit 1; cat "$VIEW" ;;
esac
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

@test "skips the merge when the branch already has the base" {
  run --separate-stderr "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q '^git fetch origin main$' "$CALLS"
  ! grep -q '^git merge ' "$CALLS"
}

@test "merges the base given as the argument before pushing when the branch is behind" {
  touch "$BEHIND"
  run --separate-stderr "$SCRIPT" develop
  [ "$status" -eq 0 ]
  grep -q '^git merge --no-edit origin/develop$' "$CALLS"
  [ "$(grep -n '^git merge --no-edit' "$CALLS" | cut -d: -f1)" -lt "$(grep -n '^git push' "$CALLS" | cut -d: -f1)" ]
}

@test "takes the base from the open PR over the argument" {
  echo release > "$BASE"
  touch "$BEHIND"
  run --separate-stderr "$SCRIPT" develop
  [ "$status" -eq 0 ]
  grep -q '^git merge --no-edit origin/release$' "$CALLS"
}

@test "stops with 3 and does not push on a conflict with the base" {
  touch "$BEHIND" "$CONFLICT"
  run --separate-stderr "$SCRIPT"
  [ "$status" -eq 3 ]
  [[ "$stderr" == *"merge conflict with origin/main"* ]]
  ! grep -q '^git push' "$CALLS"
}

@test "rejects more than one argument" {
  run "$SCRIPT" x y
  [ "$status" -eq 2 ]
}
