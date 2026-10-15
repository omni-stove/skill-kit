#!/bin/sh
# Copy the kit's workflow templates into .github/workflows (existing files are kept),
# create the labels the issue worker fires on, list what the user must set by hand, and
# say what to do next.
set -eu
. "$(dirname -- "$0")/../../../../../shared/refs/prompt.sh"
src=.agents/refs/workflows
[ -d "$src" ] || { echo "install: $src not found — the kit isn't synced into this repo. Tell the user to run \`skill-kit code sync\`, then stop." >&2; exit 1; }
[ -f .mise/tasks.toml ] || { echo "install: .mise/tasks.toml not found — the workflows run \`mise run install\`, \`make lint\` and \`make test\`. Run the init skill first, then stop." >&2; exit 1; }

mkdir -p .github/workflows
for tpl in "$src"/*.yml; do
	name=$(basename "$tpl")
	if [ -e ".github/workflows/$name" ]; then
		echo "kept	.github/workflows/$name"
	else
		cp "$tpl" ".github/workflows/$name"
		echo "created	.github/workflows/$name"
	fi
done

for task in install lint test; do
	grep -q "^\[$task\]" .mise/tasks.toml || echo "missing	task $task — the workflows call it; add it to .mise/tasks.toml"
done

if gh auth status >/dev/null 2>&1; then
	gh label create bug --color d73a4a --description "A fix the issue worker implements" --force >/dev/null 2>&1 && echo "label	bug" || echo "warning	could not create label bug"
	gh label create prototype --color fbca04 --description "A mock-level prototype the issue worker builds as a draft PR" --force >/dev/null 2>&1 && echo "label	prototype" || echo "warning	could not create label prototype"
	gh label create implementation --color 0e8a16 --description "A production-quality implementation the issue worker builds" --force >/dev/null 2>&1 && echo "label	implementation" || echo "warning	could not create label implementation"
else
	echo "todo	gh auth login, then create the labels: gh label create bug / prototype / implementation"
fi

cat <<'TODO'
todo	gh secret set ANTHROPIC_API_KEY
todo	Repository Settings > Actions > General > Workflow permissions: "Read and write" and "Allow GitHub Actions to create and approve pull requests"
todo	optional: gh secret set AGENT_GITHUB_TOKEN with a PAT or GitHub App token (contents + pull-requests write) so PRs and pushes made by the agent trigger CI and PR Review
TODO

ci_ref=$(sed -n 's/^ *workflows: *\[ *"\([^"]*\)" *\].*/\1/p' .github/workflows/ci-auto-fix.yml 2>/dev/null | head -1)
if [ -n "$ci_ref" ] && ! grep -qsx "name: $ci_ref" .github/workflows/*.yml; then
	echo "todo	.github/workflows/ci-auto-fix.yml — workflows: [\"$ci_ref\"] names no workflow in .github/workflows; set it to the CI workflow's name:"
fi
for f in .github/workflows/*.yml; do
	git check-ignore -q "$f" 2>/dev/null && echo "warning	$f is ignored by git — unignore it so the workflow runs"
done

prompt next >&2
