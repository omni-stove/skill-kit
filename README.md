# skill-kit

Skills for Claude Code, in two domains that share one core:

- **game** — engine-agnostic game-development skills (Unity, Godot, Unreal, custom).
- **story** — language-agnostic authoring skills (any surrounding project).

Plain markdown (`SKILL.md`) + POSIX `sh` — no Node, no npm. This kit merges the former
`game-kit` and `story-kit`: the pieces both used verbatim now live once in `shared/`, and
each domain keeps its own skills and refs under `domains/`.

## Install

skill-kit is a **private** repo — access is gated by your GitHub read permission. The
installer requires an authenticated [GitHub CLI](https://cli.github.com); users without
access are rejected by GitHub at clone time.

```sh
gh auth login   # once, if you haven't already
curl -fsSL https://raw.githubusercontent.com/omni-stove/skill-kit/main/install.sh | sh
```

Clones the kit to `~/.skill-kit` and links `skill-kit` into `~/.local/bin`. The installer
runs `gh auth setup-git` so `skill-kit update` can keep pulling the private repo.

> If `raw.githubusercontent.com` 404s (the URL also needs read access), fetch via
> `gh api repos/omni-stove/skill-kit/contents/install.sh -q .content | base64 -d | sh`.

## Use

Pick the domain once per repo — a game repo gets the game skills, a writing repo the story
skills. Each repo only ever sees the domain it asked for, plus the shared core.

```sh
skill-kit game sync     # symlink shared + game skills/hooks/refs into ./.claude and ./.agents
skill-kit story sync    # symlink shared + story skills/hooks/refs

skill-kit sync          # re-sync, reusing the domain recorded at the last sync
skill-kit update        # git pull the kit, then re-sync this repo (domain remembered)
```

`sync` records the chosen domain in `.agents/refs/domain` (a real, tracked file), so after
the first `skill-kit <domain> sync` you can just run `skill-kit sync` / `skill-kit update`
with no domain — it reuses what the repo recorded. Pass the domain explicitly any time to
switch or to be unambiguous.

Then, once per repo, run the **`setup`** skill in Claude Code — it adapts the kit to this
repo and writes the real `.agents/refs/*.sh` overrides (game: `engine.sh` + `layout.sh`;
story: `layout.sh`). Skills read from those; nothing repo-specific is hardcoded.

### Testing skills in the kit repo itself

Run `skill-kit game sync` (or `story`) from inside this repo to symlink the kit into its
own `.claude/` and `.agents/` — the CLI self-detects that it's running from the kit and
uses this checkout as `SKILL_KIT_HOME`. Lets you exercise skills locally before pushing.
The generated `.claude/` / `.agents/` are git-ignored.

## Layout

```
bin/               the skill-kit CLI
shared/            everything both domains use verbatim
  skills/
    setup/         adapt the kit to this repo — dispatches on the recorded domain
    create-skill/  scaffold a new skill — dispatches on the recorded domain
  refs/
    llm-instruction-rules.md   house rules for LLM-facing instruction files
  hooks/
    llm-instruction-rules.sh   PreToolUse hook that injects those rules
domains/
  game/
    skills/        gdd, mechanic, balance, run, fix, logs, setup-mcp
    refs/          engine.sh, layout.sh, *-format.md, scriptability-rules.md,
                   setup-rules.md, create-skill-rules.md
  story/
    skills/        write, plot, character, world, dupcheck, judge, …
    refs/          layout.sh, *-format.md, *-rules.md, contest-rules/,
                   setup-rules.md, create-skill-rules.md
```

## How the shared skills stay one skill for two domains

`setup` and `create-skill` are identical in shape across domains but differ in content
(game setup wires an engine + logs; story setup wires a file layout). Rather than ship two
copies, each lives once in `shared/skills/`. Its `refs.sh` reads the domain marker and
`cat`s that domain's rules — `domains/<domain>/refs/setup-rules.md` or
`create-skill-rules.md` — which `sync` has already deployed into `.agents/refs/`. The
skill body stays domain-agnostic; the domain-specific instructions arrive as "the loaded
rules". This is the same refs mechanism the other skills use, so the shared skills carry no
special-casing beyond one `cat`.

## How deployment works

`sync` symlinks each entry (shared first, then the chosen domain) into the target repo and
writes a `.gitignore` listing exactly what the kit owns, so kit-provided files are never
committed. Skills and hooks deploy to both `.claude/` and `.agents/`; refs deploy to
`.agents/refs/` only. To **override** a ref or skill in one repo, drop a real file of the
same name into the deployed dir — `sync` detects the real file, leaves it untouched, and
keeps it git-tracked.

Skills never hardcode repo facts or paths. Everything repo-specific comes from
`.agents/refs/*.sh` — POSIX-sh functions that echo a resolved value. A skill runs
`sh -c '. .agents/refs/layout.sh; story_synopsis co'` (or, in game, `engine.sh; runtime_log`)
and uses what it prints, so the kit never builds a value in-model. The `setup` skill walks
you through generating the overrides for your repo.

## LLM-instruction-rules hook

`shared/hooks/llm-instruction-rules.sh` is a PreToolUse hook: when a Write/Edit targets an
LLM-facing instruction file (`SKILL.md`, `AGENTS.md`, `CLAUDE.md`, or anything under
`.claude/commands/` · `.agents/skills/` · `.claude/workflows/`), it injects
`shared/refs/llm-instruction-rules.md` as additional context. It never blocks — non-matching
paths exit silently. `sync` symlinks the script into `.claude/hooks/` and `.agents/hooks/`,
but Claude Code only fires a hook registered in settings. Add this once to the repo's
`.claude/settings.json` (merge into an existing `hooks` block if present):

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
