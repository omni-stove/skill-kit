#!/usr/bin/env bats
# skill-kit CLI — domain-first deploy: symlink shared + one domain's entries, record
# the domain, keep real-file overrides, prune dead links, gitignore what the kit owns.

setup() {
  CLI="$BATS_TEST_DIRNAME/skill-kit"
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

  # Fixture mini-kit deployed via SKILL_KIT_HOME: shared + two domains.
  kit="$BATS_TEST_TMPDIR/kit"
  mkdir -p "$kit/bin" "$kit/shared/skills/common" "$kit/shared/refs" "$kit/shared/hooks"
  mkdir -p "$kit/domains/game/skills/gfoo" "$kit/domains/game/refs"
  mkdir -p "$kit/domains/story/skills/sfoo" "$kit/domains/story/refs"
  # bin marker so self-detect logic in the real CLI stays satisfiable if ever exercised.
  cp "$CLI" "$kit/bin/skill-kit"
  echo common > "$kit/shared/skills/common/SKILL.md"
  echo sharedref > "$kit/shared/refs/s.md"
  echo hook > "$kit/shared/hooks/h.sh"
  echo gskill > "$kit/domains/game/skills/gfoo/SKILL.md"
  echo gameref > "$kit/domains/game/refs/g.md"
  echo sskill > "$kit/domains/story/skills/sfoo/SKILL.md"
  echo storyref > "$kit/domains/story/refs/st.md"

  target="$BATS_TEST_TMPDIR/target"
  mkdir -p "$target"
  cd "$target"
}

# Turn the fixture kit into a git clone tracking a bare origin, so `update`'s
# `git pull --ff-only` has a real upstream to talk to.
make_git_kit() {
  origin="$BATS_TEST_TMPDIR/origin.git"
  git init -q --bare "$origin"
  git -C "$kit" init -q -b main
  git -C "$kit" add -A
  git -C "$kit" -c user.email=t@t -c user.name=t commit -qm init
  git -C "$kit" remote add origin "$origin"
  git -C "$kit" push -qu origin main
}

@test "no args prints usage and fails" {
  run "$CLI"
  [ "$status" -eq 1 ]
  [[ "$output" == *"usage: skill-kit"* ]]
}

@test "unknown domain fails" {
  SKILL_KIT_HOME="$kit" run "$CLI" music sync
  [ "$status" -eq 1 ]
}

