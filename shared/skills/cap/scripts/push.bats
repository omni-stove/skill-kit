#!/usr/bin/env bats
# push.sh — against a real bare remote: a plain push, a merge of the remote branch when it is
# ahead, exit 3 on a conflict and finishing that merge on the rerun, and the review-rerun
# empty commit only when the branch has an open PR.

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/push.sh"
  GH_HAS_PR="$BATS_TEST_TMPDIR/has_pr"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat > "$BATS_TEST_TMPDIR/bin/gh" <<STUB
#!/usr/bin/env bash
[ -e "$GH_HAS_PR" ] && { echo '{"number":1}'; exit 0; }
exit 1
STUB
  chmod +x "$BATS_TEST_TMPDIR/bin/gh"
  PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
  export GIT_CONFIG_GLOBAL=/dev/null
  remote="$BATS_TEST_TMPDIR/remote.git"
  git init -q --bare -b main "$remote"
  git clone -q "$remote" "$BATS_TEST_TMPDIR/other" 2>/dev/null
  cd "$BATS_TEST_TMPDIR/other" || exit
  echo base > a; echo base > b
  git add -A; git commit -qm base; git push -q origin main
  git clone -q "$remote" "$BATS_TEST_TMPDIR/repo"
  cd "$BATS_TEST_TMPDIR/repo" || exit
}

advance_remote() { # file content
  (cd "$BATS_TEST_TMPDIR/other" && echo "$2" > "$1" && git commit -qam other && git push -q origin main)
}

@test "pushes when the remote is not ahead" {
  echo mine > a; git commit -qam mine
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ]
}

@test "merges the remote branch and pushes when the remote is ahead, with no empty commit without a PR" {
  advance_remote b theirs
  echo mine > a; git commit -qam mine
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  git rev-parse -q --verify 'HEAD^2' >/dev/null
  [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ]
  [ "$(cat b)" = theirs ]
}

@test "adds the empty commit on top of the merge when the branch has a PR" {
  touch "$GH_HAS_PR"
  advance_remote b theirs
  echo mine > a; git commit -qam mine
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$(git log -1 --format=%s)" = "chore: trigger code review after merge" ]
  [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ]
}

@test "stops with 3 on a conflict, then finishes the merge and pushes on the rerun" {
  advance_remote a theirs
  echo mine > a; git commit -qam mine
  run "$SCRIPT"
  [ "$status" -eq 3 ]
  git rev-parse -q --verify MERGE_HEAD >/dev/null
  echo resolved > a
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ]
  [ "$(git show origin/main:a)" = resolved ]
}

@test "rejects an argument" {
  run "$SCRIPT" x
  [ "$status" -eq 2 ]
}
