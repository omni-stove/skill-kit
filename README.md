# skill-kit

Skills for Claude Code, in three domains that share one core:

- **game** — engine-agnostic game-development skills (Unity, Godot, Unreal, custom).
- **story** — language-agnostic authoring skills (any surrounding project).
- **code** — skills for a software repo (any language).

Plain markdown (`SKILL.md`) + POSIX `sh` + plain text (`prompts/*.txt`) — no Node, no npm.

Prerequisites, on every machine: `git`, an authenticated [GitHub CLI](https://cli.github.com)
(`gh auth login`), and [mise](https://mise.jdx.dev). The target is always a git repository
(`init` creates one if needed) — the kit is cloned and pulled with git, and overrides live as
files the repo tracks.

## Install

skill-kit is a **private** repo — the installer needs an authenticated
[GitHub CLI](https://cli.github.com). (`curl` against `raw.githubusercontent.com`
gets a 404 on a private repo; `gh api` authenticates.)

```sh
gh auth login   # once, if you haven't already
gh api repos/omni-stove/skill-kit/contents/install.sh -q .content | base64 -d | sh
```

Clones the kit to `~/.skill-kit` and links `skill-kit` into `~/.local/bin`.

## Use

```sh
skill-kit game sync     # symlink shared + game skills/hooks/refs into ./.claude and ./.agents
skill-kit story sync    # symlink shared + story skills/hooks/refs
skill-kit code sync     # symlink shared + code skills/hooks/refs

skill-kit sync          # re-sync, reusing the domain recorded at the last sync
skill-kit update        # git pull the kit, then re-sync this repo
```

The first sync records the domain (so later `sync`/`update` need no domain argument) and
seeds `AGENTS.md` / `CLAUDE.md` if missing. Then run the **`init`** skill once in Claude Code —
it puts the repo on mise + make (see below). In a game repo, also run the **`setup`** skill,
which adapts the kit to the engine via `.agents/refs/engine.sh`.

To **override** a kit-provided skill or ref in one repo, drop a real file of the same name
into the deployed dir — sync leaves real files untouched and keeps them git-tracked.

### Testing skills in the kit repo itself

Run `skill-kit game sync` (or `story` / `code`) from inside this repo — the CLI self-detects the
checkout and syncs it into its own `.claude/` / `.agents/` (git-ignored).

## Skills

A skill is a `SKILL.md` that runs `scripts/*.sh`; what a script says to the LLM — the next
step, the judgment to make — lives in `prompts/<step>.txt` beside it, printed through
`shared/refs/prompt.sh` with the script's values filled into `{key}` placeholders. So the
words are read and edited as prose, and the scripts stay code.

Skills read and write fixed paths relative to the repo root (`README.md`, `characters/`,
`world/`, `items/`, `story/`, `story/plot/`; game design docs under `docs/design/`). The only
repo-specific facts are the game engine's, which arrive through `.agents/refs/engine.sh`.

## mise + make (every domain)

A synced repo lists every tool it runs under `[tools]` in `mise.toml` (by major version) and
defines every command as a mise task in `.mise/tasks.toml`. The `Makefile` is an alias layer:
`make <task> [args]` runs `mise run <task> [args]` (flags go through `ARGS="--flag"`), and
`make setup` is the one target make owns — it checks for git, gh and mise, then runs
`mise trust`, `mise install` and the `setup` task, which installs the repo's dependencies and
syncs skill-kit for the repo's recorded domain.

The first person bootstraps by hand, once:

```sh
gh api repos/omni-stove/skill-kit/contents/install.sh -q .content | base64 -d | sh
skill-kit code sync     # or game / story
```

then runs the `init` skill in Claude Code, which runs `git init` if the directory is not a
repository yet, generates the three files, proposes a major version per tool, and turns the
repo's scripts and Makefile targets into tasks. Run `init` again after a kit update: it diffs
what the kit generates against what the repo has and adds only what is missing — a newer
forwarding Makefile, a task the kit now expects, a changed rules block in `AGENTS.md` — and
never touches what a person wrote. Everyone after
that runs:

```sh
make setup              # tools + dependencies + skill-kit, on any clone
make test               # = mise run test
mise tasks              # list what the repo can do
```

A tool with its own binary (runtime, package manager, `biome`, `rust`, `terraform`) goes in
`[tools]`; a tool that runs on the runtime or loads npm plugins (`vitest`, `turbo`, `vite`) goes
in the package manager's dev dependencies.

The `task` skill adds a command as a task; the rules both skills follow are in
`shared/refs/mise-rules.md`.

`pr` opens a PR from the current branch: it reads the branch's PR state, reruns generate for
the changed paths (scoped to their packages and dependents under turbo, else the repo's
`generate` task) and lists the generated files that belong in the commit, pushes with `shared/refs/push-with-merge.sh` (a rejected push merges the remote and retries),
and opens the PR with a body of 目的 / 実装方針 / 確認方法 / 見て欲しいポイント.

## Code domain: the org's shared automation

The kit ships no CI of its own. The `automation` skill adopts what the org already shares:
`scan.sh` lists the repos of the org behind `origin` (or `--org`), marks each one that holds
composite actions (`action.yml` at the root or under `actions/`), reusable workflows
(`workflow_call`), workflow templates or a template repo, or whose description says shared,
and prints that repo's README — the install instructions are the repo's own — followed by
this repo's current workflows (with their `uses:` lines) and mise tasks. A repo named on the
command line is listed whether or not it looks shared. The skill then installs what applies
the way each README says, with the inputs filled from the repo's tasks, and hands the user
what the README leaves to them: secrets, labels, rulesets, App installs.

`init` also copies `domains/code/refs/code-rules.md` (comments say only why-not, generated
files are never hand-edited) into the repo's `AGENTS.md`, so local sessions and agents that
run in CI follow the same rules.

Two skills for the person driving the work against that automation: `remote-issue` splits
a task into labeled issues under a parent so an issue worker implements them in parallel, and
`fix-pr` addresses a PR's review threads and CI failures locally.

Two skills keep a frontend's feature catalog: `feature-jsdoc` adds or audits the `@feature`
JSDoc on UI components by the rules in `domains/code/refs/feature-jsdoc-rules.md`, and `tour`
walks a new member through the app from those blocks.

## LLM-instruction-rules hook

`shared/hooks/llm-instruction-rules.sh` is a PreToolUse hook that injects the house rules for
writing anything an LLM reads (SKILL.md, AGENTS.md, prompts, workflow defs) when a Write/Edit
targets such a file. `sync` deploys the script and `init` registers it in the repo's
`.claude/settings.json` — creating the file, or merging this entry into an existing one with
`jq` (without `jq`, `init` prints the entry to add by hand):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/llm-instruction-rules.sh\"" }
        ]
      }
    ]
  }
}
```

## before-skill hook

`shared/hooks/before-skill.sh <skill> <command>...` is a PreToolUse hook on `Skill` that runs
the command before the named skill and denies the skill with the command's output when it
fails. The kit ships only the mechanism: which skill and which command are the repo's call,
given as the hook's arguments in its `.claude/settings.json`. `sync` deploys the script;
nothing registers it for you. To run `make check` before the `pr` skill:

```json
{
  "matcher": "Skill",
  "hooks": [
    { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/before-skill.sh\" pr make check", "timeout": 600 }
  ]
}
```

The timeout is the command's: Claude Code stops a hook after 60 s otherwise.

## Editing

The kit is plain files under `~/.skill-kit`. Edit, commit, push — every consuming repo sees
it after `skill-kit update`. No publish cycle.

## Test

```sh
make test    # bats over bin, shared, domains
```
