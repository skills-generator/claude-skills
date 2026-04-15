#!/usr/bin/env bash
# Install github-ops skill into the user's Claude skills directory.
# Usage: ./install.sh
# Env: CLAUDE_SKILLS_DIR (default: ~/.claude/skills)

set -euo pipefail

TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
SKILL_NAME="github-ops"
SRC="$(cd "$(dirname "$0")" && pwd)/skills/$SKILL_NAME"

if [ ! -d "$SRC" ]; then
  echo "error: source skill not found at $SRC" >&2
  exit 1
fi

mkdir -p "$TARGET"

if [ -e "$TARGET/$SKILL_NAME" ]; then
  printf '%s already exists. Overwrite? [y/N] ' "$TARGET/$SKILL_NAME"
  read -r ans
  case "$ans" in
    y|Y|yes|YES) rm -rf "$TARGET/$SKILL_NAME" ;;
    *) echo "aborted"; exit 0 ;;
  esac
fi

cp -r "$SRC" "$TARGET/"
echo "installed: $TARGET/$SKILL_NAME"
echo ""
echo "next steps:"
echo "  1. edit team conventions in $TARGET/$SKILL_NAME/SKILL.md"
echo "     (replace <队友1-github-username> etc. with real usernames)"
echo "  2. ensure gh CLI is installed and authenticated: gh auth status"
