# Game create-skill conventions

Conventions the existing game skills establish — follow them when scaffolding a new one:

- **Never hardcode engine facts.** Anything engine-specific (log location, source root,
  build/run command, grep pattern) comes from `.agents/refs/engine.sh`. If a value the new
  skill needs isn't defined, add the function name to the default and have the user
  re-generate their repo's override — don't build the value in-model.
- **Name doc paths directly, relative to the repo root.** Design docs live under
  `docs/design/` (`gdd.md`, `mechanics/<slug>.md`, `balance/<slug>.md`,
  `post-mortems/<slug>.md`); setting docs at the root (`README.md`,
  `characters/<category>/<name>.md`, `world/`, `items/`, `story/timeline.md`).
- **Resolve refs inside the skill's `scripts/*.sh`** (`. .agents/refs/engine.sh`), so the
  body stays about the judgment.
- **For a design-doc skill, reference the format** under `.agents/refs/*-format.md`: the skill's
  `refs.sh` cats `doc-rules.md` then the format, rather than restating a template.
- If the skill runs, builds, tests, or edits game code, load the scriptability rules and
  follow them.
