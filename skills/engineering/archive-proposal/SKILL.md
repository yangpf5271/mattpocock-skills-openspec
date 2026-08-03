---
name: archive-proposal
description: Finalize a completed OpenSpec change — sync its delta specs into the project's main specs, then file the change under the archive. The step that turns a finished change into a permanent part of the spec's source of truth.
disable-model-invocation: true
---

Archive a completed OpenSpec change. This is the closing move of the `/to-proposal` lifecycle: it checks the change is actually done, merges its delta specs into `openspec/specs/` (so the next proposal builds on the updated truth), and moves the change folder into `openspec/changes/archive/YYYY-MM-DD-<name>/`.

## Prerequisites

- **OpenSpec CLI installed** — run `openspec --version`. If missing, stop and tell the user to install it (`npm install -g @fission-ai/openspec`).
- A completed (or completing) change under `openspec/changes/`.

## Process

### 1. Pick the change

If a change name wasn't given, run `openspec list --json` and use the **AskUserQuestion tool** to let the user choose among the active (non-archived) changes. Do NOT guess or auto-select.

### 2. Check artifact completion

```bash
openspec status --change "<name>" --json
```

Parse `artifacts` — each has a `status`. If any artifact is not `done`, list the incomplete ones, warn the user, and use the **AskUserQuestion tool** to confirm they want to proceed anyway. Proceed if they confirm.

### 3. Check task completion

Read `openspec/changes/<name>/tasks.md` (if it exists). Count `- [ ]` (incomplete) vs `- [x]` (complete). If incomplete tasks remain, show the count, warn, and confirm via **AskUserQuestion** before proceeding. If no tasks file exists, skip this check.

### 4. Assess and sync delta specs

Look for delta specs at `openspec/changes/<name>/specs/`. If none exist, skip to step 5 with "No delta specs".

If delta specs exist, for each `openspec/changes/<name>/specs/<capability>/spec.md`:

a. Compare it against the main spec at `openspec/specs/<capability>/spec.md` (create the main spec file/folder if this capability is brand new).
b. Determine the operations the delta declares under its `##` headers:
   - `## ADDED Requirements` → append each `### Requirement:` block (with its `#### Scenario:` blocks) to the main spec.
   - `## MODIFIED Requirements` → replace the matching `### Requirement:` block in the main spec **in full** (the delta must contain the complete updated block — never merge partial content).
   - `## REMOVED Requirements` → remove the matching block from the main spec (the delta should carry a `**Reason**`; record it if the project wants a changelog).
   - `## RENAMED Requirements` → apply the `FROM:` / `TO:` rename in the main spec.
c. Show the user a combined summary of what would change across all capabilities, then use **AskUserQuestion** with options:
   - "Sync now (recommended)" — apply the merge above, then continue to archive.
   - "Archive without syncing" — skip the merge, continue to archive (the delta stays frozen in the archive; main specs won't reflect this change).

Proceed to archive regardless of the choice.

### 5. Archive the change

```bash
mkdir -p openspec/changes/archive
```

Target name: `YYYY-MM-DD-<name>` (today's date). If `openspec/changes/archive/YYYY-MM-DD-<name>/` already exists, fail with that target path and suggest renaming the existing archive or waiting for a different date. Otherwise:

```bash
mv openspec/changes/<name> openspec/changes/archive/YYYY-MM-DD-<name>
```

### 6. Summarize

```
## Archive Complete

**Change:** <change-name>
**Schema:** <schema-name>
**Archived to:** openspec/changes/archive/YYYY-MM-DD-<name>/
**Specs:** ✓ Synced to main specs   (or "No delta specs" / "Sync skipped")
```

Note any warnings (incomplete artifacts/tasks) if the user proceeded past them.

## Guardrails

- Always prompt for change selection if the name wasn't provided.
- Use the artifact graph (`openspec status --json`) for completion checking.
- Don't block the archive on warnings — inform and confirm, then proceed.
- Preserve `.openspec.yaml` when moving to archive (it travels with the directory).
- When syncing MODIFIED requirements, always replace the whole block — partial merges silently lose detail.
- If delta specs exist, always run the sync assessment and show the combined summary before prompting, even if the user ends up skipping.
