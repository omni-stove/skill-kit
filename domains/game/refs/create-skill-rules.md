# Game create-skill conventions

Conventions the existing game skills establish — follow them when scaffolding a new one:

- **Never hardcode engine facts or paths.** Anything engine-specific (log location, source
  root, build/run command, grep pattern) comes from `.agents/refs/engine.sh`; a game-design
  doc path (gdd / mechanics / balance / levels) comes from `.agents/refs/layout.sh`; a
  per-project setting path comes from `.agents/refs/path <project-id> <what> [name]`. If a
  value the new skill needs isn't defined, add the function name to the matching ref default
  and have the user re-generate their repo's override — don't build the value in-model.
- **Resolve refs inside the skill's `scripts/*.sh`** (`. .agents/refs/engine.sh`), so the
  body stays about the judgment.
- **For a design-doc skill, reference the format** under `.agents/refs/*-format.md` (cat it
  in the skill's context script) rather than restating a template.
- If the skill runs, builds, tests, or edits game code, load the scriptability rules and
  follow them.
