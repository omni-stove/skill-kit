#!/bin/sh
# Create the mise/make files this repo is missing (a git repository if there is none, the
# forwarding Makefile, mise.toml, .mise/tasks.toml) and list what init must still fold in: a Makefile with its own
# targets, dependency manifests and the version pins and scripts they carry. A file that
# already exists is never changed.
set -eu
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { git init -q && echo "created	.git"; }
domain=$(cat .agents/refs/domain 2>/dev/null || true)
[ -f .agents/refs/mise-rules.md ] && [ -n "$domain" ] || { echo "init: the kit isn't synced into this repo. Tell the user to run \`skill-kit {game|story|code} sync\`, then stop." >&2; exit 1; }

write_makefile() {
	cat >Makefile <<'MK'
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

# Goals passed as arguments are not targets to build.
ifneq ($(TASK_ARGS),)
$(TASK_ARGS):
	@:
endif
MK
}

if [ ! -e Makefile ]; then
	write_makefile
	echo "created	Makefile"
elif grep -q 'mise run \$(TASK)' Makefile; then
	echo "kept	Makefile"
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
else
	echo "kept	mise.toml — add: [task_config] includes = [\".mise/tasks.toml\"]"
fi

# The dependency install command, from the lockfile or manifest present; ":" when none.
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

if [ ! -e .mise/tasks.toml ]; then
	mkdir -p .mise
	cat >.mise/tasks.toml <<TOML
[install]
description = "Install the repo's dependencies"
run = "$install_cmd"

[setup]
description = "Install dependencies and skill-kit, then sync (run by make setup)"
depends = ["install"]
run = [
  "gh api repos/omni-stove/skill-kit/contents/install.sh -q .content | base64 -d | sh",
  "skill-kit $domain sync",
]

[update]
description = "Pull skill-kit and re-sync this repo"
run = "skill-kit $domain update"
TOML
	echo "created	.mise/tasks.toml"
	echo "install	$install_cmd"
else
	echo "kept	.mise/tasks.toml"
	grep -q '^\[install\]' .mise/tasks.toml || echo "kept	.mise/tasks.toml — add an [install] task running: $install_cmd"
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
