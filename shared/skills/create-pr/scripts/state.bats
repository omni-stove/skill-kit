#!/usr/bin/env bats
# state.sh — the state word on stdout, the changes and the next step, and origin/<base> fetched.

bats_require_minimum_version 1.5.0

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/state.sh"
  CALLS="$BATS_TEST_TMPDIR/calls"
  VIEW="$BATS_TEST_TMPDIR/view"     # what gh pr view prints; empty = no PR (exit 1)
  BRANCH="$BATS_TEST_TMPDIR/branch" # the current branch
  : > "$CALLS"; : > "$VIEW"; echo my-branch > "$BRANCH"
  cat > "$BATS_TEST_TMPDIR/git" <<STUB
#!/usr/bin/env bash
echo "git \$*" >> "$CALLS"
[ "\$1" = rev-parse ] && cat "$BRANCH"
exit 0
STUB
  cat > "$BATS_TEST_TMPDIR/gh" <<STUB
#!/usr/bin/env bash
echo "gh \$*" >> "$CALLS"
[ -s "$VIEW" ] || exit 1
cat "$VIEW"
STUB
  chmod +x "$BATS_TEST_TMPDIR/git" "$BATS_TEST_TMPDIR/gh"
  PATH="$BATS_TEST_TMPDIR:$PATH"
}

@test "on the base branch: ON_BASE, fetches it, never looks the PR up" {
  echo main > "$BRANCH"
  printf 'OPEN\thttps://github.com/o/r/pull/1\n' > "$VIEW"
  run --separate-stderr "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "ON_BASE" ]
  [[ "$stderr" == *"git switch -c <new-branch> origin/main"* ]]
  grep -q 'git fetch origin main' "$CALLS"
  ! grep -q 'gh pr view' "$CALLS"
}

@test "a custom base branch is compared and fetched" {
  echo develop > "$BRANCH"
  run --separate-stderr "$SCRIPT" develop
  [ "$output" = "ON_BASE" ]
  grep -q 'git fetch origin develop' "$CALLS"
}

@test "no PR: NONE, then the changes against the fetched base" {
  run --separate-stderr "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "NONE" ]
  [[ "$output" == *"==> diff against origin/main"* ]]
  [[ "$stderr" == *"regenerate.sh"* ]]
  grep -q 'git fetch origin main' "$CALLS"
  grep -q 'git status --short' "$CALLS"
  grep -q 'git log -8' "$CALLS"
}

@test "open PR: STATE<TAB>URL and no second PR" {
  printf 'OPEN\thttps://github.com/o/r/pull/1\n' > "$VIEW"
  run --separate-stderr "$SCRIPT"
  [ "${lines[0]}" = "OPEN	https://github.com/o/r/pull/1" ]
  [[ "$output" == *"==> changes (git status)"* ]]
  [[ "$stderr" == *"do not open another"* ]]
}

@test "merged or closed PR: fetches the base and asks for a new branch" {
  printf 'MERGED\thttps://github.com/o/r/pull/1\n' > "$VIEW"
  run --separate-stderr "$SCRIPT"
  [ "$output" = "MERGED	https://github.com/o/r/pull/1" ]
  [[ "$stderr" == *"git switch -c <new-branch> origin/main"* ]]
  grep -q 'git fetch origin main' "$CALLS"
}

@test "rejects more than one argument" {
  run "$SCRIPT" main extra
  [ "$status" -eq 2 ]
}
