#!/bin/sh
# Per-project layout — the deterministic resolver.
#
# There is ONE layout file per project, and it declares where THAT project keeps its
# files (in this repo, a sibling repo, or an absolute path anywhere — no shared root,
# no monorepo assumption). Skills never pass a base path and never hardcode one: they
# name a project id, sh resolves it to that project's layout file, sources it, and the
# project's structural functions come into scope, each taking only a name.
#
# Usage from a skill:
#   sh -c '. .agents/refs/layout.sh; load_project co; characters_main "アリス"'
#     -> whatever co's layout file defines, e.g. src/co/characters/main/アリス.md
#
# The id -> file rule is the ONLY convention and it lives here, so a repo can lay its
# per-project layout files out differently by overriding project_layout below. The
# per-project files themselves are scaffolded from layout-template.sh by `setup`.

# Deterministic map: project id -> its layout file. Override this one line to relocate.
project_layout() { echo ".agents/refs/layouts/$1.sh"; }

# Resolve + source the project's layout file, bringing its structural functions into
# scope. Deterministic: the skill passes only the id; sh derives and loads the file.
load_project() {
	_lf=$(project_layout "$1")
	[ -f "$_lf" ] || { echo "layout: no layout file for project '$1' (looked at $_lf) — run the setup skill to create one" >&2; return 1; }
	. "$_lf"
}
