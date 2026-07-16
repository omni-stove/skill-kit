# Game setup rules

Read the kit defaults first — they are the contract you are adapting:
`cat .agents/refs/engine.sh .agents/refs/layout.sh`. In both files the function NAMES are
fixed; the values they echo are what you change for this repo.

This produces up to two **real** files in this repo, plus one per project that uses the
shared setting skills:
- `.agents/refs/engine.sh` — engine-specific facts (source root, log path, build/run
  commands, compile/runtime/call-site grep patterns, and the optional engine-control MCP
  prefix).
- `.agents/refs/layout.sh` — where this repo keeps its game-design docs (gdd / mechanics /
  balance / levels). It also carries the resolver the setting skills use; leave that part
  alone.
- `.agents/refs/layouts/<id>.sh` — one per project that uses `character` / `world` / `item`
  / `timeline`, copied from `.agents/refs/layout-template.sh` and pointed at where that
  project keeps its setting docs (anywhere on disk).

Wiring an engine-control MCP is a separate, optional step; by default `control_mcp` stays
empty and the kit reads errors, logs, and runs the game from the log fallback.

`skill-kit game sync` leaves real files untouched and keeps them git-tracked, so a real file
overrides the kit's symlinked default. Do NOT edit a symlink target, and never
hand-build engine facts or paths elsewhere — every value a skill uses comes from these
functions.

First, confirm the kit is synced: if `sh -c '. .agents/refs/engine.sh; engine_name'`
errors, tell the user to run `skill-kit game sync` first and stop.

## Detect the engine and layout — do not assume

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
- Find where design docs live (`docs/`, `design/`, none yet). Read the disk; ask when
  empty.

## Generate the overrides

Walk each default function with the user. For `engine.sh`, resolve at minimum:
`engine_name`, `source_root`, `third_party`, `runtime_log`, `runtime_log_prev`,
`build_log`, `compile_error_pattern`, `runtime_error_pattern`, `call_site_pattern`,
`build_cmd`, `run_cmd`, `headless_cmd`, `recompile_hint`. For `layout.sh`: `design_root`,
`gdd_file`, `mechanics`/`mechanic_file`, `balance`/`balance_file`, `levels`/`level_file`
— the game's own design docs. Leave the `project_layout` / `load_project` resolver below
them untouched.

When the game uses the shared setting skills, generate a per-project layout file too: copy
`.agents/refs/layout-template.sh` to `.agents/refs/layouts/<id>.sh`, point `_base` at where
that project keeps its characters / world / items / timeline, and keep every function name.

Pay special attention to `headless_cmd`: find this engine's batch/headless launch (Unity
`-batchmode -nographics … -runTests / -executeMethod`, a Godot `--headless` invocation, a
CI build command) and fill in the real binary path and entry point. It's the agent's
primary way to run and test without a GUI (see `scriptability-rules.md`). If the engine
genuinely can't run headless, leave it as a `#` human instruction.

Batch related functions into single `AskUserQuestion` calls (all logs together, all
patterns together) rather than asking one at a time. If a default already fits this repo,
keep it and say so.

Constraints for each generated file:
- Keep EVERY function name from the default, even ones left unchanged — skills depend on
  the full set existing. Never rename, drop, or add functions; only change what they echo.
- Each function echoes exactly one value, nothing else. Paths are relative to the repo
  root with no trailing slash; log paths may be absolute. Grep patterns must be valid for
  `grep -E`/`-oE`.
- Preserve the `$1`/argument convention and the `# $1 = ...` comments where the default
  has them.
- Start each file with `#!/bin/sh` and a one-line comment noting it is this repo's
  override of the kit default, naming the engine.

## Verify

Write the files, overwriting the symlinks with real files. Then resolve a few values and
confirm they match reality:

```sh
sh -c '. .agents/refs/engine.sh; runtime_log; echo "---"; compile_error_pattern'
sh -c '. .agents/refs/layout.sh; gdd_file; mechanic_file demo'
.agents/refs/path <id> characters_main テスト   # only if a per-project layout file was made
```

Confirm the log path exists (`ls -l "$(sh -c '. .agents/refs/engine.sh; runtime_log')"`)
and that `compile_error_pattern` actually matches a real error line if the log has one.

## Surface the scriptability rules to the whole repo

`.agents/refs/scriptability-rules.md` (headless over GUI, wire object references in code
not the Inspector, observe through logs) is a rule the agent should follow on *every*
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

## Verify & report

Finally run `git status` and confirm the two `.agents/refs/*.sh` files show as real,
tracked files (not ignored), and that nothing else changed. Tell the user the overrides
are in place and will survive `skill-kit game sync` / `update`, and that the log fallback
is in use until an engine-control MCP is wired up.
