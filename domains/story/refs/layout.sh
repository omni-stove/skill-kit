#!/bin/sh
# Project layout — the single source of truth for where a repo keeps its files.
# Skills never hardcode paths; they source this file and call a function to get a
# resolved path. To adapt the kit to a repo that lays its files out differently,
# override this file: drop a real .agents/refs/layout.sh into the repo (sync leaves
# real files untouched) and redefine the functions below. The function NAMES are the
# contract; the paths they return are not.
#
# Usage from a skill (after you know the project id):
#   sh -c '. .agents/refs/layout.sh; characters_main co "アリス"'
#     -> src/co/characters/main/アリス.md
#
# Every function echoes one resolved path relative to the repo root. Args are the
# runtime values the user gave you: $1 = project id, then name / title / filename.
#
# The argument convention is part of the contract: skills always pass a project id as
# $1. A repo with no project-id level ignores $1 and echoes a project-less path; the
# functions absorb the difference, the callers never change.
#
# If a location a skill needs is not defined here, do not guess a path. Stop and ask
# the user to define it in their repo's .agents/refs/layout.sh. Setup is explicit —
# there is no hidden default directory.

project_root()          { echo "src/$1"; }
readme()                { echo "src/$1/README.md"; }

characters()            { echo "src/$1/characters"; }
characters_main()       { echo "src/$1/characters/main/$2.md"; }
characters_supporting() { echo "src/$1/characters/supporting/$2.md"; }
characters_antagonist() { echo "src/$1/characters/antagonist/$2.md"; }
characters_archive()    { echo "src/$1/characters/archive/$2.md"; }

world()                 { echo "src/$1/world"; }
items()                 { echo "src/$1/items"; }

story()                 { echo "src/$1/story"; }
story_plot()            { echo "src/$1/story/plot"; }
story_plot_file()       { echo "src/$1/story/plot/$2.md"; }        # $2 = english-title
story_outline()         { echo "src/$1/story/outline"; }
story_synopsis()        { echo "src/$1/story/synopsis.txt"; }
story_timeline()        { echo "src/$1/story/timeline.md"; }
story_memo()            { echo "src/$1/story/memo/$2.md"; }        # $2 = filename
story_body_file()       { echo "src/$1/story/$2.md"; }            # $2 = chapter
