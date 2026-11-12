# skill-kit

Skills for coding agents. Each repo takes one domain, and every domain also gets the shared
skills in `shared/skills/`.

- **[game](domains/game/README.md)** — game development, on any engine (Unity, Godot, Unreal, custom).
- **[story](domains/story/README.md)** — writing fiction, in any language.
- **[code](domains/code/README.md)** — working in a software repo, in any language.

[日本語](README.ja.md)

## Getting started

You need `git`, `curl` and [mise](https://mise.jdx.dev).

1. Put `skill-kit` in `~/.local/bin`.

   ```sh
   curl -fsSL https://raw.githubusercontent.com/omni-stove/skill-kit/main/install.sh | sh
   ```

2. In the target git repo, sync a domain.

   ```sh
   skill-kit code sync     # or game / story
   ```

3. Run the `init` skill. In a game repo, also run the `setup` skill.
4. From then on, ask the `guide` skill what to use for what you want, or what to do next.

Anyone who clones the repo runs `make setup`, and `make update` for the latest kit.

## Changing a skill for one repo only

Put a real file of the same name where the kit's link is
(e.g. `.claude/skills/<name>/`). Sync leaves it alone.

## Working on the kit

Run `make setup` after cloning and `make update` to pull and re-sync.