@test "sync fails when the kit home does not exist" {
  SKILL_KIT_HOME="$BATS_TEST_TMPDIR/nowhere" run "$CLI" game sync
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "game sync deploys shared + game, not story" {
  SKILL_KIT_HOME="$kit" run "$CLI" game sync
  [ "$status" -eq 0 ]
  [ -L .agents/skills/common ]   # shared
  [ -L .agents/skills/gfoo ]     # game
  [ ! -e .agents/skills/sfoo ]   # story absent
  [ -L .claude/skills/gfoo ]
  [ -L .agents/hooks/h.sh ] && [ -L .claude/hooks/h.sh ]
  [ -L .agents/refs/s.md ] && [ -L .agents/refs/g.md ]
  [ ! -e .agents/refs/st.md ]
  [ ! -e .claude/refs ]          # refs to .agents only
}

@test "sync records the domain marker as a real, tracked file" {
  SKILL_KIT_HOME="$kit" run "$CLI" story sync
  [ "$status" -eq 0 ]
  [ -f .agents/refs/domain ] && [ ! -L .agents/refs/domain ]
  [ "$(cat .agents/refs/domain)" = "story" ]
  ! grep -Fxq "domain" .agents/refs/.gitignore
}

@test "sync seeds AGENTS.md and a CLAUDE.md that only imports it" {
  SKILL_KIT_HOME="$kit" run "$CLI" game sync
  [ "$status" -eq 0 ]
  [ -f AGENTS.md ] && [ ! -L AGENTS.md ]
  [ -f CLAUDE.md ] && [ ! -L CLAUDE.md ]
  [ "$(cat CLAUDE.md)" = "@AGENTS.md" ]
}

@test "existing AGENTS.md / CLAUDE.md are never overwritten" {
  echo myagents > AGENTS.md
  echo myclaude > CLAUDE.md
  SKILL_KIT_HOME="$kit" run "$CLI" game sync
  [ "$status" -eq 0 ]
  [ "$(cat AGENTS.md)" = "myagents" ]
  [ "$(cat CLAUDE.md)" = "myclaude" ]
}

@test "no-domain sync reuses the recorded domain" {
  SKILL_KIT_HOME="$kit" "$CLI" game sync
  SKILL_KIT_HOME="$kit" run "$CLI" sync
  [ "$status" -eq 0 ]
  [[ "$output" == *"[game]"* ]]
  [ -L .agents/skills/gfoo ]
}

@test "no-domain sync with no marker fails" {
  SKILL_KIT_HOME="$kit" run "$CLI" sync
  [ "$status" -eq 1 ]
  [[ "$output" == *"no domain recorded"* ]]
}

@test "a real local file is an override: left untouched and not gitignored" {
  mkdir -p .agents/refs
  echo mine > .agents/refs/g.md
  SKILL_KIT_HOME="$kit" run "$CLI" game sync
  [ "$status" -eq 0 ]
  [ ! -L .agents/refs/g.md ]
  [ "$(cat .agents/refs/g.md)" = "mine" ]
  ! grep -Fxq "g.md" .agents/refs/.gitignore
}

@test "re-sync prunes links whose kit entry was removed upstream" {
  SKILL_KIT_HOME="$kit" "$CLI" game sync
  rm -r "$kit/domains/game/skills/gfoo"
  SKILL_KIT_HOME="$kit" run "$CLI" game sync
  [ "$status" -eq 0 ]
  [ ! -e .agents/skills/gfoo ] && [ ! -L .agents/skills/gfoo ]
  [ -L .agents/skills/common ]   # shared survives
}

@test "a stale whole-dir symlink from an older layout is replaced" {
  mkdir -p old-kit-skills .agents
  ln -s "$PWD/old-kit-skills" .agents/skills
  SKILL_KIT_HOME="$kit" run "$CLI" game sync
  [ "$status" -eq 0 ]
  [ ! -L .agents/skills ] && [ -d .agents/skills ]
  [ -L .agents/skills/gfoo ]
}

@test "update with nothing new upstream says so instead of claiming an update" {
  make_git_kit
  SKILL_KIT_HOME="$kit" run "$CLI" game update
  [ "$status" -eq 0 ]
  [[ "$output" == *"already up to date"* ]]
  [[ "$output" != *"skill-kit: updated"* ]]
  [ -L .agents/skills/gfoo ]   # still re-syncs
}

@test "update with new upstream commits reports updated" {
  make_git_kit
  work="$BATS_TEST_TMPDIR/work"
  git clone -q "$origin" "$work"
  echo new > "$work/newfile"
  git -C "$work" add newfile
  git -C "$work" -c user.email=t@t -c user.name=t commit -qm change
  git -C "$work" push -q
  SKILL_KIT_HOME="$kit" run "$CLI" game update
  [ "$status" -eq 0 ]
  [[ "$output" == *"skill-kit: updated"* ]]
  [[ "$output" != *"already up to date"* ]]
}

@test "self-detects the kit repo when run from its own checkout" {
  env -u SKILL_KIT_HOME "$REPO_ROOT/bin/skill-kit" story sync
  [ -L .agents/skills/write ]
  [ "$(readlink .agents/skills/write)" = "$REPO_ROOT/domains/story/skills/write" ]
  [ -L .agents/skills/setup ]
  [ "$(readlink .agents/skills/setup)" = "$REPO_ROOT/shared/skills/setup" ]
}
