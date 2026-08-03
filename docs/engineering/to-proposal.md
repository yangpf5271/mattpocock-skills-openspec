Quickstart:

```bash
npx skills add mattpocock/skills --skill=to-proposal
```

```bash
npx skills update to-proposal
```

[Source](https://github.com/mattpocock/skills/tree/main/skills/engineering/to-proposal)

## What it does

`to-proposal` turns the current conversation into an OpenSpec **change** — `proposal.md`, `design.md`, delta `specs/`, and `tasks.md` — that lives in the repo at `openspec/changes/<name>/`.

The defining difference from [to-spec](https://aihero.dev/skills-to-spec): `to-spec` publishes the spec to your **issue tracker** (out of the repo); `to-proposal` sinks the same thinking into the **repo itself**, so the spec becomes a versioned, auditable source of truth that future changes build on as deltas rather than rewrites.

It does **not** interview you again. Like `to-spec`, it synthesises what the grilling or spec thread already established.

## When to reach for it

You invoke this by typing `/to-proposal` — the agent won't reach for it on its own.

Reach for it once a change has been talked through and you want the spec to live **in the repo and evolve across changes**, not just sit on the tracker. It pairs naturally with [to-spec](https://aihero.dev/skills-to-spec): run `to-spec` to publish to the tracker, then `to-proposal` to sink the same thinking into OpenSpec — or skip the tracker entirely and use `to-proposal` alone. When the implementation is done, close the loop with [archive-proposal](https://aihero.dev/skills-archive-proposal).

## Prerequisites

- The OpenSpec CLI on PATH (`npm install -g @fission-ai/openspec`).
- An OpenSpec instance initialized in the repo (`openspec/changes/`, `openspec/specs/`). [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) records the instance location in `docs/agents/openspec-instance.md` and will guide you through installing the CLI and running `openspec init` if either is missing.

## From conversation to change

`to-proposal` bridges the conversation's content into OpenSpec's artifacts:

- **proposal.md** — the *why* and *what* (Problem Statement, Solution, User Stories, Out of Scope).
- **design.md** — the *how* (Implementation Decisions, the seams chosen, Testing Decisions).
- **specs/\<capability\>/spec.md** — User Stories recast as SHALL/MUST requirements, each with WHEN/THEN scenarios. This is the **delta** — what this change adds or modifies.
- **tasks.md** — the tracer-bullet slices, as `- [ ]` checkboxes so progress is machine-trackable.

It follows the OpenSpec dependency chain in order — proposal unlocks design and specs; those unlock tasks — and stops when the change is ready to implement.

## It's working if

- It scaffolds `openspec/changes/<name>/` and fills every artifact the schema requires, not just `proposal.md`.
- It maps your conversation's content into the right artifact (decisions into `design.md`, stories into `specs/`, slices into `tasks.md`) instead of dumping everything into one file.
- `openspec status --change <name>` shows the change as apply-ready when it finishes.

## Where it fits

`to-proposal` is the in-repo alternative to [to-spec](https://aihero.dev/skills-to-spec) in the build chain, and the opener of the spec lifecycle:

```txt
grill-with-docs → to-spec → to-proposal → implement → archive-proposal
```

Reach for it after the plan is resolved and before implementation begins. Its key neighbours are [to-spec](https://aihero.dev/skills-to-spec), which publishes the same thinking to the tracker, and [archive-proposal](https://aihero.dev/skills-archive-proposal), which merges the finished change's delta into `openspec/specs/` so the next proposal builds on updated truth. When you're unsure which skill or flow fits, [ask-matt](https://aihero.dev/skills-ask-matt) routes you.
