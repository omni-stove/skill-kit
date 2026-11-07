#!/usr/bin/env bats
# plot-skeleton.sh — the fixed plot file skeleton.

setup() {
  SKEL="$BATS_TEST_DIRNAME/plot-skeleton.sh"
  cd "$BATS_TEST_TMPDIR" || exit
}

@test "plot-skeleton.sh writes every section heading in order, with the placeholder under the dialogue heading" {
  run sh "$SKEL" story/plot/010-a.md
  [ "$status" -eq 0 ]
  [ "$(cat story/plot/010-a.md)" = "$(printf '\n## プロットの意図\n\n## 禁止事項\n\n## ハイライト\n\n## セリフ\n<!-- 指示があるまでこの項目に追加しない -->\n\n## 参照')" ]
}

@test "plot-skeleton.sh replaces an existing file and writes each file given" {
  mkdir -p story/plot
  echo old > story/plot/010-a.md
  run sh "$SKEL" story/plot/010-a.md story/plot/020-b.md
  [ "$status" -eq 0 ]
  ! grep -q old story/plot/010-a.md
  cmp story/plot/010-a.md story/plot/020-b.md
}

@test "plot-skeleton.sh needs a file" {
  run sh "$SKEL"
  [ "$status" -eq 2 ]
}

@test "plot-skeleton.sh prints how to fill the file" {
  run sh "$SKEL" story/plot/010-a.md
  [ "${lines[0]}" = "Write the plot body above the first heading and each section under its heading." ]
}
