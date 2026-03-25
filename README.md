# claude-memorize

A Claude Code plugin that lets you save and replay operational recipes — exact steps you've performed successfully — so you never have to research them from scratch again.

## How it works

After Claude successfully completes a multi-step operation (e.g. syncing ArgoCD, pushing an ECR image, restarting a deployment), run `/memorize:save <name>` to store those steps as a named skill. Next time, invoke `/memorize:<name>` and Claude executes the steps for you, prompting only for variable inputs.

Each saved recipe becomes its own Claude Code skill, created on the fly inside the plugin directory. Save and recall operations are delegated to a **Claude Haiku** subagent — keeping costs low while the main model handles conversation and decision-making.

## Prerequisites

- [Claude Code](https://claude.ai/code) v1.0.33 or later (`claude --version` to check)

## Installation

### From the marketplace

```
/plugin install https://github.com/grinfeld/claude-memorize
```

### For local development / testing

```bash
git clone https://github.com/grinfeld/claude-memorize.git
claude --plugin-dir ./claude-memorize
```

## Usage

### Save steps from the current conversation

After Claude has successfully completed something:

```
/memorize:save get-pods List pods in your dev cluster
```

Claude looks back through the conversation, extracts the steps that succeeded, generalizes hardcoded values into `<placeholders>`, and saves them as a new skill at `skills/get-pods/SKILL.md` inside the plugin directory.

If you omit the description, Claude infers it from your last message:

```
/memorize:save get-pods
```

You can also ask in plain language:

> "memorize this as get-pods"
> "save what you just did as get-pods"

### Recall and execute a saved recipe

```
/memorize:get-pods
```

Claude reads the recipe, shows you the steps, asks for any `<placeholder>` values, then executes them.

![get-pods example](example.png)

### Other commands

```
/memorize:list                      # show all saved recipes
/memorize:search argocd k8s         # find recipes by keyword
/memorize:delete sync-argocd        # delete a recipe (asks for confirmation)
```

## How saved recipes are stored

Each recipe is saved as a `SKILL.md` inside the plugin's `skills/` directory:

```
<plugin-dir>/
  skills/
    memorize/          ← the core memorize skill (ships with the plugin)
      SKILL.md
    get-pods/          ← created on first save
      SKILL.md
    sync-argocd/       ← created on first save
      SKILL.md
    ...
```

Each generated skill file looks like:

```markdown
---
name: get-pods
description: List pods in your dev cluster
disable-model-invocation: true
---

List pods in your dev cluster

## Steps

1. Ask for the target namespace if not provided
2. Run: `kubectl get pods -n <namespace>`

## Notes

- Requires kubectl configured with the right context
```

You can edit skill files directly — they're just Markdown.

## Full Example

First request:

```
> Let me get the pods in the kube-system namespace.
  Bash(kubectl get pods -n kube-system)
  ⎿  NAME                              READY   STATUS    RESTARTS
     coredns-xxx                       1/1     Running   0
     ...

> /memorize:save get-pods List pods in your dev cluster, asking for namespace
  Recipe `get-pods` saved. Invoke it with /memorize:get-pods
```

Second request (new session):

```
> /memorize:get-pods
  Which namespace? > kube-system
  Bash(kubectl get pods -n kube-system)
  ⎿  NAME                              READY   STATUS    RESTARTS
     coredns-xxx                       1/1     Running   0
     ...
```

## License

MIT