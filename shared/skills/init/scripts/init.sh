#!/bin/sh
# Create the mise/make files this repo is missing (a git repository if there is none, the
# forwarding Makefile, mise.toml, .mise/tasks.toml, the domain's rules in AGENTS.md), bring
# a kit-generated file up to the current template with only the missing parts added, and
# list what init must still fold in: a Makefile with its own targets, dependency manifests
# and the version pins and scripts they carry. What a person wrote is never changed.
set -eu
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { git init -q && echo "created	.git"; }
domain=$(cat .agents/refs/domain 2>/dev/null || true)
[ -f .agents/refs/mise-rules.md ] && [ -n "$domain" ] || { echo "init: the kit isn't synced into this repo. Tell the user to run \`skill-kit {game|story|code} sync\`, then stop." >&2; exit 1; }

write_makefile() {
	cat >"$1" <<'MK'
# make <task> [args] runs mise run <task> [args]: the first goal is the task name, the
# rest are its arguments. A flag that begins with - is eaten by make, so pass it as ARGS:
#   make count src/story           ->  mise run count src/story
#   make pdf ARGS="--limit 10"     ->  mise run pdf --limit 10
TASK := $(firstword $(MAKECMDGOALS))
TASK_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

.PHONY: setup $(TASK) $(TASK_ARGS)

# The one target make owns: install the pinned tools, then hand over to the setup task.
# Every other command is a task in .mise/tasks.toml — list them with: mise tasks
setup:
	@command -v git >/dev/null || { echo "make setup: git is not installed"; exit 1; }
	@gh auth status >/dev/null 2>&1 || { echo "make setup: GitHub CLI is missing or not logged in — install gh and run: gh auth login"; exit 1; }
	@command -v mise >/dev/null || { echo "make setup: mise is not installed — see https://mise.jdx.dev/getting-started.html"; exit 1; }
	@mise trust -q
	@mise install
	@mise run setup

ifneq ($(TASK),)
ifneq ($(TASK),setup)
$(TASK):
	@mise run $(TASK) $(TASK_ARGS) $(ARGS)
endif
endif

# Without a no-op rule, make would try to build the argument goals as targets.
ifneq ($(TASK_ARGS),)
$(TASK_ARGS):
	@:
endif
MK
}

if [ ! -e Makefile ]; then
	write_makefile Makefile
	echo "created	Makefile"
elif grep -q 'mise run \$(TASK)' Makefile; then
	tmp=$(mktemp)
	write_makefile "$tmp"
	if cmp -s "$tmp" Makefile; then
		echo "kept	Makefile"
	else
		diff -u Makefile "$tmp" || true
		cp "$tmp" Makefile
		echo "updated	Makefile — the forwarding Makefile is kit-owned; the diff above is what changed"
	fi
	rm -f "$tmp"
else
	echo "foreign	Makefile — move each target below into a task in .mise/tasks.toml, delete the Makefile, and run this script again"
	grep -oE '^[A-Za-z0-9_-]+( [A-Za-z0-9_-]+)*:' Makefile | sed 's/:$//' | tr ' ' '\n' | sort -u | sed 's/^/target	/'
fi

if [ ! -e mise.toml ]; then
	cat >mise.toml <<'TOML'
[tools]

[task_config]
includes = [".mise/tasks.toml"]
TOML
	echo "created	mise.toml"
elif grep -q '\.mise/tasks\.toml' mise.toml; then
	echo "kept	mise.toml"
elif grep -q '^\[task_config\]' mise.toml; then
	echo "kept	mise.toml — add \".mise/tasks.toml\" to the includes under [task_config]"
else
	printf '\n[task_config]\nincludes = [".mise/tasks.toml"]\n' >>mise.toml
	echo "updated	mise.toml — added [task_config] includes"
fi

install_cmd=:
if [ -e pnpm-lock.yaml ]; then install_cmd="pnpm install --frozen-lockfile"
elif [ -e yarn.lock ]; then install_cmd="yarn install --frozen-lockfile"
elif [ -e package-lock.json ]; then install_cmd="npm ci"
elif [ -e bun.lockb ] || [ -e bun.lock ]; then install_cmd="bun install --frozen-lockfile"
elif [ -e uv.lock ]; then install_cmd="uv sync --frozen"
elif [ -e Pipfile ]; then install_cmd="pipenv sync --dev"
elif [ -e requirements.txt ]; then install_cmd="pip install -r requirements.txt"
elif [ -e go.mod ]; then install_cmd="go mod download"
elif [ -e Cargo.toml ]; then install_cmd="cargo fetch"
elif [ -e Gemfile ]; then install_cmd="bundle install"
elif [ -e package.json ]; then install_cmd="npm install"
fi

