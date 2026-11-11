#!/usr/bin/env bats
# plot-skeleton.sh — writes the plot file from the text given, with every heading always
# written and no way to set Dialogue.

setup() {
  SKEL="$BATS_TEST_DIRNAME/plot-skeleton.sh"
  cd "$BATS_TEST_TMPDIR" || exit
}

@test "plot-skeleton.sh writes every section heading in order when only the required text is given" {
  run sh "$SKEL" story/plot/010-a.md --body 'She leaves.' --length '12000字'
  [ "$status" -eq 0 ]
  [ "$(cat story/plot/010-a.md)" = "$(printf 'She leaves.\n\n## Intent\n\n## Length\n12000字\n\n## Prohibited\n\n## Highlights\n\n## Dialogue\n\n## References')" ]
}

@test "plot-skeleton.sh puts each option's text in its section" {
  run sh "$SKEL" a.md --body 'She leaves.' --intent 'Loss' --length '3000 words' --prohibited '- No hope' --highlights 'The door stayed open.' --references '- @characters/a.md'
  [ "$status" -eq 0 ]
  [ "$(cat a.md)" = "$(printf 'She leaves.\n\n## Intent\nLoss\n\n## Length\n3000 words\n\n## Prohibited\n- No hope\n\n## Highlights\nThe door stayed open.\n\n## Dialogue\n\n## References\n- @characters/a.md')" ]
}

@test "plot-skeleton.sh has no option that sets Dialogue" {
  for opt in --dialogue --conversation; do
    run sh "$SKEL" a.md --body b --length 100字 "$opt" 'Let us go'
    [ "$status" -eq 2 ]
    [ ! -e a.md ]
  done
}

@test "plot-skeleton.sh replaces an existing file and keeps only what the author wrote under Dialogue" {
  printf 'old body\n\n## Intent\nold\n\n## Dialogue\n"Stay," she said.\n\n## References\n- @old.md\n' > a.md
  run sh "$SKEL" a.md --body 'new body' --length '100字'
  [ "$status" -eq 0 ]
  [ "$(cat a.md)" = "$(printf 'new body\n\n## Intent\n\n## Length\n100字\n\n## Prohibited\n\n## Highlights\n\n## Dialogue\n"Stay," she said.\n\n## References')" ]
}

@test "plot-skeleton.sh needs a file" {
  run sh "$SKEL"
  [ "$status" -eq 2 ]
}

@test "plot-skeleton.sh refuses a missing or empty body or length and writes nothing" {
  run sh "$SKEL" a.md --length 100字
  [ "$status" -eq 2 ]
  [[ "$output" == *"--body"* ]]
  run sh "$SKEL" a.md --body b
  [ "$status" -eq 2 ]
  run sh "$SKEL" a.md --body '' --length 100字
  [ "$status" -eq 2 ]
  [ ! -e a.md ]
}

@test "plot-skeleton.sh takes only one line in the units length.sh counts" {
  for bad in 'long' '１００字' '100 chars' "$(printf '100字\n200字')"; do
    run sh "$SKEL" a.md --body b --length "$bad"
    [ "$status" -eq 2 ]
    [ ! -e a.md ]
  done
  for good in '100字' '100 word' '3000 words'; do
    run sh "$SKEL" a.md --body b --length "$good"
    [ "$status" -eq 0 ]
  done
}

@test "plot-skeleton.sh refuses a line starting with a section heading in any text, and leaves the file as it was" {
  echo old > a.md
  for opt in --body --intent --prohibited --highlights --references; do
    run sh "$SKEL" a.md --length 100字 --body b "$opt" "$(printf 'ok\n## Dialogue\nLet us go')"
    [ "$status" -eq 2 ]
    [ "$(cat a.md)" = old ]
  done
}

@test "plot-skeleton.sh lets a subheading or a mid-line ## through" {
  run sh "$SKEL" a.md --body 'See ## here' --length 100字 --highlights '### note'
  [ "$status" -eq 0 ]
}
