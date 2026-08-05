---
name: to-tickets
description: 生成实施 tickets：Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker — edges as text in one file per ticket locally, or native blocking links on a real tracker.
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not. The exception is an OpenSpec change whose tasks are already all complete and have never been promoted; that path performs no tracker operations.

When this flow runs with OpenSpec (`/to-proposal` produced an OpenSpec change at `openspec/changes/<name>/`), `tasks.md` remains the OpenSpec implementation checklist and archive record. Its numbered groups own the vertical-slice boundaries and completion state. Once the change is promoted, each group maps to one tracker ticket; the ticket adds executable detail, blocking edges, status, assignment, comments, and tracker identity. OpenSpec is the archive; the tracker is the collaboration surface.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments.

If an OpenSpec change exists (`openspec/changes/<name>/`), read its `proposal.md`, `design.md`, delta `specs/`, and `tasks.md` before drafting anything. Parse every numbered `## N.` group and every exact `- [ ]` or `- [x]` checkbox. A group with no valid checkbox is malformed: stop and ask the user to fix the checklist rather than creating an empty ticket.

Inventory every plain `**Ticket:** <url-or-path>` line. Zero backlinks under a group is the normal first-promotion state. Exactly one valid backlink owns the tracker identity and prevents duplicate creation, so fetch that linked ticket and read its body, labels/status, blocking relationships, and open/closed state. Multiple backlinks under one group are ambiguous: stop before preview or tracker writes and ask the user which identity to keep. If a recorded backlink is inaccessible, points at missing work, or targets the wrong ticket, stop and ask how to repair it; do not silently create a replacement.

Classify each group from `tasks.md`:

- **Not started** — every item is `- [ ]`.
- **Partially complete** — the group contains both `- [x]` and `- [ ]`.
- **Complete** — every item is `- [x]`.

`tasks.md` checkbox state is authoritative for OpenSpec completion and archive preflight. Tracker state is authoritative for collaboration state, but it must never silently turn an unchecked OpenSpec item into a completed one.

If every group is complete and there are no backlinks anywhere in the change, stop here. Perform no tracker read or write, create no tickets or backlinks, and tell the user that no implementation work remains to promote and `/archive-proposal` is next.

If every group is complete and at least one backlink exists, continue to the preview as a reconciliation run. Reuse linked tickets. For any unlinked group, preview a minimal completed ticket only if the user wants to finish the one-group-to-one-ticket mapping; do not create it by default.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft or promote vertical slices

If this is **not** an OpenSpec flow, break the work into **tracer bullet** tickets.

If this **is** an OpenSpec flow, start from `openspec/changes/<name>/tasks.md` instead of re-breaking from scratch. Keep one proposed ticket per numbered group whenever promotion proceeds:

- Derive the ticket title from the group heading.
- Derive **What to build** from the complete group plus proposal/design context.
- For a **not-started group**, preserve every checkbox title as an unchecked acceptance criterion and expand each one with the detail needed to make it executable and verifiable.
- For a **partially complete group**, preserve completed checkbox titles verbatim as `- [x]` without expanding them. Preserve unchecked titles as `- [ ]` and expand only those items with executable and verifiable detail. The ticket represents the complete slice, while `/implement` works only the unchecked items.
- For a **complete group** in a mixed change, propose a minimal completed ticket: the group title plus only the status and dependency metadata the tracker needs. It has no work payload, receives no `ready-for-agent` label, is backlinked, and is immediately closed or marked `resolved`. It never enters the implementation frontier.
- Add **Blocked by** edges from the complete group dependency graph; don't assume every earlier group blocks every later group. A completed ticket remains a historical dependency node, but because it is closed or `resolved`, the edge is already satisfied and does not block the live frontier.
- If a group already has a valid `**Ticket:**` link, plan to reuse and reconcile that ticket; never create a duplicate.

Compare linked ticket state with `tasks.md`:

- Complete group + open ticket → preview closing the ticket and removing `ready-for-agent`.
- Incomplete or partial group + closed ticket → show a conflict. Ask whether the tracker was closed incorrectly or the implementation really completed. If the tracker is wrong, preview reopening it. If the work is complete, include the proposed `tasks.md` checkbox changes in the final preview, then recalculate and show the resulting group and ticket state. Apply neither resolution until the user approves the complete preview. Never infer completion from the closed ticket alone.
- Matching state and content → reuse without rewriting lifecycle state.
- Stale title, body, criteria, or blocking edges → preview the exact update.

Only propose changing OpenSpec group boundaries or checkbox items when the current checklist is not a valid ticket-sized vertical-slice plan, when agreed required work is missing, or when the user explicitly asks to change the OpenSpec archive boundary. Approval is the gate for applying a justified revision, not an independent reason to rewrite a valid checklist. Show the exact revision in the preview and preserve completed `- [x]` items and valid backlinks that still apply. After approval, update `tasks.md` before publishing from the revised groups.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

### 4. Quiz the user

Before presenting the preview, stop, ask the user for clarification, and wait when any condition prevents a defensible or publishable breakdown. Do not guess through these blockers:

- The source requirements contradict each other.
- A missing business rule changes what should be built.
- The tracker configuration is missing or ambiguous.
- A proposed OpenSpec revision would discard completed work rather than preserve it.
- `tasks.md` and a linked ticket disagree about whether work is complete.

For a non-OpenSpec flow, present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

For an OpenSpec flow, preview every group and show:

- **Progress**: completed items / total items
- **Action**: Create, Reuse, Update, Reopen, Close as completed, or Skip the whole ticketing step
- **Already complete**: exact completed item titles
- **Remaining work**: unchecked item titles plus the proposed executable detail
- **Blocked by**: the full dependency edges, marking completed blockers as satisfied
- Any proposed `tasks.md` revision or tracker/checklist state conflict

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?
- For an OpenSpec flow, are the proposed ticket states and any justified `tasks.md` revisions correct?

Iterate until the user approves the breakdown. Rejection causes no writes: do not modify `tasks.md`, create/update/reuse/close/reopen tracker tickets, add dependencies, or write backlinks before approval.

### 5. Publish, update, or reuse the approved tickets

Follow the tracker workflow that `/setup-matt-pocock-skills` configured. Resolve the canonical `ready-for-agent` role through `docs/agents/triage-labels.md` before applying or removing a real-tracker label or setting a local open `Status:` value; do not assume the configured string is literally `ready-for-agent`. If the workflow's read/create/update/status/close/reopen or dependency read/add/remove operations are missing or ambiguous for an action in the approved preview, stop and ask instead of guessing.

Process only OpenSpec groups whose approved action is not **Skip**, in dependency order, blockers first. For each selected group:

1. Reuse the valid linked ticket, or create the minimum tracker record needed to obtain its stable URL/path.
2. Immediately add or update the group's single plain `**Ticket:** <url-or-path>` backlink. If this write fails after creation, stop and report the created identity; do not create more tickets until the backlink is recorded.
3. Apply the approved body, acceptance criteria, dependency, label, and lifecycle state.
4. For a complete group, omit `ready-for-agent`, remove it if present, and close the real-tracker issue or set the local file to `Status: resolved`.
5. For a partial or not-started group, keep an existing active/claimed state when it is still accurate; otherwise make it open and use the configured status/label for the canonical `ready-for-agent` role.

For a non-OpenSpec flow, publish the approved tickets normally:

- **Local files** → write one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first).
- **A real issue tracker (GitHub, Linear, …)** → publish one issue per ticket in dependency order so each ticket's blocking edges can reference real identifiers. Use native blocking / sub-issue relationships where available; otherwise write **Blocked by** references. Apply `ready-for-agent` unless instructed otherwise.

Work the **frontier**: any open ticket whose blockers are all done. Completed tickets are not frontier work; they only preserve the historical graph. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue.

<local-ticket-template>

# <NN> — <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None — can start immediately".

**Status:** <configured label string for the canonical `ready-for-agent` role>

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</local-ticket-template>

<partial-openspec-ticket-template>

# <NN> — <OpenSpec group title>

**What to build:** the complete end-to-end slice represented by this group, with implementation detail focused on the remaining work.

**Blocked by:** the tickets this slice depends on, including completed tickets as satisfied historical edges.

**Status:** <configured label string for the canonical `ready-for-agent` role>

- [x] Exact completed checkbox title
- [ ] Exact remaining checkbox title
  - Executable or verifiable detail for this remaining item

</partial-openspec-ticket-template>

<completed-openspec-ticket-template>

# <NN> — <OpenSpec group title>

**Blocked by:** the tickets this slice depended on, or "None".

**Status:** resolved

</completed-openspec-ticket-template>

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

For an OpenSpec ticket, mirror the local template's completion-aware criteria in the real issue body. A completed OpenSpec issue may omit **What to build** and **Acceptance criteria**, but retains dependency metadata before it is closed.

In any ticket, avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

### 6. Verify backlinks and OpenSpec state

Skip this step entirely if this flow has no OpenSpec change.

For every promoted group, verify there is exactly one plain non-checkbox `**Ticket:** <url-or-path>` line and that it resolves to the ticket processed for that group.

Ordinary promotion and backlinking must not add, remove, split, merge, reorder, or rewrite checkbox items. Do not change checkbox text or reset completion state. Keep the format OpenSpec parses: numbered `## N.` headings, every task an exact `- [ ]` or `- [x]` checkbox, and ticket links on plain non-checkbox lines.

Run `openspec status --change "<name>"` and confirm every required artifact is still `done`. Run `openspec validate "<name>" --strict` too whenever checklist content or boundaries changed, not merely when backlinks or tracker state changed.

Because `tasks.md` is the OpenSpec checklist and tickets are the collaboration surface, `/implement` works in two modes: when tickets exist, drive ticket state first and then check off the corresponding `tasks.md` lines; when tickets do not exist, work directly from `tasks.md`. `openspec archive` reads only `tasks.md` for completion, so tracker state never replaces the checklist.
