#!/usr/bin/env bash
# install.sh — sets up the memorize command for Claude Code

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RECIPE_DIR="$HOME/.claude/skills/memorize"
COMMAND_FILE="$HOME/.claude/commands/memorize.md"
GLOBAL_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARKER="## Memorize Skill"

echo "Installing memorize command..."

# Create commands directory, memorize subcommands directory, and recipes subfolder
mkdir -p "$HOME/.claude/commands/memorize"
mkdir -p "$RECIPE_DIR/recipes"

# Copy command prompt
cp "$SCRIPT_DIR/memorize.md" "$COMMAND_FILE"

# Copy (or init) the index if it doesn't exist yet
if [ ! -f "$RECIPE_DIR/index.md" ]; then
  cp "$SCRIPT_DIR/index.md" "$RECIPE_DIR/index.md"
  echo "Initialized empty recipe index."
else
  echo "Existing index.md preserved (not overwritten)."
fi

# Generate subcommand files for existing recipes
for recipe_file in "$RECIPE_DIR/recipes/"*.md; do
  [ -f "$recipe_file" ] || continue
  name=$(basename "$recipe_file" .md)
  description=$(grep -m1 '^\*\*Description\*\*:' "$recipe_file" | sed 's/\*\*Description\*\*: *//')
  [ -z "$description" ] && description="Recall the $name recipe"
  cat > "$HOME/.claude/commands/memorize/$name.md" <<EOF
---
description: $description
---
Execute memorize recall for recipe \`$name\`:
1. Read \`~/.claude/skills/memorize/recipes/$name.md\`
2. Present the steps to the user
3. Ask for any \`<placeholder>\` values before proceeding
4. Execute the steps using the appropriate tools
EOF
  echo "  Created subcommand: /memorize/$name"
done

# Add write permission for memorize subcommands directory to Claude Code settings
SETTINGS_FILE="$HOME/.claude/settings.json"
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

# Append CLAUDE.md block if not already present
if grep -qF "$MARKER" "$GLOBAL_CLAUDE_MD" 2>/dev/null; then
  echo "CLAUDE.md block already present — skipped."
else
  echo "" >> "$GLOBAL_CLAUDE_MD"
  cat "$SCRIPT_DIR/CLAUDE.md" >> "$GLOBAL_CLAUDE_MD"
  echo "Appended memorize rules to $GLOBAL_CLAUDE_MD."
fi

echo ""
echo "Done. Command installed at:"
echo "  Command prompt: $COMMAND_FILE"
echo "  Subcommands   : $HOME/.claude/commands/memorize/"
echo "  Recipes       : $RECIPE_DIR/recipes/"
echo "  Index         : $RECIPE_DIR/index.md"
echo "  CLAUDE.md     : $GLOBAL_CLAUDE_MD (memorize block appended)"
echo "  settings.json : $SETTINGS_FILE (write permission added)"
echo ""
echo "Usage inside Claude Code:"
echo "  /memorize <name> <description>   — save steps from current conversation"
echo "  /memorize <name>                 — recall and execute a saved recipe"
echo "  /memorize list                   — list all recipes"
echo "  /memorize search <keywords>      — search recipes"
echo "  /memorize delete <name>          — delete a recipe"