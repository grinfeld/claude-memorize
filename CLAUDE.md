## Memorize Plugin

- Before starting any operational task, scan `${CLAUDE_SKILL_DIR}/../../skills/` for a matching recipe and check if a relevant skill exists. If found, suggest using it.
- After completing any multi-step operational task successfully, suggest to the user: "Want me to memorize these steps? Run `/memorize:save <suggested-name> <description>`"
- If the user says "from memory" or "use memorized steps", invoke the matching `/memorize:<name>` skill.