---
name: memorize
description: Save, recall, list, search, or delete step recipes across sessions. Use when the user asks to memorize/save/store an operation, recall/replay a saved recipe, or manage saved recipes.
argument-hint: save <name> [description] | <name> | list | search <keywords> | delete <name>
disable-model-invocation: true
---

You are executing the `memorize` skill. Read `$ARGUMENTS` carefully and follow the appropriate mode below.

The plugin directory is available as `${CLAUDE_SKILL_DIR}/../..` (two levels up from this SKILL.md).

---

## Invocation Modes

### 1. Save mode — `save <name> [description]`

Example: `save get-pods List pods in your dev cluster`

If no description is provided, infer it from the last user message or the overall conversation context.

Steps:
1. Check if `${CLAUDE_SKILL_DIR}/../../skills/<name>/SKILL.md` already exists. If it does, ask the user whether to overwrite or cancel.
2. Look back through the **current conversation** and identify all tool calls, bash commands, and actions that succeeded and are relevant to the description.
3. Extract the logical steps. Generalize hardcoded values into `<placeholder>` format where appropriate (e.g. `<namespace>`, `<app-name>`, `<image-tag>`).
4. Delegate the file write to a Haiku subagent (faster and cheaper):
   ```
   Use the Agent tool with model: "haiku" and this prompt:
   "Write a skill file to ${CLAUDE_SKILL_DIR}/../../skills/<name>/SKILL.md with this exact content:
   <skill content using the template below>

   Create parent directories if needed."
   ```
5. Confirm to the user: "Recipe `<name>` saved. Invoke it with `/memorize:<name>`."

**Skill template to write:**
```markdown
---
name: <name>
description: <description>
disable-model-invocation: true
---

<description>

## Steps

1. <step one>
2. <step two>
...

## Notes

<any important context, caveats, prerequisites, or placeholder explanations>
```

---

### 2. Recall mode — `<name>` (no subcommand keyword)

> **Disambiguation:** if the first word is not `save`, `list`, `search`, or `delete`, treat the entire argument as a recipe name.

Example: `get-pods`

Steps:
1. Read `${CLAUDE_SKILL_DIR}/../../skills/<name>/SKILL.md`.
   - If not found, list available skills by scanning `${CLAUDE_SKILL_DIR}/../../skills/` and suggest the closest match.
2. Present the steps to the user.
3. If the recipe contains `<placeholder>` values, ask the user to supply them before proceeding.
4. Delegate execution to a Haiku subagent:
   ```
   Use the Agent tool with model: "haiku" and this prompt:
   "Execute the following steps exactly, substituting any placeholder values provided:
   <steps with placeholders replaced>

   Use Bash, Read, Write, and other tools as needed. Report what was done."
   ```

---

### 3. List mode — `list`

Steps:
1. Scan `${CLAUDE_SKILL_DIR}/../../skills/` for subdirectories containing a `SKILL.md`.
2. For each, read the `name` and `description` from the frontmatter.
3. Present as a table: name | description.

---

### 4. Search mode — `search <keywords>`

Steps:
1. Scan all skill files under `${CLAUDE_SKILL_DIR}/../../skills/`.
2. Find skills whose name, description, or body matches any keyword.
3. Present matches. If exactly one match, offer to recall it immediately.

---

### 5. Delete mode — `delete <name>`

Steps:
1. Confirm with the user before deleting.
2. Delete `${CLAUDE_SKILL_DIR}/../../skills/<name>/SKILL.md` and its parent directory if empty.
3. Confirm: "Recipe `<name>` deleted."

---

## Important Rules

- Never invent steps that didn't happen — only save what was actually executed and succeeded.
- When generalizing parameters, prefer explicit `<placeholders>` over omitting the parameter.
- If a recipe already exists for `<name>`, ask the user whether to overwrite or cancel.
- Keep steps atomic and shell-executable where possible.