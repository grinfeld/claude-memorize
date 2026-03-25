# Privacy Policy

**Last updated: 2026-03-24**

## Overview

claude-memorize is a Claude Code skill that saves and replays operational step recipes locally on your machine. It does not collect, transmit, or share any personal data.

## Data Collected

This skill does not collect any data. All information is stored exclusively on your local machine in the following locations:

- `~/.claude/skills/memorize/index.md` — recipe index
- `~/.claude/skills/memorize/recipes/` — individual recipe files
- `~/.claude/commands/memorize/` — per-recipe subcommand files
- `~/.claude/CLAUDE.md` — behavior rules block (appended once)
- `~/.claude/settings.json` — permissions entries

Recipe files may contain command-line steps, placeholder names, and notes you choose to save. This content never leaves your machine.

## Permissions

`install.sh` adds the following entries to `~/.claude/settings.json` so Claude never prompts for approval when reading or writing recipes:

- `Read(~/.claude/commands/memorize/*)` — read per-recipe subcommand files
- `Write(~/.claude/commands/memorize/*)` — create/delete per-recipe subcommand files
- `Read(~/.claude/skills/memorize/index.md)` — read the recipe index
- `Write(~/.claude/skills/memorize/index.md)` — update the recipe index
- `Read(~/.claude/skills/memorize/recipes/*)` — read saved recipes
- `Write(~/.claude/skills/memorize/recipes/*)` — save and delete recipes

No other paths are accessed.

## No Network Access

This skill does not make any network requests. It reads and writes local files only.

## No Third-Party Sharing

No data is shared with the author, Anthropic, or any third party.

## Claude AI Processing

When you use `/memorize` commands, the content of your conversation and recipe files is processed by Claude (via Claude Code) to extract and replay steps. This processing is subject to [Anthropic's Privacy Policy](https://www.anthropic.com/privacy).

## Contact

For questions, open an issue at https://github.com/grinfeld/claude-memorize/issues