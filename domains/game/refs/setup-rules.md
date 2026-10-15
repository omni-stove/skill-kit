# Game setup rules

Read the kit default first — it is the contract you are adapting:
`cat .agents/refs/engine.sh`. The function NAMES are fixed; the values they echo are what
you change for this repo.

This produces one **real** file in this repo: `.agents/refs/engine.sh` — engine-specific
facts (source root, log path, build/run commands, compile/runtime/call-site grep patterns,
and the optional engine-control MCP prefix).

`skill-kit game sync` leaves real files untouched and keeps them git-tracked, so a real file
overrides the kit's symlinked default. Do NOT edit a symlink target, and never
hand-build engine facts elsewhere — every value a skill uses comes from these functions.

## Detect the engine — do not assume

- Identify the engine from the repo: a `*.uproject` → Unreal; `project.godot` → Godot;
  `ProjectSettings/ProjectVersion.txt` or `Assets/` + `*.csproj` → Unity; a `Cargo.toml`
  with a game crate, a `package.json` game framework, etc. Ask if genuinely unclear.
- Find this project's own source root (Unity `Assets/`, Godot project root or `scripts/`,
  Unreal `Source/`, …) versus third-party/engine dirs to keep off-limits.
- Locate the engine's log. Where does the running game's output and its errors go?
  (Unity `~/Library/Logs/Unity/Editor.log`; Godot stdout or `~/.local/share/godot/…`;
  Unreal `Saved/Logs/*.log`.) Confirm the real path exists on this machine.
- Work out the log's shape: what a compile error line looks like, what a runtime
  exception looks like, and how a stack frame names a source file:line. The grep
  patterns must match THIS engine's format.
- Find how the project builds and runs from the shell, or that it can't be scripted
  (editor-driven) — in which case the command function echoes a human instruction.

## Generate the overrides

Walk each default function with the user. Resolve at minimum: `engine_name`,
`source_root`, `third_party`, `runtime_log`, `runtime_log_prev`, `build_log`,
`compile_error_pattern`, `runtime_error_pattern`, `call_site_pattern`, `build_cmd`,
`run_cmd`, `headless_cmd`, `recompile_hint`.

Pay special attention to `headless_cmd`: find this engine's batch/headless launch (Unity
`-batchmode -nographics … -runTests / -executeMethod`, a Godot `--headless` invocation, a
CI build command) and fill in the real binary path and entry point. It's the agent's
primary way to run and test without a GUI (see `scriptability-rules.md`). If the engine
genuinely can't run headless, leave it as a `#` human instruction.

Batch related functions into single `AskUserQuestion` calls (all logs together, all
patterns together) rather than asking one at a time. If a default already fits this repo,
keep it and say so.

Constraints for the generated file:
- Keep EVERY function name from the default, even ones left unchanged — skills depend on
  the full set existing. Never rename, drop, or add functions; only change what they echo.
- Each function echoes exactly one value, nothing else. Paths are relative to the repo
  root with no trailing slash; log paths may be absolute. Grep patterns must be valid for
  `grep -E`/`-oE`.
- Preserve the `$1`/argument convention and the `# $1 = ...` comments where the default
  has them.
- Start the file with `#!/bin/sh` and a one-line comment noting it is this repo's
  override of the kit default, naming the engine.

## Verify

Write the file, overwriting the symlink with a real file. Then resolve a few values and
confirm they match reality:

```sh
sh -c '. .agents/refs/engine.sh; runtime_log; echo "---"; compile_error_pattern'
```

Confirm the log path exists (`ls -l "$(sh -c '. .agents/refs/engine.sh; runtime_log')"`)
and that `compile_error_pattern` actually matches a real error line if the log has one.

## Surface the scriptability rules to the whole repo

`.agents/refs/scriptability-rules.md` is a rule the agent should follow on *every*
task in this repo, not only when a skill happens to read it. Offer to add a one-line
pointer to it in the repo's `CLAUDE.md` (create or append) so it's always in context —
e.g. "Game workflow: follow `.agents/refs/scriptability-rules.md` (no GUI; wire refs and
run headless via script)." Do this only with the user's OK; don't clobber existing
`CLAUDE.md` content — append a line.

## Engine-control MCP (optional)

Leave `control_mcp` echoing an empty string — reading errors, reading logs, and running
the game then use the log-scraping fallback, which always works. Wiring an engine-control
MCP (to trigger recompiles, enter Play Mode, run tests, read the live console via a
structured API) is a separate opt-in step that sets `control_mcp` to the server's tool
prefix. Don't fabricate an MCP server to fill it in.

## Expose build and test as tasks

When `.mise/tasks.toml` exists, add a `build` task running `build_cmd` and a `test` task
running `headless_cmd`, each with a `description`. Skip a task whose command is a `#` human
instruction.

## Verify & report

Finally run `git status` and confirm `.agents/refs/engine.sh` appears in it as a real file
(not a symlink, not ignored), and that nothing else changed. Tell the user the override is in place
and will survive `skill-kit game sync` / `update`, and that the log fallback
is in use until an engine-control MCP is wired up.
