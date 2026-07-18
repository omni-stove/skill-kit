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
seeds `AGENTS.md` / `CLAUDE.md` if missing. Then run the **`setup`** skill once in Claude
Code — it adapts the kit to the repo via files under `.agents/refs/`.

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
  skills/          setup + setting skills (character, world, item, timeline)
  refs/            path resolver, llm-instruction-rules.md
  hooks/           llm-instruction-rules.sh
domains/
  game/            skills (gdd, mechanic, balance, run, …) + refs
  story/           skills (write, plot, dupcheck, judge, …) + refs
```

Shared skills are domain-agnostic: they never hardcode a repo fact or path. Everything
repo-specific arrives through `.agents/refs/` (the `path` resolver, `layout.sh`,
`engine.sh`, per-domain rules files), so one skill body serves both domains and any repo.

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
