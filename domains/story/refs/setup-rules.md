# Story setup rules

The kit's **default** `.agents/refs/layout.sh` is the contract: the function NAMES are
fixed, the paths they return are what you are here to adapt. `cat .agents/refs/layout.sh`
and read it in full before doing anything else.

This produces one thing: a **real** `.agents/refs/layout.sh` in this repo whose functions
echo this repo's actual paths. `skill-kit story sync` leaves real files untouched and keeps
them git-tracked, so a real `layout.sh` overrides the kit's symlinked default. Do NOT edit
the symlink target, and never hand-build project paths elsewhere — every path a skill uses
comes from these functions.

First, confirm the kit is synced: if `.agents/refs/layout.sh` does not resolve
(`sh -c '. .agents/refs/layout.sh; project_root x'` errors), tell the user to run
`skill-kit story sync` first and stop.

Then figure out how THIS repo already lays out its files — do not assume the default:

- Run `ls`, and look for an existing source root (`src/`, `content/`, `manuscripts/`,
  a language-specific dir, …). If content already exists, inspect it:
  `find <root> -maxdepth 3 -type d` to see how characters / world / items / story /
  plot / synopsis / timeline are actually arranged.
- Note the naming: is `synopsis` a file or a dir? Are chapters flat files or nested?
  Match what already exists.
- Settle whether this repo has a project-id level. The default nests every path under
  one id (`src/<id>/…`), holding many projects at once; a single-work repo drops the id
  and puts content directly under the source root (`src/characters/main/アリス.md`). Read
  the disk, or ask when the repo is empty. This decides every function below.

Walk the default `layout.sh` function by function with the user. For each function,
show its default path and either keep it or map it to this repo's location. Use
AskUserQuestion to resolve the ones that differ — batch related functions (all
`characters_*`, all `story_*`) into single questions rather than asking one at a time.
If the repo is empty and the user has no preference, the kit default is the right
answer — say so and keep it.

Constraints for the generated file:

- Keep EVERY function name from the default, even ones you leave unchanged — skills
  depend on the full set existing. Never rename, drop, or add functions; only change
  the paths they echo.
- Preserve the argument convention: `$1` = project id, then name / title / filename in
  the order the default uses. Keep the `# $2 = ...` comments where the default has them.
  In a repo with no project-id level, ignore `$1` in the path but keep it in the
  signature; `$2` onward stay the name / title / filename.
- Each function echoes exactly one path, relative to the repo root, no trailing slash.
- Start the file with `#!/bin/sh` and a one-line comment noting it is this repo's
  override of the kit default.

Write the result to `.agents/refs/layout.sh` (overwriting the symlink with a real file).
Then verify: run a few resolutions —
`sh -c '. .agents/refs/layout.sh; characters_main demo テスト; story_synopsis demo'` —
and confirm the printed paths match what you and the user agreed on. In a project-less
repo, confirm `demo` is absent from the output.

Finally run `git status` and confirm `.agents/refs/layout.sh` now shows as a real,
tracked file (not ignored), and that nothing else changed. Tell the user the override
is in place and will survive `skill-kit story sync` / `update`.
