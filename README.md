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
gh api repos/omni-stove/skill-kit/contents/install.sh -q .content | base64 -d | sh
```

Clones the kit to `~/.skill-kit` and links `skill-kit` into `~/.local/bin`. The installer
runs `gh auth setup-git` so `skill-kit update` can keep pulling the private repo.

> Fetch `install.sh` via `gh api` (not `curl`): because the repo is private,
> `raw.githubusercontent.com` doesn't see your GitHub credentials and returns 404, so a
> plain `curl -fsSL https://raw.githubusercontent.com/…/install.sh | sh` fails at that step.
> `gh api` authenticates, so it works.

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
repo, writing a per-project layout file (`.agents/refs/layouts/<id>.sh`) for each project,
plus, in game, the `engine.sh` override. Skills read from those; nothing repo-specific is
hardcoded.

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
    character/     setting skills that make sense in either domain — deployed to
    world/         both game and story. Domain-neutral bodies; they ask
    item/          `.agents/refs/path` for every path and never learn how it
    timeline/      resolves.
  refs/
    path                       resolves <project-id> <what> to a path (both domains)
    llm-instruction-rules.md   house rules for LLM-facing instruction files
  hooks/
    llm-instruction-rules.sh   PreToolUse hook that injects those rules
domains/
  game/
    skills/        gdd, mechanic, balance, run, fix, logs, setup-mcp
    refs/          engine.sh, layout.sh, layout-template.sh, *-format.md,
                   scriptability-rules.md, setup-rules.md, create-skill-rules.md
  story/
    skills/        write, plot, dupcheck, judge, …
    refs/          layout.sh, layout-template.sh, *-format.md, *-rules.md,
                   contest-rules/, setup-rules.md, create-skill-rules.md
```

## How the shared skills stay one skill for two domains

A skill lives in `shared/skills/` when its body is domain-agnostic and only its
*content or paths* differ per domain. Two flavors of this:

**Meta-skills — differ by loaded rules.** `setup` and `create-skill` are identical in
shape across domains but differ in content (game setup wires an engine + logs; story setup
wires a file layout). Rather than ship two copies, each lives once in `shared/skills/`. Its
`refs.sh` reads the domain marker and `cat`s that domain's rules —
`domains/<domain>/refs/setup-rules.md` or `create-skill-rules.md` — which `sync` has
already deployed into `.agents/refs/`. The skill body stays domain-agnostic; the
domain-specific instructions arrive as "the loaded rules".

**Setting skills — differ by layout only.** `character`, `world`, `item`, and `timeline`
describe things that exist in both a game and a story. Their bodies never name a path and
never learn how one resolves: they call `.agents/refs/path <project-id> <what> [name]` and
use the line it prints. `path` sources the domain's `.agents/refs/layout.sh`, which maps
the id to that project's own layout file (`.agents/refs/layouts/<id>.sh`) and sources it;
the project's structural functions then echo the concrete path. Those per-project files —
scaffolded from `layout-template.sh` by `setup` — carry the whole base, so a project can
live anywhere on disk (this repo, a sibling, an absolute path), with no assumed `src/` or
`docs/design/` root. The id → file rule is one overridable line; the skill sees none of it.

Either way the shared skills carry no special-casing — `sync` deploys them to both domains
verbatim, and the domain supplies the difference through refs.

## How deployment works

`sync` symlinks each entry (shared first, then the chosen domain) into the target repo and
writes a `.gitignore` listing exactly what the kit owns, so kit-provided files are never
committed. Skills and hooks deploy to both `.claude/` and `.agents/`; refs deploy to
`.agents/refs/` only. To **override** a ref or skill in one repo, drop a real file of the
same name into the deployed dir — `sync` detects the real file, leaves it untouched, and
keeps it git-tracked.

Skills never hardcode repo facts or paths. Everything repo-specific comes from
`.agents/refs/` — a project path from `.agents/refs/path <project-id> <what> [name]`, an
engine fact from `sh -c '. .agents/refs/engine.sh; runtime_log'` — and the skill uses what
it prints, so the kit never builds a value in-model. The `setup` skill walks you through
generating the per-project layout files and engine overrides for your repo.

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
