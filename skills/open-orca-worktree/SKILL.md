---
name: open-orca-worktree
description: Use when the user says "open a new worktree", "create a new worktree", or asks to start work in a separate Orca worktree. Collect task and base details before creating an Orca-managed worktree.
---

# Open An Orca Worktree

Use the `orca-cli` skill for current, version-matched command guidance. Use Orca commands rather than raw `git worktree` commands.

## Gather Details First

Before creating anything, ask for these details in one concise prompt:

1. The task or purpose of the new worktree.
2. Whether it is independent work based on the repository default branch or stacked work based on the current/specified branch. Recommend the repository default for independent work.
3. The worktree name, or permission to derive a short lowercase kebab-case name from the task.
4. Whether to reveal the new worktree in Orca immediately.

Explain only when relevant that these are separate values:

- The worktree name controls the Orca worktree name and checkout directory.
- The display name is an optional editable UI label and can differ from the worktree name.
- The Git branch is separate from both names.

Do not create the worktree until the user answers. Do not ask for information already supplied in the request or conversation.

## Create The Worktree

Resolve the Orca executable and load the version-matched `orca-cli` guide before running Orca commands. Confirm Orca status if it has not been checked during the current turn.

For independent work, create from the repository default base and do not attach parent lineage:

```text
ORCA worktree create --name <worktree-name> --no-parent --json
```

Omit `--base-branch` so Orca uses the configured repository default. Add `--activate` only when the user asked to reveal the worktree immediately.

For stacked or related work, make the relationship and base explicit:

```text
ORCA worktree create --name <worktree-name> --parent-worktree active --base-branch <branch-or-ref> --json
```

If the user requests a separate display name, use the complete worktree ID returned by the create command:

```text
ORCA worktree set --worktree id:<repo-id>::<worktree-path> --display-name "<display-name>" --json
```

Do not launch or hand work to another agent unless the user explicitly requests it. If they do, follow the `orca-cli` handoff guidance and prefer `worktree create --agent <agent> --prompt <task>` rather than creating a duplicate terminal afterward.

## Report The Result

Return the created worktree's:

- Display name, if set
- Worktree name and path
- Git branch
- Base branch/ref
- Whether it is independent or a child of another Orca worktree

Use the create response and, when necessary, `ORCA worktree show` or Git metadata to verify these values rather than inferring them from names.
