---
name: to-proposal
description: 规格要留库并跨变更演进：Turn the current conversation into an OpenSpec change proposal — proposal, design, specs, and tasks — that lives in the repo and evolves across changes. No interview, just synthesis of what you've already discussed.
disable-model-invocation: true
---

This skill takes the current conversation context (typically a `/grilling` or `/to-spec` thread) and writes it into an OpenSpec change at `openspec/changes/<name>/`. Do NOT interview the user — synthesize what you already know.

Where `/to-spec` publishes a spec to the **issue tracker** (out of the repo), `/to-proposal` sinks the same thinking into the **repo itself** as an OpenSpec change, so the spec becomes the project's living source of truth: each change's delta is merged into `openspec/specs/` when you later run `/archive-proposal`.

## Prerequisites

- **OpenSpec CLI installed** — run `openspec --version`. If it's missing, stop and tell the user to install it:
  ```bash
  npm install -g @fission-ai/openspec
  ```
- **OpenSpec instance initialized in this repo** — `openspec/changes/` and `openspec/specs/` must exist. If not, run `openspec init --tools none` (the `--tools none` keeps it from installing its own `.claude/` skills, which would clash with this repo's plugin layout). `openspec/config.yaml` must select the `spec-driven` schema; if it is missing after init, write only `schema: spec-driven`. Never add Matt-specific `context:` or `rules:` to this shared project config. If an existing config selects another schema, do not overwrite it — ask the user how to proceed. `/setup-matt-pocock-skills` records the instance root in `docs/agents/openspec-instance.md`; read it if it exists.

## Process

### 1. Confirm what we're building

If the change name (kebab-case) isn't obvious from the conversation, derive one from what was discussed (e.g. "add user authentication" → `add-user-auth`). If the conversation has no clear subject, use the **AskUserQuestion tool** (open-ended) to ask what they want to build — do NOT proceed without it.

If a change with that name already exists (`openspec/changes/<name>/` is present), ask whether to continue it or pick a new name.

### 2. Scaffold the change

```bash
openspec new change "<name>"
```

This creates `openspec/changes/<name>/` with `.openspec.yaml` and a `README.md`.

### 3. Get the artifact build order

```bash
openspec status --change "<name>" --json
```

Parse the JSON:
- `applyRequires` — the artifact IDs that must reach `status: "done"` before the change is implementable (for `spec-driven` schema, this is `["tasks"]`).
- `artifacts` — each artifact's `id`, `outputPath`, and `status` (`ready` / `blocked`).

For `spec-driven`, the dependency chain is:

```
proposal ─┬─▶ design ──┐
         └─▶ specs ───┴─▶ tasks   (tasks artifact done ⇒ apply-ready)
```

So you create them in order: **proposal → (design + specs) → tasks**.

### 4. Create each artifact, bridging from the conversation

Use the **TodoWrite tool** to track the artifacts. For each `ready` artifact in turn:

a. Fetch its instructions:
   ```bash
   openspec instructions <artifact-id> --change "<name>" --json
   ```
   The JSON gives you `template` (the structure to fill), `instruction` (schema guidance), `context` + `rules` (constraints for YOU — do NOT copy them into the file), `dependencies` (completed files to read), and `outputPath` (where to write it).

b. **Bridge the conversation's content into the artifact** — map what `/to-spec` or `/grilling` already produced:

   | OpenSpec artifact | Fill from the conversation's… |
   |---|---|
   | `proposal.md` (Why / What Changes / Capabilities / Impact) | Problem Statement + Solution + User Stories + Out of Scope |
   | `design.md` (Context / Goals / Non-Goals / Decisions / Risks) | Implementation Decisions + Testing Decisions + the seams chosen |
   | `specs/<capability>/spec.md` (ADDED/MODIFIED Requirements + Scenarios) | User Stories recast as SHALL/MUST requirements, each with WHEN/THEN scenarios. One file per capability named in the proposal's Capabilities section. **Check the baseline first**: if `openspec/specs/<capability>/spec.md` already exists, write a MODIFIED delta (only the requirements you change, against that baseline) — ADDED is only for capabilities with no existing spec. |
   | `tasks.md` (numbered `- [ ]` checkboxes) | The OpenSpec implementation checklist: vertical tracer-bullet slices grouped under `## N.` headings, with each checkbox as a verifiable acceptance/completion item. It is **not** a tracker ticket — it has no assignee, status lane, comments, or blocking links — but `/to-tickets` can later promote each group into a ticket by adding those tracker-specific parameters. **Use exactly `- [ ]`** so apply/archive can track them. |

   If the conversation never produced some of this (e.g. no `/to-spec` ran), synthesize it from the grilling thread directly. Don't invent scope the user didn't agree to.

   For `proposal.md` specifically: keep the Problem Statement in user-facing terms, with no file paths or implementation code. Reference the `/grilling` or `/to-spec` thread it synthesizes when one exists.

   For `tasks.md` specifically: write the checklist as **vertical slices** (each `## N.` group = one narrow but complete path through every layer, demoable or verifiable on its own, blockers first), not as horizontal phases (Setup / Core / Tests). If the flow skips `/to-tickets`, `/implement` can work this checklist directly. If the flow runs `/to-tickets`, those groups become the starting boundaries for tracker tickets; `/to-tickets` adds ticket-specific fields like Blocked by, status, and tracker identity.

   When the conversation doesn't already dictate a slice boundary, draw one from these patterns (pick the first that fits): **Workflow steps** (build the simplest end-to-end path first, then middle steps and special cases) · **Operations/CRUD** (split "manage X" into Create/Read/Update/Delete) · **Simple → complex** (ship the minimal version, then edge cases as later slices) · **Spike, last resort** (time-box an investigation slice when a part is too uncertain to build). The rule underneath: find the core complexity and reduce the variations through it so one slice exercises a single path.

   Each slice should pass three checks before it lands in the checklist: (1) **it verifies alone** — the system's observable behaviour changes when it's done, and if it needs another slice first to be meaningful it's a horizontal layer, not a slice; (2) **it can be deferred** — a later slice still makes sense without it, and low-value work hidden inside a necessary slice means the cut is wrong; (3) **its acceptance reduces to one sentence** — if you can't state what's done in one line, the slice is too big, so split again. Size each slice so it fits one `/implement` run (one fresh context window of red-green at the seams and its `/code-review`); one that can't finish in a session is too big, and one that touches nothing end-to-end is a layer.

c. Read each completed dependency file before writing an artifact that depends on it.

d. Write the file to `outputPath`, using `template` as the structure and applying `context`/`rules` as constraints — but never pasting those constraint blocks into the artifact.

e. After each artifact, re-run `openspec status --change "<name>" --json` and confirm its `status` flipped to `done`. Stop when every ID in `applyRequires` is `done`.

### 5. Summarize

```bash
openspec status --change "<name>"
```

Tell the user:
- The change name and location (`openspec/changes/<name>/`).
- Which artifacts were created, one line each.
- That `tasks.md` is the OpenSpec implementation checklist: `/implement` can work it directly, or `/to-tickets` can promote each vertical slice into a tracker ticket by adding ticket-specific fields.
- That the change is ready to implement — tasks can be worked by `/implement` (check each `- [ ]` off as it lands), and when all tasks are done, `/archive-proposal` delegates the merge-and-file to `openspec archive`, syncing the delta into `openspec/specs/` and filing the change under `openspec/changes/archive/`.

## Guardrails

- Create **all** artifacts required for implementation (the `applyRequires` set), not just proposal.md.
- Always read dependency artifacts before writing one that depends on them.
- `context` and `rules` from `openspec instructions` are constraints on what you write, never content for the file.
- If the conversation is critically unclear on a point, use the **AskUserQuestion tool** to clarify — but prefer reasonable decisions to keep momentum.
- Verify each artifact file exists after writing, before moving on.
- Keep tasks as `- [ ]` checkboxes grouped under `## N.` headings — apply parses that exact format.
- `tasks.md` is an OpenSpec checklist, not a full tracker ticket. Keep it as vertical slice groups with exact `- [ ]` checkboxes; `/to-tickets` may add ticket links later on plain non-checkbox lines.
