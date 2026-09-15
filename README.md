# skill-kit

Skills for Claude Code, in two domains that share one core:

- **game** — engine-agnostic game-development skills (Unity, Godot, Unreal, custom).
- **story** — language-agnostic authoring skills (any surrounding project).

Plain markdown (`SKILL.md`) + POSIX `sh` — no Node, no npm.

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

skill-kit sync          # re-sync, reusing the domain recorded at the last sync
skill-kit update        # git pull the kit, then re-sync this repo
```

The first sync records the domain (so later `sync`/`update` need no domain argument) and
seeds `AGENTS.md` / `CLAUDE.md` if missing. In a game repo, then run the **`setup`** skill
once in Claude Code — it adapts the kit to the engine via `.agents/refs/engine.sh`.

To **override** a kit-provided skill or ref in one repo, drop a real file of the same name
into the deployed dir — sync leaves real files untouched and keeps them git-tracked.

### Testing skills in the kit repo itself

Run `skill-kit game sync` (or `story`) from inside this repo — the CLI self-detects the
checkout and syncs it into its own `.claude/` / `.agents/` (git-ignored).

## Layout

```
bin/               the skill-kit CLI
.claude/skills/
  create-skill/    scaffold a new skill — the kit's own skill, never deployed
shared/            everything both domains use verbatim
  skills/          setting skills (character, world, item, timeline)
  refs/            llm-instruction-rules.md, doc-rules.md, setting formats
  hooks/           llm-instruction-rules.sh
domains/
  game/            skills (gdd, mechanic, balance, setup, run, …) + refs
  story/           skills (write, plot, dupcheck, judge, …) + refs
```

Skills read and write fixed paths relative to the repo root (`README.md`, `characters/`,
`world/`, `items/`, `plot/`, `story/`; game design docs under `docs/design/`). The only
repo-specific facts are the game engine's, which arrive through `.agents/refs/engine.sh`.

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
