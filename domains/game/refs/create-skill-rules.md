# Game create-skill conventions

Conventions the existing game skills establish — follow them when scaffolding a new one:

- **Never hardcode engine facts or paths.** Anything engine-specific (log location, source
  root, build/run command, grep pattern) comes from `.agents/refs/engine.sh`; any doc path
  comes from `.agents/refs/layout.sh`. If a value the new skill needs isn't defined in a
  ref, add the function to the ref's default and have the user re-generate their repo's
  override — don't build the value in-model.
- **Push deterministic work into `scripts/*.sh`** under the skill dir, called from the body
  in one line. Merge consecutive deterministic steps into one script; split only across a
  point where the skill needs to judge. Resolve refs inside the script
  (`. .agents/refs/engine.sh`), so the body stays about the judgment.
- **Load a shared rule set via a `` Run `.agents/skills/<name>/refs.sh` `` line** directly
  after the frontmatter, where `refs.sh` cats the rule set from `.agents/refs/`; refer to
  it in the body as "the loaded rules". A rule set used by more than one skill lives in
  `.agents/refs/<topic>-rules.md`.
- **For a design-doc skill, reference the format** under `.agents/refs/*-format.md` (cat it
  in the skill's context script) rather than restating a template.
- **Keep each skill self-contained** — never name another skill from the body. Share
  overlapping behavior through the refs mechanism instead of "for X, use the Y skill".
- If the skill runs, builds, tests, or edits game code, load the scriptability rules and
  follow them (no GUI; run headless; wire object references in code, not the Inspector).