task_install() {
	cat <<TOML
[install]
description = "Install the repo's dependencies"
run = "$install_cmd"
TOML
}
task_setup() {
	cat <<TOML
[setup]
description = "Install dependencies and skill-kit, then sync (run by make setup)"
depends = ["install"]
run = [
  "gh api repos/omni-stove/skill-kit/contents/install.sh -q .content | base64 -d | sh",
  "skill-kit $domain sync",
]
TOML
}
task_update() {
	cat <<TOML
[update]
description = "Pull skill-kit and re-sync this repo"
run = "skill-kit $domain update"
TOML
}

if [ ! -e .mise/tasks.toml ]; then
	mkdir -p .mise
	{ task_install; echo; task_setup; echo; task_update; } >.mise/tasks.toml
	echo "created	.mise/tasks.toml"
	echo "install	$install_cmd"
else
	added=
	for task in install setup update; do
		grep -q "^\[$task\]" .mise/tasks.toml && continue
		[ -s .mise/tasks.toml ] && echo >>.mise/tasks.toml
		"task_$task" >>.mise/tasks.toml
		added="$added $task"
	done
	if [ -n "$added" ]; then
		echo "updated	.mise/tasks.toml — added tasks:$added"
		case $added in *install*) echo "install	$install_cmd" ;; esac
	else
		echo "kept	.mise/tasks.toml"
	fi
	if ! awk '/^\[setup\]/{s=1;next} /^\[/{s=0} s && /^depends *=.*"install"/{f=1} END{exit !f}' .mise/tasks.toml; then
		echo "todo	.mise/tasks.toml — give [setup] depends = [\"install\"]"
	fi
fi

# The rules are copied into AGENTS.md rather than referenced from .agents/refs because a CI
# agent has no kit symlinks.
if [ -f .agents/refs/code-rules.md ]; then
	rules=.agents/refs/code-rules.md
	heading=$(head -1 "$rules")
	if [ -f AGENTS.md ] && grep -qxF "$heading" AGENTS.md; then
		current=$(awk -v h="$heading" '$0==h{p=1} p && $0!=h && /^# /{exit} p' AGENTS.md)
		if [ "$current" = "$(cat "$rules")" ]; then
			echo "kept	AGENTS.md"
		else
			tmp=$(mktemp)
			awk -v h="$heading" -v f="$rules" '
				$0==h{ while ((getline line < f) > 0) print line; skip=1; next }
				skip && /^# /{ skip=0; print "" }
				!skip' AGENTS.md >"$tmp"
			mv "$tmp" AGENTS.md
			echo "updated	AGENTS.md — replaced the \"$heading\" block with the current rules"
		fi
	else
		[ -s AGENTS.md ] && printf '\n' >>AGENTS.md
		cat "$rules" >>AGENTS.md
		echo "appended	AGENTS.md"
	fi
fi

for f in package.json pnpm-lock.yaml yarn.lock package-lock.json bun.lockb pyproject.toml uv.lock Pipfile requirements.txt go.mod Cargo.toml Gemfile; do
	[ -e "$f" ] && echo "manifest	$f"
done
for f in .node-version .nvmrc .python-version .ruby-version .go-version .tool-versions; do
	[ -f "$f" ] && echo "pin	$f	$(head -1 "$f")"
done
if [ -f package.json ]; then
	if command -v jq >/dev/null 2>&1; then
		jq -r '[.packageManager, .engines] | map(select(. != null)) | .[] | if type == "string" then "pin\tpackage.json\t\(.)" else to_entries[] | "pin\tpackage.json\t\(.key) \(.value)" end' package.json
		jq -r '.scripts // {} | to_entries[] | "script\t\(.key)\t\(.value)"' package.json
	else
		grep -oE '"packageManager" *: *"[^"]+"' package.json | sed -E 's/"packageManager" *: *"([^"]+)"/pin	package.json	\1/'
		sed -n '/"scripts" *: *{/,/^ *}/p' package.json | grep -oE '"[^"]+" *: *"[^"]*"' | sed -E 's/"([^"]+)" *: *"([^"]*)"/script	\1	\2/' | grep -v '^script	scripts	'
	fi
fi
exit 0
