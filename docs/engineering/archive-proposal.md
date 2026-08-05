## What it does

`archive-proposal` finalizes a finished OpenSpec change. It checks artifact and task completion, gets explicit confirmation, then delegates to `openspec archive --yes`. The CLI syncs the change's delta specs into `openspec/specs/` and files the change under `openspec/changes/archive/YYYY-MM-DD-<name>/`.

This turns a completed change into part of the spec's living baseline. The skill never reimplements OpenSpec's merge or move rules by hand.

## When to reach for it

You invoke this by typing `/archive-proposal`; the agent will not reach for it on its own.

Use it after [implement](https://aihero.dev/skills-implement) has completed the change and every applicable `tasks.md` checkbox reflects reality. It is the closing move paired with [to-proposal](https://aihero.dev/skills-to-proposal), not an implementation step.

The OpenSpec CLI and an active change under `openspec/changes/` are prerequisites. [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) records the instance location and can guide CLI installation.

## Common questions

**What if tasks or artifacts are incomplete?**

The skill reports the incomplete work before asking for confirmation. OpenSpec may permit archiving with warnings, but the user sees those warnings and makes the decision explicitly.

**Does the skill merge ADDED and MODIFIED requirements itself?**

No. It calls `openspec archive`, which owns ADDED, MODIFIED, REMOVED, and RENAMED semantics. Keeping those rules in the CLI prevents this skill from drifting from the installed OpenSpec version.

**Why pass `--yes` if confirmation is required?**

The skill obtains confirmation first, then uses `--yes` only to prevent a second CLI prompt for the same outward-facing archive action.

**Can I archive without syncing specs?**

Use OpenSpec's `--skip-specs` option only when that is an intentional exception. The normal lifecycle syncs the deltas so the next proposal starts from updated truth.

## It's working if

- It reports artifact and task completion before performing the archive.
- It obtains one explicit confirmation after showing any warnings.
- The trace shows `openspec archive`, not hand-written delta merging or filesystem moves.
- The change lands under `openspec/changes/archive/YYYY-MM-DD-<name>/` and no longer appears as active.
- `openspec/specs/` reflects the archived delta unless `--skip-specs` was explicitly chosen.

## Where it fits

`archive-proposal` closes both OpenSpec implementation paths:

```text
to-proposal → implement → archive-proposal
to-proposal → to-tickets → implement → archive-proposal
```

[to-proposal](https://aihero.dev/skills-to-proposal) creates the change, [implement](https://aihero.dev/skills-implement) keeps `tasks.md` accurate as work lands, and this skill delegates the final merge and filing to OpenSpec. [ask-matt](https://aihero.dev/skills-ask-matt) routes the full lifecycle.
