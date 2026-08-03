Quickstart:

```bash
npx skills add mattpocock/skills --skill=archive-proposal
```

```bash
npx skills update archive-proposal
```

[Source](https://github.com/mattpocock/skills/tree/main/skills/engineering/archive-proposal)

## What it does

`archive-proposal` finalizes a finished OpenSpec change: it syncs the change's delta specs into the project's main `openspec/specs/`, then files the change under `openspec/changes/archive/YYYY-MM-DD-<name>/`.

This is the step that turns a one-off change into a **permanent part of the spec's source of truth**. Without it, every new [to-proposal](https://aihero.dev/skills-to-proposal) would rewrite specs from scratch; with it, each proposal is a delta against living, accumulated truth.

## When to reach for it

You invoke this by typing `/archive-proposal` — the agent won't reach for it on its own.

Reach for it once a change's tasks are done (worked through by [implement](https://aihero.dev/skills-implement)) and you want to close the loop. It is the closing move of the spec lifecycle that [to-proposal](https://aihero.dev/skills-to-proposal) opens — the two are a pair. Don't reach for it mid-implementation; it only makes sense once the change is genuinely complete.

## Prerequisites

- The OpenSpec CLI on PATH (`npm install -g @fission-ai/openspec`).
- A change under `openspec/changes/` (created by [to-proposal](https://aihero.dev/skills-to-proposal)). [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) records the instance location and guides CLI installation if needed.

## How it merges the delta

Before filing, `archive-proposal` checks the change's delta specs and, with your confirmation, applies them to the main specs:

- **ADDED Requirements** — appended to `openspec/specs/<capability>/spec.md`.
- **MODIFIED Requirements** — the matching block replaced **in full** (partial merges silently lose detail, so it never merges partially).
- **REMOVED Requirements** — the matching block dropped.
- **RENAMED Requirements** — the `FROM:` / `TO:` rename applied.

It shows you a combined summary of every change across all capabilities before asking whether to sync. If you skip the sync, the change is still archived but the delta is frozen in the archive — the main specs won't reflect it.

## It's working if

- It checks artifact and task completion first, and warns (but doesn't block) if anything is incomplete.
- It shows you exactly what the delta sync will change before doing it.
- The change lands at `openspec/changes/archive/YYYY-MM-DD-<name>/` and `openspec list` no longer shows it as active.

## Where it fits

`archive-proposal` is the closing step of the spec lifecycle:

```txt
to-proposal → implement → archive-proposal
                            └─ merges delta into openspec/specs/
```

Reach for it after implementation completes. Its key neighbour is [to-proposal](https://aihero.dev/skills-to-proposal), which creates the change that `archive-proposal` files — together they form the loop that keeps the repo's specs evolving across changes. When you're unsure which skill or flow fits, [ask-matt](https://aihero.dev/skills-ask-matt) routes you.
