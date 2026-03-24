# claude-memorize

A Claude Code slash command that lets you save and replay operational recipes — exact steps you've performed successfully — so you never have to research them from scratch again.

## How it works

After Claude successfully completes a multi-step operation (e.g. syncing ArgoCD, pushing an ECR image, restarting a deployment), you can save those steps as a named recipe. Next time, recall the recipe by name and Claude executes the steps for you, prompting only for variable inputs.

The installer also patches `~/.claude/CLAUDE.md` so Claude automatically checks for matching recipes before researching any operational task from scratch, and suggests saving steps after success.

## Installation

### One-liner (recommended)

```bash
git clone https://github.com/grinfeld/claude-memorize.git /tmp/claude-memorize && \
  chmod +x /tmp/claude-memorize/install.sh && \
  /tmp/claude-memorize/install.sh && \
  rm -rf /tmp/claude-memorize
```

### Manual

```bash
git clone https://github.com/grinfeld/claude-memorize.git
cd claude-memorize
chmod +x install.sh
./install.sh
```

If you prefer to install manually without running the installer, copy `memorize.md` to `~/.claude/commands/memorize.md`. That's all that's needed for `/memorize` to appear in Claude Code.

### What the installer sets up

- `~/.claude/commands/memorize.md` — command prompt Claude reads when you invoke `/memorize`
- `~/.claude/skills/memorize/index.md` — auto-maintained recipe index
- `~/.claude/skills/memorize/recipes/` — individual recipe files
- `~/.claude/CLAUDE.md` — appended with memorize behavior rules (idempotent)

## Usage

### Save steps from the current conversation

After Claude has successfully completed something:

```
/memorize sync_argocd Store steps for syncing an ArgoCD application
```

Claude looks back through the conversation, extracts the steps that succeeded, generalizes hardcoded values into `<placeholders>`, and saves them as `~/.claude/skills/memorize/recipes/sync_argocd.md`.

### Recall and execute a saved recipe

```
/memorize sync_argocd
```

Claude reads the recipe, shows you the steps, asks for any `<placeholder>` values, then executes them.

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
**Times used**: 3

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

~/.claude/skills/memorize/
  index.md                     ← searchable recipe index
  recipes/
    sync_argocd.md
    push_ecr_image.md
    ...
```

## Updating

```bash
git clone https://github.com/grinfeld/claude-memorize.git /tmp/claude-memorize && \
  /tmp/claude-memorize/install.sh && \
  rm -rf /tmp/claude-memorize
```

Existing recipes and `index.md` are never overwritten. The `CLAUDE.md` block is only appended once (idempotent check on the `## Memorize Skill` marker).