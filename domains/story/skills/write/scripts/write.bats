#!/usr/bin/env bats
# source.sh — deterministic resolution of the source and its output file.

setup() {
  SOURCE="$BATS_TEST_DIRNAME/source.sh"
  work="$BATS_TEST_TMPDIR/work"
  mkdir -p "$work/.agents/refs" "$work/story/plot"
  cat > "$work/.agents/refs/path" <<'SH'
#!/bin/sh
case $2 in
  story) echo "story" ;;
  story_plot_file) echo "story/plot/$3.md" ;;
  story_body_file) echo "story/$3.md" ;;
esac
SH
  chmod +x "$work/.agents/refs/path"
  cd "$work"
}

@test "source.sh resolves plot/<title>.md through the layout" {
  : > story/plot/010-co-arrival.md
  run sh "$SOURCE" co plot/010-co-arrival.md
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Source: story/plot/010-co-arrival.md" ]
}

@test "source.sh resolves a bare plot title" {
  : > story/plot/arrival.md
  run sh "$SOURCE" co arrival
  [ "${lines[0]}" = "Source: story/plot/arrival.md" ]
}

@test "source.sh resolves <chapter>.md to the body file" {
  : > story/03.md
  run sh "$SOURCE" co 03.md
  [ "${lines[0]}" = "Source: story/03.md" ]
}

@test "source.sh takes an existing path as-is" {
  mkdir -p elsewhere
  : > elsewhere/draft.md
  run sh "$SOURCE" co elsewhere/draft.md
  [ "${lines[0]}" = "Source: elsewhere/draft.md" ]
}

@test "source.sh names the output after the source's leading number" {
  : > story/plot/010-co-arrival.md
  run sh "$SOURCE" co plot/010-co-arrival.md
  [ "${lines[1]}" = "Output: story/010.txt" ]
}

@test "source.sh names the output after the whole stem when there is no leading number" {
  : > story/plot/arrival.md
  run sh "$SOURCE" co arrival
  [ "${lines[1]}" = "Output: story/arrival.txt" ]
}

@test "source.sh says to start fresh when the output is missing" {
  : > story/plot/arrival.md
  run sh "$SOURCE" co arrival
  [[ "$output" == *"does not exist yet"* ]]
}

@test "source.sh says to read and ask when the output exists" {
  : > story/plot/010-co-arrival.md
  : > story/010.txt
  run sh "$SOURCE" co plot/010-co-arrival.md
  [[ "$output" == *"Read it, ask"* ]]
}

@test "source.sh fails on a missing source" {
  run sh "$SOURCE" co missing
  [ "$status" -eq 1 ]
}
