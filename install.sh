#!/usr/bin/env bash
# install.sh — post-install setup for claude-memorize plugin
#
# If you installed via `/plugin install`, run this once to:
#   1. Initialize the recipe storage directory
#   2. Append memorize behavior rules to ~/.claude/CLAUDE.md
#
# If you are installing manually (without the plugin system), this script
# also copies the command file and adds the Write permission to settings.json.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RECIPE_DIR="$HOME/.claude/skills/memorize"
GLOBAL_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARKER="## Memorize Skill"

echo "Setting up claude-memorize..."

# Initialize recipe storage
mkdir -p "$RECIPE_DIR/recipes"
mkdir -p "$HOME/.claude/commands/memorize"

if [ ! -f "$RECIPE_DIR/index.md" ]; then
  cp "$SCRIPT_DIR/index.md" "$RECIPE_DIR/index.md"
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

# --- Manual install only (skip if using /plugin install) ---
COMMAND_FILE="$HOME/.claude/commands/memorize.md"
SETTINGS_FILE="$HOME/.claude/settings.json"

if [ "${MANUAL_INSTALL:-0}" = "1" ]; then
  mkdir -p "$HOME/.claude/commands"
  cp "$SCRIPT_DIR/commands/memorize.md" "$COMMAND_FILE"
  echo "Copied command file to $COMMAND_FILE."

  PERMISSION="Write(~/.claude/commands/memorize/*)"
  python3 - "$SETTINGS_FILE" "$PERMISSION" <<'PYEOF'
import json, sys
settings_file, permission = sys.argv[1], sys.argv[2]
try:
    with open(settings_file) as f:
        d = json.load(f)
except FileNotFoundError:
    d = {}
allows = d.setdefault("permissions", {}).setdefault("allow", [])
if permission not in allows:
    allows.append(permission)
    with open(settings_file, "w") as f:
        json.dump(d, f, indent=2)
    print(f"Added permission: {permission}")
else:
    print("Permission already present — skipped.")
PYEOF
fi

echo ""
echo "Done."
echo "  Recipes : $RECIPE_DIR/recipes/"
echo "  Index   : $RECIPE_DIR/index.md"
echo "  CLAUDE.md block appended."