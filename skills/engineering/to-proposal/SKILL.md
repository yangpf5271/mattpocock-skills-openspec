---
name: to-proposal
description: Turn the current conversation into an OpenSpec change proposal — proposal, design, specs, and tasks — that lives in the repo and evolves across changes. No interview, just synthesis of what you've already discussed.
disable-model-invocation: true
---

This skill takes the current conversation context (typically a `/grilling` or `/to-spec` thread) and writes it into an OpenSpec change at `openspec/changes/<name>/`. Do NOT interview the user — synthesize what you already know.

Where `/to-spec` publishes a spec to the **issue tracker** (out of the repo), `/to-proposal` sinks the same thinking into the **repo itself** as an OpenSpec change, so the spec becomes the project's living source of truth: each change's delta is merged into `openspec/specs/` when you later run `/archive-proposal`.

## Prerequisites

- **OpenSpec CLI installed** — run `openspec --version`. If it's missing, stop and tell the user to install it:
  ```bash
  npm install -g @fission-ai/openspec
  ```
- **OpenSpec instance initialized in this repo** — `openspec/changes/` and `openspec/specs/` must exist. If not, run `openspec init --tools none` (the `--tools none` keeps it from installing its own `.claude/` skills, which would clash with this repo's plugin layout). `/setup-matt-pocock-skills` records the instance root in `docs/agents/openspec-instance.md`; read it if it exists.

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
          └─▶ specs ───┴─▶ tasks   (tasks done ⇒ apply-ready)
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
   | `specs/<capability>/spec.md` (ADDED/MODIFIED Requirements + Scenarios) | User Stories recast as SHALL/MUST requirements, each with WHEN/THEN scenarios. One file per capability named in the proposal's Capabilities section. |
   | `tasks.md` (numbered `- [ ]` checkboxes) | The tracer-bullet slices `/to-tickets` would produce — vertical, demoable, blockers-first. **Use exactly `- [ ]`** so apply can track them. |

   If the conversation never produced some of this (e.g. no `/to-spec` ran), synthesize it from the grilling thread directly. Don't invent scope the user didn't agree to.

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
- That it's ready to implement — tasks can be worked by `/implement` (check each `- [ ]` off as it lands), and when all tasks are done, `/archive-proposal` merges the delta into `openspec/specs/` and files the change under `openspec/changes/archive/`.

## Guardrails

- Create **all** artifacts required for implementation (the `applyRequires` set), not just proposal.md.
- Always read dependency artifacts before writing one that depends on them.
- `context` and `rules` from `openspec instructions` are constraints on what you write, never content for the file.
- If the conversation is critically unclear on a point, use the **AskUserQuestion tool** to clarify — but prefer reasonable decisions to keep momentum.
- Verify each artifact file exists after writing, before moving on.
- Keep tasks as `- [ ]` checkboxes grouped under `## N.` headings — apply parses that exact format.
