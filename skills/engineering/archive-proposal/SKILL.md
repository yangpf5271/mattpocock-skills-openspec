---
name: archive-proposal
description: Finalize a completed OpenSpec change — check it's actually done, then delegate the merge-and-file to `openspec archive`. The step that turns a finished change into a permanent part of the spec's source of truth.
disable-model-invocation: true
---

Archive a completed OpenSpec change. This is the closing move of the `/to-proposal` lifecycle: it pre-flights that the change is actually done, gets the user's explicit go-ahead, then delegates the mechanical work — syncing delta specs into `openspec/specs/` and moving the change under `openspec/changes/archive/YYYY-MM-DD-<name>/` — to the `openspec archive` CLI.

The merge semantics (ADDED appended, MODIFIED replaced in full, REMOVED dropped, RENAMED applied) belong to the CLI — OpenSpec's rules are the source of truth, so the skill never re-implements them. What the skill adds is a human checkpoint *before* the CLI runs.

## Prerequisites

- **OpenSpec CLI installed** — run `openspec --version`. If missing, stop and tell the user to install it (`npm install -g @fission-ai/openspec`).
- A completed (or completing) change under `openspec/changes/`.

## Process

### 1. Pick the change

If a change name wasn't given, run `openspec list --json` and use the **AskUserQuestion tool** to let the user choose among the active (non-archived) changes. Do NOT guess or auto-select.

### 2. Pre-flight completion

```bash
openspec status --change "<name>" --json
```

Parse `artifacts` — each has a `status`. If any artifact is not `done`, list the incomplete ones, warn the user, and use the **AskUserQuestion tool** to confirm they want to proceed anyway.

### 3. Check task completion

Read `openspec/changes/<name>/tasks.md` (if it exists). Count `- [ ]` (incomplete) vs `- [x]` (complete). If incomplete tasks remain, show the count, warn, and confirm via **AskUserQuestion** before proceeding. If no tasks file exists, skip this check.

### 4. Delegate to the CLI

Run the archive — the CLI performs its own validation (e.g. proposal warnings), syncs the delta specs into `openspec/specs/`, and moves the change:

```bash
openspec archive "<name>" --yes
```

`--yes` is correct here: the human confirmation already happened in steps 2–3, so the CLI shouldn't prompt again. If the CLI exits non-zero, surface its output and stop — do not paper over it with a hand-written fallback.

### 5. Summarize

```
## Archive Complete

**Change:** <change-name>
**Schema:** <schema-name>
**Archived to:** openspec/changes/archive/YYYY-MM-DD-<name>/
**Specs:** ✓ Synced to main specs by openspec archive   (or "No delta specs" / "Sync skipped" per the CLI output)
```

Note any warnings (incomplete artifacts/tasks) if the user proceeded past them.

## Guardrails

- Always prompt for change selection if the name wasn't provided.
- Use the artifact graph (`openspec status --json`) for completion checking.
- Don't block the archive on warnings — inform and confirm, then proceed.
- **Delegate the merge and file move to `openspec archive`** — never re-implement delta merging by hand. The CLI's merge semantics (ADDED/MODIFIED/REMOVED/RENAMED) are the contract; a hand-written merge will drift from it.
- Pass `--yes` only after the user has confirmed in steps 2–3; if the CLI still exits non-zero, surface the error — don't bypass it.
