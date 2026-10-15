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
  refs/            llm-instruction-rules.md, doc-rules.md, mise-rules.md, setting formats
  hooks/           llm-instruction-rules.sh
domains/
  game/            skills (gdd, mechanic, balance, setup, run, …) + refs
  story/           skills (write, plot, dupcheck, judge, …) + refs
  code/            skills (analyze-repository, …)
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
repo's scripts and Makefile targets into tasks. Everyone after
that runs:

```sh
make setup              # tools + dependencies + skill-kit, on any clone
make test               # = mise run test
mise tasks              # list what the repo can do
```

The `task` skill adds a command as a task; the rules both skills follow are in
`shared/refs/mise-rules.md`.

## LLM-instruction-rules hook

`shared/hooks/llm-instruction-rules.sh` is a PreToolUse hook that injects the house rules
when a Write/Edit targets an LLM-facing instruction file. `sync` deploys the script, but
Claude Code only fires hooks registered in settings — add this once to the repo's
`.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/llm-instruction-rules.sh" }
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
