#!/bin/sh
# skill-kit installer. Clones the kit and puts the `skill-kit` CLI on PATH.
# skill-kit is a PRIVATE repo: access is gated by your GitHub read permission,
# so this installer requires an authenticated GitHub CLI (`gh`). Users without
# access are rejected by GitHub itself at clone time — not bypassable client-side.
# Usage: curl -fsSL https://raw.githubusercontent.com/omni-stove/skill-kit/main/install.sh | sh
set -eu

REPO_SLUG="${SKILL_KIT_REPO_SLUG:-omni-stove/skill-kit}"
REPO="${SKILL_KIT_REPO:-https://github.com/$REPO_SLUG.git}"
KIT_HOME="${SKILL_KIT_HOME:-$HOME/.skill-kit}"
BIN_DIR="${SKILL_KIT_BIN:-$HOME/.local/bin}"

# --- preflight: require an authenticated GitHub CLI ---------------------------
if ! command -v gh >/dev/null 2>&1; then
	echo "skill-kit: GitHub CLI (gh) is required. Install it: https://cli.github.com" >&2
	exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
	echo "skill-kit: not logged in to GitHub. Run 'gh auth login' first." >&2
	exit 1
fi
# Let plain `git` (clone above, and later `skill-kit update`) use gh's credentials
# for github.com, so pulls against the private repo keep working.
gh auth setup-git >/dev/null 2>&1 || true

# --- clone / update -----------------------------------------------------------
if [ -d "$KIT_HOME/.git" ]; then
	echo "skill-kit: updating existing checkout at $KIT_HOME"
	git -C "$KIT_HOME" pull --ff-only
else
	echo "skill-kit: cloning into $KIT_HOME"
	if ! git clone "$REPO" "$KIT_HOME"; then
		echo "skill-kit: clone failed — your GitHub account may not have access to $REPO_SLUG." >&2
		echo "          Ask an owner to add you, then re-run this installer." >&2
		exit 1
	fi
fi

mkdir -p "$BIN_DIR"
ln -sfn "$KIT_HOME/bin/skill-kit" "$BIN_DIR/skill-kit"

echo
echo "skill-kit installed."
case ":$PATH:" in
*":$BIN_DIR:"*) ;;
*) echo "  Add to PATH:  export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac
echo "  Then in a game repo:   skill-kit game sync"
echo "  Or in a writing repo:  skill-kit story sync"
