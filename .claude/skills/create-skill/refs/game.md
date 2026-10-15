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
- **Resolve refs inside the skill's `scripts/*.sh`** (`. .agents/refs/engine.sh`), and end the
  script with what to do next, so the body stays at the `Run` lines.
- **Keep what a script says to the reader in `prompts/<step>.txt`** beside `scripts/`, one file per
  message. The script sources `. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"` and
  prints a file with `prompt <step> key=value...`; `{key}` in the file is the value the script
  fills in, an engine fact among them. `fix` is a working example.
- **For a design-doc skill, reference the format** under `.agents/refs/*-format.md`: the skill's
  `refs.sh` cats `doc-rules.md` then the format, rather than restating a template.
- If the skill runs, builds, tests, or edits game code, load the scriptability rules and
  follow them.
- **Run the repo's commands through its tasks:** `make <task> [args]` (= `mise run`), never a tool
  binary the repo has not listed under `[tools]` in `mise.toml`. A skill that adds a task or a tool
  loads `.agents/refs/mise-rules.md` through its `refs.sh`.
