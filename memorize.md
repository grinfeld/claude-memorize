---
description: Save, recall, list, search, or delete step recipes across sessions
argument-hint: [name] [description]
---

You are executing the `/memorize` command. Read the invocation carefully and follow the appropriate mode below.

The arguments are: $ARGUMENTS

---

## Invocation Modes

### 1. Save mode — `/memorize <name> [description]`

Example: `/memorize sync_argocd Store steps for syncing an ArgoCD application`

If no description is provided, use the user's last message as the description.

Steps:
1. Read `~/.claude/skills/memorize/index.md` to check if a recipe named `<name>` already exists.
2. Look back through the **current conversation** and identify all tool calls, bash commands, and actions that succeeded and are relevant to `<description>`.
3. Extract the logical steps. Generalize hardcoded values into `<placeholder>` format where appropriate (e.g. `<app-name>`, `<namespace>`, `<image-tag>`).
4. Write the recipe to `~/.claude/skills/memorize/recipes/<name>.md` using the template below.
5. Update `~/.claude/skills/memorize/index.md` — add or update the entry for `<name>`.
6. Write a subcommand file to `~/.claude/commands/memorize/<name>.md` with this content (substituting actual name and description):
   ```
   ---
   description: <description>
   ---
   Execute memorize recall for recipe `<name>`:
   1. Read `~/.claude/skills/memorize/recipes/<name>.md`
   2. Present the steps to the user
   3. Ask for any `<placeholder>` values before proceeding
   4. Execute the steps using the appropriate tools
   ```
7. Confirm to the user: "Recipe `<name>` saved."

**Recipe template:**
```markdown
# <name>

**Description**: <description>
**Tags**: <comma-separated relevant tags>
**Last updated**: <today's date>

## Steps

1. <step one>
2. <step two>
...

## Notes

<any important context, caveats, or prerequisites>
```

---

### 2. Recall mode — `/memorize <name>`

> **Disambiguation:** when only a name is given (no description), check if `~/.claude/skills/memorize/recipes/<name>.md` exists. If it does → recall mode. If it doesn't → save mode using the last user message as the description.

Example: `/memorize sync_argocd`

Steps:
1. Read `~/.claude/skills/memorize/recipes/<name>.md`.
   - If not found, search `~/.claude/skills/memorize/index.md` for a close match and suggest it.
2. Present the steps to the user.
3. If the recipe contains `<placeholder>` values, ask the user to supply them before proceeding.
4. Execute the steps using the appropriate tools (Bash, Edit, Write, etc.).

---

### 3. List mode — `/memorize list`

Steps:
1. Read `~/.claude/skills/memorize/index.md`.
2. Present the full recipe list in a clean table (name, description, tags, last updated).

---

### 4. Search mode — `/memorize search <keywords>`

Steps:
1. Read `~/.claude/skills/memorize/index.md`.
2. Find all recipes whose name, description, or tags match any of `<keywords>`.
3. Present matches. If exactly one match, offer to recall it immediately.

---

### 5. Delete mode — `/memorize delete <name>`

Steps:
1. Confirm with the user before deleting.
2. Delete `~/.claude/skills/memorize/recipes/<name>.md`.
3. Remove the entry from `~/.claude/skills/memorize/index.md`.
4. Delete `~/.claude/commands/memorize/<name>.md` if it exists.
5. Confirm: "Recipe `<name>` deleted."

---

## Important Rules

- Never invent steps that didn't happen — only save what was actually executed and succeeded.
- When generalizing parameters, prefer explicit placeholders over omitting the parameter entirely.
- If a recipe already exists for `<name>`, ask the user whether to overwrite or append/update.
- Keep steps atomic and shell-executable where possible.