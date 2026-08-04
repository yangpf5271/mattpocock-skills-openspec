---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker — edges as text in one file per ticket locally, or native blocking links on a real tracker.
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

When this flow runs with OpenSpec (`/to-proposal` produced an OpenSpec change at `openspec/changes/<name>/`), `tasks.md` remains the OpenSpec implementation checklist. Treat each vertical `## N.` group as a ticket candidate: `/to-tickets` promotes those groups into tracker tickets by adding ticket-specific parameters (What to build, Blocked by, status/label, tracker identity) and linking the published tickets back. OpenSpec is still the archive; the tracker is the collaboration surface.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments.

If an OpenSpec change exists (`openspec/changes/<name>/`), read its `proposal.md`, `design.md`, delta `specs/`, and `tasks.md` before drafting anything. `tasks.md` is the OpenSpec checklist: parse each `## N.` group as one ticket candidate, with its `- [ ]` checkbox lines as the candidate acceptance criteria. Keep any existing plain-text ticket link lines (for example `**Ticket:** ...`) — they are rerun protection.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft or promote vertical slices

If this is **not** an OpenSpec flow, break the work into **tracer bullet** tickets.

If this **is** an OpenSpec flow, start from `openspec/changes/<name>/tasks.md` instead of re-breaking from scratch:

- Treat each numbered `## N.` group as one ticket candidate.
- Treat each `- [ ]` checkbox in that group as an acceptance criterion.
- Derive the ticket title from the group heading.
- Derive **What to build** from the group heading, its checkbox criteria, and the proposal/design context.
- Add **Blocked by** edges from the ordering and the actual dependency logic; don't assume every earlier group blocks every later group.
- If a group already has a `**Ticket:** <url-or-path>` line, do not create a duplicate ticket. Plan to update the existing ticket if needed, or skip it if it is already correct.

Only split, merge, or reorder OpenSpec groups when the existing `tasks.md` is not a valid ticket-sized vertical-slice plan, or when the user approves the change during the quiz. When you do change slice boundaries, update `tasks.md` first, preserving any completed `- [x]` items and existing ticket links that still apply; then publish from the updated groups.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?

Iterate until the user approves the breakdown.

### 5. Publish, update, or reuse the tickets on the configured tracker

Publish the approved tickets, or update/reuse existing linked tickets when this is an OpenSpec rerun. **How** depends on the tracker `/setup-matt-pocock-skills` configured — the tickets are the same either way, only the shape of the blocking edges changes:

- **Local files** → write one file per new ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). If the matching OpenSpec group already has a `**Ticket:**` local path, update that file in place or skip it if already correct; do not create a second file for the same group. Each file's "Blocked by" lists the numbers/titles it depends on. Use the per-ticket file template below — one ticket per file, never a single combined file.
- **A real issue tracker (GitHub, Linear, …)** → publish one new issue per unlinked ticket in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers. If the matching OpenSpec group already has a `**Ticket:**` URL, update that issue if needed or skip it if already correct; do not create a duplicate issue. Use the platform's native blocking / sub-issue relationship where it has one; otherwise set each ticket's "Blocked by" to the blocking issues. Apply the `ready-for-agent` triage label unless instructed otherwise — the tickets are agent-grabbable by construction.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue.

<local-ticket-template>

# <NN> — <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None — can start immediately".

**Status:** ready-for-agent

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</local-ticket-template>

<issue-template>

## Parent

A reference to the parent issue on the tracker (if the source was an existing issue, otherwise omit this section).

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- A reference to each blocking ticket, or "None — can start immediately".

</issue-template>

In either form, avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

### 6. Link published tickets back to tasks.md (OpenSpec flow only)

Skip this step entirely if this flow has no OpenSpec change — i.e. no `openspec/changes/<name>/` was produced by `/to-proposal`.

If an OpenSpec change exists, `tasks.md` remains the OpenSpec checklist. It does not become the tracker, but it should carry a lightweight backlink so future runs and `/implement` can map a checklist group to its ticket:

1. For each successfully published or reused ticket, add or update a plain non-checkbox line under the matching `## N.` group, e.g. `**Ticket:** <url-or-local-path>`.
2. Do not change checkbox text or reset completion state. Preserve every `- [x]` as complete.
3. Do not create duplicate tickets for groups that already have a `**Ticket:**` link. Update the existing ticket if its ticket-specific fields are stale, or skip it if it already matches.
4. Keep the format OpenSpec's apply/archive parses: numbered `## N.` headings, every task an exact `- [ ]` or `- [x]` checkbox. Ticket links must stay on plain non-checkbox lines.
5. Verify with `openspec status --change "<name>"` that the change is still apply-ready (all artifacts `done`).

Because `tasks.md` is the OpenSpec checklist and tickets are the collaboration surface, `/implement` works in two modes: when tickets exist, drive ticket state on the tracker and then check off the corresponding `tasks.md` lines; when tickets do not exist, work directly from `tasks.md` and check it off as the implementation lands. `openspec archive` reads **only** `tasks.md` for completion, so the checklist must stay accurate in both modes.
