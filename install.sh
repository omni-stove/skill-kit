#!/bin/sh
# skill-kit installer. Clones the kit and puts the `skill-kit` CLI on PATH.
# Usage: curl -fsSL https://raw.githubusercontent.com/omni-stove/skill-kit/main/install.sh | sh
set -eu

REPO_SLUG="${SKILL_KIT_REPO_SLUG:-omni-stove/skill-kit}"
REPO="${SKILL_KIT_REPO:-https://github.com/$REPO_SLUG.git}"
KIT_HOME="${SKILL_KIT_HOME:-$HOME/.skill-kit}"
BIN_DIR="${SKILL_KIT_BIN:-$HOME/.local/bin}"

# --- clone / update -----------------------------------------------------------
if [ -d "$KIT_HOME/.git" ]; then
	echo "skill-kit: updating existing checkout at $KIT_HOME"
	git -C "$KIT_HOME" pull --ff-only
else
	echo "skill-kit: cloning into $KIT_HOME"
	git clone "$REPO" "$KIT_HOME"
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
echo "  Or in a code repo:     skill-kit code sync"
