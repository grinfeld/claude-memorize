## Memorize Skill

- Before starting any operational task, read `~/.claude/skills/memorize/index.md`
  and check if a matching recipe exists. If found, use it instead of researching from scratch.
- After completing any multi-step operational task successfully, suggest to the user:
  "Want me to memorize these steps? Run `/memorize <suggested-name> <description>`"
- If the user says "from memory" or "use memorized steps" in any prompt, check
  `~/.claude/skills/memorize/index.md` for a matching recipe and recall it.
