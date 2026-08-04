Quickstart:

```bash
npx skills add yangpf5271/mattpocock-skills-openspec --skill=archive-proposal
```

```bash
npx skills update archive-proposal
```

[Source](https://github.com/yangpf5271/mattpocock-skills-openspec/tree/main/skills/engineering/archive-proposal)

## What it does

`archive-proposal` finalizes a finished OpenSpec change: it pre-flights that the change is actually done, gets your go-ahead, then **delegates the merge-and-file to `openspec archive`** — the CLI syncs the change's delta specs into the project's main `openspec/specs/` and files the change under `openspec/changes/archive/YYYY-MM-DD-<name>/`.

This is the step that turns a one-off change into a **permanent part of the spec's source of truth**. Without it, every new [to-proposal](https://aihero.dev/skills-to-proposal) would rewrite specs from scratch; with it, each proposal is a delta against living, accumulated truth.

## When to reach for it

You invoke this by typing `/archive-proposal` — the agent won't reach for it on its own.

Reach for it once a change's tasks are done (worked through by [implement](https://aihero.dev/skills-implement)) and you want to close the loop. It is the closing move of the spec lifecycle that [to-proposal](https://aihero.dev/skills-to-proposal) opens — the two are a pair. Don't reach for it mid-implementation; it only makes sense once the change is genuinely complete.

## Prerequisites

- The OpenSpec CLI on PATH (`npm install -g @fission-ai/openspec`).
- A change under `openspec/changes/` (created by [to-proposal](https://aihero.dev/skills-to-proposal)). [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) records the instance location and guides CLI installation if needed.

## How it merges the delta

`archive-proposal` pre-flights completion (artifacts + tasks) and asks for your confirmation, then hands the merge to `openspec archive`. The CLI owns the delta semantics — you never re-implement them:

- **ADDED Requirements** — appended to `openspec/specs/<capability>/spec.md`.
- **MODIFIED Requirements** — the matching block replaced **in full** (partial merges silently lose detail, so the CLI never merges partially).
- **REMOVED Requirements** — the matching block dropped.
- **RENAMED Requirements** — the `FROM:` / `TO:` rename applied.

The CLI shows you a summary of every change before applying, and warns (but doesn't block) on incomplete artifacts or tasks — mirroring the pre-flight the skill already did. If you need to skip the sync, use the CLI's `--skip-specs` flag.

## It's working if

- It checks artifact and task completion first, and warns (but doesn't block) if anything is incomplete.
- It delegates the sync to `openspec archive` rather than merging delta specs by hand.
- The change lands at `openspec/changes/archive/YYYY-MM-DD-<name>/` and `openspec list` no longer shows it as active.

## Where it fits

`archive-proposal` is the closing step of the spec lifecycle:

```txt
to-proposal → implement → archive-proposal
                            └─ openspec archive merges delta into openspec/specs/
```

Reach for it after implementation completes. Its key neighbour is [to-proposal](https://aihero.dev/skills-to-proposal), which creates the change that `archive-proposal` files — together they form the loop that keeps the repo's specs evolving across changes. When you're unsure which skill or flow fits, [ask-matt](https://aihero.dev/skills-ask-matt) routes you.
