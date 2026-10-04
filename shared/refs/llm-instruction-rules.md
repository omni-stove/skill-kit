# Rules for writing any LLM-facing instruction (SKILL.md, AGENTS.md, prompts, command/workflow defs)

Hold only what the LLM must judge.

- Cut the obvious.
- Write the action to take, not the reason, the example, or what kind of step it is.
- Describe forces rather than binding judgment to a fixed label.
- Write in the positive. Add a prohibition only when the wrong path is tempting and non-obvious.
- Grant judgment explicitly.
- Check the real files and configs; write the actual case.

- Order the body by the reader's workflow; order carries sequence. Add a heading or step number only where it scopes a rule set or is referenced by name elsewhere; otherwise a plain lead-in line is enough.
- Define each thing once. State what it does in one place; let the steps carry the rest.
- Lead each step with the command; only its arguments are left to decide.
- Keep the frontmatter `description` to the trigger and the shape of the work, not the full procedure.

## SKILL.md only

- Keep each skill self-contained: never reference another skill from a skill body. Share overlapping behavior through the refs mechanism; cut "for X, use the Y skill" notes.
- Push deterministic work into `scripts/*.sh` the skill calls in one line.
- Merge consecutive deterministic scripts; split only across an LLM judgment.
- Write a command the skill runs as the command and its arguments alone. The script prints whatever else the reader needs to act on its output, its error message says what to do when it fails, and it prints nothing more.
- Keep rule sets shared across skills in `.agents/refs/<name>-rules.md`. Load them with a `` Run `.agents/skills/<name>/refs.sh` `` line directly after the frontmatter, where `refs.sh` cats the refs file — not the Claude-only `` !`command` `` injection. In the body say "the loaded rules", never the refs path.
