# skill-kit

Skills for coding agents, in three domains that share one core:

- **game** — game development, on any engine (Unity, Godot, Unreal, custom).
- **story** — writing fiction, in any language.
- **code** — working in a software repo, in any language.

Each skill's `README.md` (`shared/skills/<name>/`, `domains/<domain>/skills/<name>/`) shows
what it asks and what it gives back.

## Requirements

`git`, the [GitHub CLI](https://cli.github.com) logged in (`gh auth login`), and
[mise](https://mise.jdx.dev). The target is a git repository.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/omni-stove/skill-kit/main/install.sh | sh
```

This puts `skill-kit` in `~/.local/bin`.

## Set up a repo

The first time, in the repo:

```sh
skill-kit code sync     # or game / story
```

Then run the `init` skill. It puts the repo's tools and commands on mise and
make. In a game repo, also run the `setup` skill to fit the kit to the engine.

After that, anyone who clones the repo runs `make setup`, and `make update` for the latest
kit. Everything else is the agent's.

To change a kit skill for one repo only, put a real file of the same name where the kit's
link is (e.g. `.claude/skills/<name>/`). Sync leaves it alone.

## Hooks

**llm-instruction-rules** shows Claude the house rules for writing instructions whenever it
edits a `SKILL.md`, `AGENTS.md` or a prompt. `init` registers it.

**before-skill** runs a command before a skill and stops the skill when the command fails.
Register it yourself in `.claude/settings.json`, under `hooks.PreToolUse`; this one runs
`make check` before `pr`:

```json
{
  "matcher": "Skill",
  "hooks": [
    { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/before-skill.sh\" pr make check", "timeout": 600 }
  ]
}
```

## Working on the kit

Run `make setup` after cloning and `make update` to pull and re-sync.
