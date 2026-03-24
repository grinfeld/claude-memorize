# claude-memorize

A Claude Code plugin that lets you save and replay operational recipes — exact steps you've performed successfully — so you never have to research them from scratch again.

## How it works

After Claude successfully completes a multi-step operation (e.g. syncing ArgoCD, pushing an ECR image, restarting a deployment), you can save those steps as a named recipe. Next time, recall the recipe by name and Claude executes the steps for you, prompting only for variable inputs.

The plugin patches `~/.claude/CLAUDE.md` so Claude automatically checks for matching recipes before researching any operational task from scratch, and suggests saving steps after success.

Save and recall operations are delegated to a **Claude Haiku** subagent — keeping costs low while the main model handles conversation and decision-making.

## Prerequisites

- [Claude Code](https://claude.ai/code) installed and configured
- `bash` (macOS/Linux)
- `python3` (only needed for manual install)
- `git` (only needed for manual install)

## Installation

### Plugin install (recommended)

```
/plugin install github:grinfeld/claude-memorize
```

Then run the post-install setup once to initialize recipe storage and inject behavior rules:

```bash
~/.claude/plugins/memorize/install.sh
```

### Manual install

```bash
git clone https://github.com/grinfeld/claude-memorize.git /tmp/claude-memorize && \
  MANUAL_INSTALL=1 /tmp/claude-memorize/install.sh && \
  rm -rf /tmp/claude-memorize
```

### What gets set up

- `~/.claude/commands/memorize.md` — command prompt Claude reads when you invoke `/memorize`
- `~/.claude/commands/memorize/<name>.md` — per-recipe subcommands for autocomplete (auto-maintained)
- `~/.claude/skills/memorize/index.md` — auto-maintained recipe index
- `~/.claude/skills/memorize/recipes/` — individual recipe files
- `~/.claude/CLAUDE.md` — appended with memorize behavior rules (idempotent)
- `~/.claude/settings.json` — `Write(~/.claude/commands/memorize/*)` permission added so Claude never prompts for approval when saving a recipe subcommand

## Usage

### Save steps from the current conversation

After Claude has successfully completed something:

```
/memorize sync_argocd Store steps for syncing an ArgoCD application
```

Claude looks back through the conversation, extracts the steps that succeeded, generalizes hardcoded values into `<placeholders>`, and saves them as `~/.claude/skills/memorize/recipes/sync_argocd.md`.

If you omit the description, Claude uses your last message as the description:

```
/memorize get-pods
```

This is handy when your last prompt already describes what you did (e.g. "get all pods in the kube-system namespace").

You can also just ask Claude in plain language:

> "memorize this as get-pods"
> "save what you just did into /memorize as get-pods"
> "store the last steps in /memorize with name get-pods"

Claude will invoke `/memorize get-pods` using your last message as the description.

### Recall and execute a saved recipe

```
/memorize sync_argocd
```

Claude reads the recipe, shows you the steps, asks for any `<placeholder>` values, then executes them.

Each saved recipe also registers as a subcommand, so you get autocomplete:

```
/memorize/sync_   →  /memorize/sync_argocd
/memorize/push_   →  /memorize/push_ecr_image
```

You can also reference recipes naturally in conversation:

> "sync argocd from memory"
> "do the ecr push thing we memorized"

Claude will check the index and recall the best match automatically.

### Other commands

```
/memorize list                    # show all saved recipes
/memorize search argocd k8s       # find recipes by keyword
/memorize delete sync_argocd      # delete a recipe (asks for confirmation)
```

## Recipe format

Each recipe is a plain Markdown file at `~/.claude/skills/memorize/recipes/<name>.md`:

```markdown
# sync_argocd

**Description**: Sync an ArgoCD application from the CLI
**Tags**: argocd, gitops, k8s
**Last updated**: 2026-03-24

## Steps

1. List applications: `kubectl --context shared-eks -n argocd-nonprod get applications`
2. Trigger sync: `argocd app sync <app-name>`
3. Wait for health: `argocd app wait <app-name> --health`

## Notes

- ArgoCD runs on shared-eks, namespace argocd-nonprod
- Credentials must already be configured via `argocd login`
```

You can edit recipe files directly — they're just Markdown.

## File layout after install

```
~/.claude/commands/
  memorize.md                  ← command prompt (Claude reads this on /memorize)
  memorize/
    sync_argocd.md             ← autocomplete subcommand (/memorize/sync_argocd)
    push_ecr_image.md          ← autocomplete subcommand (/memorize/push_ecr_image)
    ...                        ← auto-created on save, auto-deleted on delete

~/.claude/skills/memorize/
  index.md                     ← searchable recipe index
  recipes/
    sync_argocd.md
    push_ecr_image.md
    ...
```

## Updating

```
/plugin update memorize
```

Then re-run `install.sh` if the post-install setup has changed.

Existing recipes and `index.md` are never overwritten. The `CLAUDE.md` block is only appended once (idempotent check on the `## Memorize Skill` marker).