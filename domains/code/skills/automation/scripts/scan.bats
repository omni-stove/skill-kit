#!/usr/bin/env bats
# scan.sh with a gh stub: the org from origin or --org, which repos count as shared (never
# this repo itself), their READMEs, this repo's workflows and tasks, and the next step.

bats_require_minimum_version 1.5.0

setup() {
  SCAN="$BATS_TEST_DIRNAME/scan.sh"
  repo="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$repo/bin" "$repo/readme"
  export STUB_ORG=acme STUB_DIR="$repo"
  cat > "$repo/repos.json" <<'JSON'
[
  {"name": ".github", "description": "Org-wide actions", "isTemplate": false, "isArchived": false},
  {"name": "lint-config", "description": "Shared lint rules", "isTemplate": false, "isArchived": false},
  {"name": "starter", "description": "", "isTemplate": true, "isArchived": false},
  {"name": "spec-ci", "description": "", "isTemplate": false, "isArchived": false},
  {"name": "app", "description": "the app", "isTemplate": false, "isArchived": false},
  {"name": "local", "description": "", "isTemplate": false, "isArchived": false},
  {"name": "me", "description": "Shared me", "isTemplate": false, "isArchived": false},
  {"name": "old", "description": "", "isTemplate": false, "isArchived": true}
]
JSON
  cat > "$repo/trees.json" <<'JSON'
{"data": {
  "r0": {"name": ".github", "rootAction": null,
         "actions": {"entries": [{"name": "setup", "type": "tree", "object": {"entries": [{"name": "action.yml"}]}}, {"name": "README.md", "type": "blob", "object": {}}]},
         "templates": {"entries": [{"name": "ci.yml"}, {"name": "ci.properties.json"}]},
         "workflows": {"entries": [{"name": "ci.yml", "object": {"text": "on:\n  workflow_call:\n"}}, {"name": "release.yml", "object": {"text": "on: push\n"}}]}},
  "r1": {"name": "lint-config", "rootAction": null, "actions": null, "templates": null, "workflows": null},
  "r2": {"name": "starter", "rootAction": null, "actions": null, "templates": null, "workflows": null},
  "r3": {"name": "spec-ci", "rootAction": {"byteSize": 10}, "actions": null, "templates": null,
         "workflows": {"entries": [{"name": "impl-reusable.yml", "object": {"text": "on:\n  workflow_call:\n"}}]}},
  "r4": {"name": "app", "rootAction": null, "actions": null, "templates": null,
         "workflows": {"entries": [{"name": "ci.yml", "object": {"text": "on: pull_request\njobs:\n  ci:\n    uses: acme/.github/.github/workflows/ci.yml@main\n"}}]}},
  "r5": {"name": "local", "rootAction": null, "actions": null, "templates": null, "workflows": null}
}}
JSON
  echo "# .github readme: uses: acme/.github/actions/setup@main" > "$repo/readme/.github"
  echo "# lint-config: npx @acme/lint-config" > "$repo/readme/lint-config"
  cat > "$repo/bin/gh" <<'STUB'
#!/usr/bin/env bash
case "$1 $2" in
  "repo view") [ -n "$STUB_ORG" ] && echo "$STUB_ORG/me" || exit 1 ;;
  "repo list") echo "$3" > "$STUB_DIR/org"; jq -r "${@: -1}" "$STUB_DIR/repos.json" ;;
  "api graphql") cat "$STUB_DIR/trees.json" ;;
  "api -H") p="${4#repos/*/}"; cat "$STUB_DIR/readme/${p%/readme}" 2>/dev/null || { echo "gh: Not Found (HTTP 404)" >&2; exit 1; } ;;
esac
STUB
  chmod +x "$repo/bin/gh"
  PATH="$repo/bin:$PATH"
  cd "$repo" || exit
}

@test "fails without an org when the directory has no GitHub repo" {
  STUB_ORG=
  run "$SCAN"
  [ "$status" -eq 1 ]
  [[ "$output" == *"--org <org>"* ]]
  run "$SCAN" --org other
  [ "$status" -eq 0 ]
  [ "$(cat org)" = other ]
}

@test "lists the shared repos with what they hold, their READMEs, and this repo's state" {
  mkdir -p .github/workflows .mise
  printf 'jobs:\n  ci:\n    uses: acme/.github/.github/workflows/ci.yml@main\n    steps:\n      - uses: actions/checkout@v4\n' > .github/workflows/ci.yml
  printf '[install]\nrun = ":"\n[lint]\nrun = "x"\n' > .mise/tasks.toml
  run "$SCAN"
  [ "$status" -eq 0 ]
  [[ "$output" == *"==> shared in acme (6 repos)"* ]]
  [[ "$output" != *"me"$'\t'* ]]
  [[ "$output" == *$'\n.github\tactions: setup\treusable workflows: ci.yml\tworkflow templates: ci.yml\tOrg-wide actions\n'* ]]
  [[ "$output" == *$'\nlint-config\tShared lint rules\n'* ]]
  [[ "$output" == *$'\nstarter\ttemplate repository\n'* ]]
  [[ "$output" == *$'\nspec-ci\tactions: (root)\treusable workflows: impl-reusable.yml\n'* ]]
  [[ "$output" == *$'==> other repos\napp local\n'* ]]
  [[ "$output" == *$'==> README acme/.github\n# .github readme'* ]]
  [[ "$output" == *$'==> README acme/lint-config\n# lint-config'* ]]
  [[ "$output" == *$'==> README acme/starter\n(no README)'* ]]
  [[ "$output" == *$'==> this repo: .github/workflows\n.github/workflows/ci.yml\n\tuses: acme/.github/.github/workflows/ci.yml@main\n\t- uses: actions/checkout@v4\n'* ]]
  [[ "$output" == *$'==> this repo: tasks\ninstall lint\n'* ]]
  [[ "$output" == *"Pick what this repo takes"* ]]
}

@test "a repo named on the command line is shared; an unknown one is reported" {
  run "$SCAN" app nope
  [ "$status" -eq 0 ]
  [[ "$output" == *$'\napp\tthe app\n'* ]]
  [[ "$output" == *$'==> README acme/app\n(no README)'* ]]
  [[ "$output" == *"scan: nope is not a repository of acme"* ]]
  [[ "$output" == *$'==> this repo: .github/workflows\n(none)\n==> this repo: tasks\n(none)\n'* ]]
}

@test "fails when the org shows no repository or the trees cannot be read" {
  echo '[]' > repos.json
  run "$SCAN"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no repository visible in acme"* ]]
  echo '[{"name": "a", "description": "", "isTemplate": false, "isArchived": false}]' > repos.json
  echo 'gh: bad credentials' > trees.json
  run "$SCAN"
  [ "$status" -eq 1 ]
  [[ "$output" == *"could not read the repos"* ]]
}
