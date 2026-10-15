# skill-kit

Skills for Claude Code, in three domains that share one core:

- **game** — engine-agnostic game-development skills (Unity, Godot, Unreal, custom).
- **story** — language-agnostic authoring skills (any surrounding project).
- **code** — skills for a software repo (any language).

Plain markdown (`SKILL.md`) + POSIX `sh` — no Node, no npm.

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

## Layout

```
bin/               the skill-kit CLI
.claude/skills/
  create-skill/    scaffold a new skill — the kit's own skill, never deployed
shared/            everything every domain uses verbatim
  skills/          init, task (mise + make), cap, create-pr, and the setting skills
                   (character, world, item, timeline)
  refs/            llm-instruction-rules.md, doc-rules.md, mise-rules.md, push-with-merge.sh,
                   setting formats
  hooks/           llm-instruction-rules.sh
domains/
  game/            skills (gdd, mechanic, balance, setup, run, …) + refs
  story/           skills (write, plot, dupcheck, judge, …) + refs
  code/            skills (automation, remote-issue, fix-pr, review-loop, tour, feature-jsdoc,
                   analyze-repository) + refs (workflow templates, PR thread scripts,
                   feature-jsdoc rules)
```

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
in the package manager's dev dependencies. CI uses `jdx/mise-action` for the tools, a frozen
dependency install, then the same `make <task>` commands — never `make setup`.

The `task` skill adds a command as a task; the rules both skills follow are in
`shared/refs/mise-rules.md`.

`create-pr` opens a PR from the current branch: it reads the branch's PR state, runs the
repo's `generate` task (when there is one) and lists the generated files that belong in the
commit, pushes with `shared/refs/push-with-merge.sh` (a rejected push merges the remote and
retries), and opens the PR with a body of 目的 / 実装方針 / 確認方法 / 見て欲しいポイント.

## Code domain: agent automation

The `automation` skill copies four GitHub Actions workflows from `domains/code/refs/workflows/`
into the repo and creates the labels they fire on:

- `ci.yml` — mise-action, `mise run install`, `make lint`, `make test`.
- `issue-worker.yml` — an issue labeled `bug`, `prototype` or `implementation` is implemented
  by Claude, which pushes a branch and opens a PR (a draft for prototypes).
- `pr-review.yml` — Claude reviews every non-draft PR with inline comments and a
  `Verdict: changes requested` / `Verdict: LGTM` summary, then a second job fixes the
  unresolved threads on the PR branch with one `[agent-fix]` commit.
- `ci-auto-fix.yml` — when CI fails on a PR, Claude fixes the cause from the failed job logs.

Needs the `ANTHROPIC_API_KEY` secret. PRs and pushes made with `GITHUB_TOKEN` do not trigger
other workflows, so set `AGENT_GITHUB_TOKEN` (a PAT or GitHub App token) when agent PRs should
get CI and review too. Three consecutive `[agent-fix]` commits stop the fix jobs.

`init` also copies `domains/code/refs/code-rules.md` (comments say only why-not, generated
files are never hand-edited) into the repo's `AGENTS.md`, so local sessions and the CI agents
follow the same rules.

Around them, three skills for the person driving the work: `remote-issue` splits a task into
labeled issues under a parent so the worker implements them in parallel, `fix-pr` addresses a
PR's review threads and CI failures locally, and `review-loop` waits for the automation to
settle, audits what it pushed, fixes what remains, and repeats until LGTM.

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

## Editing

The kit is plain files under `~/.skill-kit`. Edit, commit, push — every consuming repo sees
it after `skill-kit update`. No publish cycle.

## Test

```sh
make test    # bats over bin, shared, domains
```
