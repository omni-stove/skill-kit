# Story setup rules

The kit ships two files. `.agents/refs/layout.sh` maps a project id to that project's
layout file and sources it — leave it alone unless a repo keeps its layout files
somewhere other than `.agents/refs/layouts/`, in which case override its one
`project_layout` line. `.agents/refs/layout-template.sh` is the shape of one project's
layout: the function NAMES skills depend on, over placeholder paths. `cat` both before
doing anything else.

Setup produces one **real** file per project: `.agents/refs/layouts/<id>.sh`, whose
functions echo where THAT project actually keeps its files. `skill-kit story sync` leaves
real files untouched and git-tracks them.

Confirm the kit is synced: if `.agents/refs/layout-template.sh` is absent, tell the user
to run `skill-kit story sync` first and stop.

For each project the user names:

- Settle its id (`co`) and where its files live — a directory in this repo (`src/co`,
  `manuscripts/co`), a sibling checkout, or an absolute path. Read an existing layout with
  `find <dir> -maxdepth 3 -type d`; ask when the directory is empty. There is no assumed
  base — the project may sit anywhere.
- Copy `.agents/refs/layout-template.sh` to `.agents/refs/layouts/<id>.sh`. Point `_base`
  at the project's directory, or inline concrete paths per function where the directories
  don't share one base.
- Match what already exists on disk: whether `synopsis` is a file or a directory, whether
  chapters are flat or nested. Keep every function name even when a project doesn't use
  it; change only the paths.

Verify with `.agents/refs/path <id> characters_main テスト` and
`.agents/refs/path <id> story_synopsis` — confirm the printed paths match what you and the
user agreed on.

Run `git status` and confirm each `.agents/refs/layouts/<id>.sh` shows as a real, tracked
file. Tell the user the layout files survive `skill-kit story sync` / `update`.
