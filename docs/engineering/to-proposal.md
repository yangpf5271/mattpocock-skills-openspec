## What it does

`to-proposal` turns the current conversation into an OpenSpec **change** under `openspec/changes/<name>/`: `proposal.md`, `design.md`, delta `specs/`, and a vertical-slice `tasks.md` checklist.

The defining difference from [to-spec](https://aihero.dev/skills-to-spec) is where the result lives. `to-spec` publishes to the issue tracker; `to-proposal` writes versioned artifacts into the repo, so later changes can describe deltas against specs that already reflect earlier work. It does not interview you again. It synthesizes what the grilling or spec thread already settled.

## When to reach for it

You invoke this by typing `/to-proposal`; the agent will not reach for it on its own.

Use it after a change has been talked through when the spec should remain an evolving in-repo source of truth. It can follow [to-spec](https://aihero.dev/skills-to-spec), or replace it when no tracker spec is needed. After it runs, choose between two paths:

| Need | Next step |
| --- | --- |
| Lightweight implementation from the repo checklist | [implement](https://aihero.dev/skills-implement) directly |
| Tracker collaboration, blocking edges, or one ticket per session | [to-tickets](https://aihero.dev/skills-to-tickets), which promotes each `tasks.md` group |

The OpenSpec CLI and an initialized instance are prerequisites. [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) can install or initialize them and records the instance in `docs/agents/openspec-instance.md`.

## Common questions

**Does it replace `to-spec`?**

Not necessarily. They perform the same synthesis job for different destinations. Use `to-spec` when the tracker is the durable record, `to-proposal` when the repo should hold evolving specs, or both when the team needs both surfaces.

**Does it only write a proposal?**

No. It follows the schema dependency graph until every required artifact is complete: proposal, design, delta specs, then tasks. A proposal without the downstream artifacts is not apply-ready.

**How are existing specs handled?**

The main `openspec/specs/` tree is the baseline. New behavior goes under `## ADDED Requirements`; changes to an existing requirement use `## MODIFIED Requirements` and restate the complete requirement block. The skill does not treat every request as an addition.

**Are `tasks.md` groups tickets?**

They are the OpenSpec implementation checklist and archive record. Each numbered group is deliberately ticket-sized, but it becomes a tracker ticket only if `to-tickets` promotes it and writes a plain `**Ticket:**` backlink.

## It's working if

- `openspec/changes/<name>/` contains every artifact required by the active schema.
- Decisions land in `design.md`, behavior lands in delta specs, and implementation slices land in `tasks.md` instead of being dumped into one file.
- Every task is an exact `- [ ]` checkbox under a numbered `## N.` vertical-slice group.
- `openspec status --change <name>` reports the change apply-ready.
- The checklist can be implemented directly or promoted to tickets without re-breaking the work from scratch.

## Where it fits

`to-proposal` opens the optional in-repo spec lifecycle:

```text
grill-with-docs → to-spec → to-proposal ──┬─→ implement → archive-proposal
                                           └─→ to-tickets → implement → archive-proposal
```

Its upstream neighbor is [to-spec](https://aihero.dev/skills-to-spec), its optional collaboration step is [to-tickets](https://aihero.dev/skills-to-tickets), and [archive-proposal](https://aihero.dev/skills-archive-proposal) closes the loop by delegating the delta merge to `openspec archive`. [ask-matt](https://aihero.dev/skills-ask-matt) routes the full flow.
