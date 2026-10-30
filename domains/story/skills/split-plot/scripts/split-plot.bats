#!/usr/bin/env bats
# segments.sh — each splitter's segment count and titles; paths.sh — deterministic output
# paths for the split segments.

setup() {
  PATHS="$BATS_TEST_DIRNAME/paths.sh"
  SEGMENTS="$BATS_TEST_DIRNAME/segments.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/story/plot"
  cd "$work" || exit
}

@test "paths.sh numbers from 010 by tens in an empty story/plot/" {
  run sh "$PATHS" co arrival first-night
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "story/plot/010-co-arrival.md" ]
  [ "${lines[1]}" = "story/plot/020-co-first-night.md" ]
  [[ "${lines[2]}" == "Create each plot file"* ]]
}

@test "paths.sh numbers from 010 when story/plot/ is missing" {
  rmdir story/plot
  run sh "$PATHS" co arrival
  [ "${lines[0]}" = "story/plot/010-co-arrival.md" ]
}

@test "paths.sh continues from the next ten after the highest number" {
  : > story/plot/010-co-arrival.md
  : > story/plot/085-co-detour.md
  : > story/plot/memo.md
  run sh "$PATHS" co return
  [ "${lines[0]}" = "story/plot/090-co-return.md" ]
}

@test "paths.sh steps past a number already on a ten" {
  : > story/plot/090-co-return.md
  run sh "$PATHS" co epilogue
  [ "${lines[0]}" = "story/plot/100-co-epilogue.md" ]
}

@test "paths.sh rejects a slug that is not kebab-case" {
  run sh "$PATHS" co "First Night"
  [ "$status" -eq 1 ]
}

@test "paths.sh needs a base and at least one slug" {
  run sh "$PATHS" co
  [ "$status" -eq 2 ]
}

@test "segments.sh counts the segments each splitter yields and names them" {
  cat > story/draft.md <<'MD'
# Title

## 出会い
- 朝、港で会う
- 名前を聞く

---

## 別れ
夜、船が出る。

【場面3】
戻ってこない。
MD
  run sh "$SEGMENTS" story/draft.md
  [ "$status" -eq 0 ]
  [[ "$output" == *"== headings (2) =="* ]]
  [[ "$output" == *"$(printf '1\t## 出会い')"* ]]
  [[ "$output" == *"$(printf '2\t## 別れ')"* ]]
  [[ "$output" == *"== rules (2) =="* ]]
  [[ "$output" == *"== bullets (2) =="* ]]
  [[ "$output" == *"== blocks (5) =="* ]]
  [[ "$output" == *"== markers: no split =="* ]]
  [[ "$output" != *"【場面3】"* ]]
  [[ "$output" == *"paths.sh <base name>"* ]]
}

@test "segments.sh fails on a missing source" {
  run sh "$SEGMENTS" story/none.md
  [ "$status" -eq 1 ]
}
