# Code create-skill conventions

Conventions the existing code skills establish — follow them when scaffolding a new one:

- **Run the repo's commands through its tasks:** `make <task> [args]` (= `mise run`). A skill never
  calls a tool binary the repo has not listed under `[tools]` in `mise.toml`, and never installs one.
- **Name the repo's own files directly, relative to the repo root:** `Makefile`, `mise.toml`,
  `.mise/tasks.toml`, `README.md`.
- **Push deterministic work into `scripts/*.sh`** under the skill dir, called from the body in one
  line. The script ends with what to do next, so the body stays at the `Run` lines; its error
  message says what to do when it fails.
- **Load the mise/make rules** through a `` Run `.agents/skills/<name>/refs.sh` `` line right after
  the frontmatter when the skill writes a task, adds a tool, or touches the Makefile; `refs.sh` cats
  `.agents/refs/mise-rules.md`. `chmod +x` the refs.sh. The shared `init` skill is a working example.
- **Share PR plumbing through refs:** `.agents/refs/review-threads.sh`, `.agents/refs/reply-review-thread.sh`,
  `.agents/refs/resolve-review-thread.sh` and `.agents/refs/push-with-merge.sh` are called or
  sourced from a skill's scripts; `fix-pr` and `review-loop` are working examples.
- **Keep each skill self-contained** — never name another skill from the body.
