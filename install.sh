#!/usr/bin/env bash
# install.sh — sets up the memorize skill for Claude Code

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$HOME/.claude/skills/memorize"
SKILL_FILE="$HOME/.claude/skills/memorize.md"
GLOBAL_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARKER="## Memorize Skill"

echo "Installing memorize skill..."

# Create skill directory and recipes subfolder
mkdir -p "$SKILL_DIR/recipes"

# Copy skill prompt
cp "$SCRIPT_DIR/memorize.md" "$SKILL_FILE"

# Copy (or init) the index if it doesn't exist yet
if [ ! -f "$SKILL_DIR/index.md" ]; then
  cp "$SCRIPT_DIR/index.md" "$SKILL_DIR/index.md"
  echo "Initialized empty recipe index."
else
  echo "Existing index.md preserved (not overwritten)."
fi

# Append CLAUDE.md block if not already present
if grep -qF "$MARKER" "$GLOBAL_CLAUDE_MD" 2>/dev/null; then
  echo "CLAUDE.md block already present — skipped."
else
  echo "" >> "$GLOBAL_CLAUDE_MD"
  cat "$SCRIPT_DIR/CLAUDE.md" >> "$GLOBAL_CLAUDE_MD"
  echo "Appended memorize rules to $GLOBAL_CLAUDE_MD."
fi

echo ""
echo "Done. Skill installed at:"
echo "  Skill prompt : $SKILL_FILE"
echo "  Recipes      : $SKILL_DIR/recipes/"
echo "  Index        : $SKILL_DIR/index.md"
echo "  CLAUDE.md    : $GLOBAL_CLAUDE_MD (memorize block appended)"
echo ""
echo "Usage inside Claude Code:"
echo "  /memorize <name> <description>   — save steps from current conversation"
echo "  /memorize <name>                 — recall and execute a saved recipe"
echo "  /memorize list                   — list all recipes"
echo "  /memorize search <keywords>      — search recipes"
echo "  /memorize delete <name>          — delete a recipe"
