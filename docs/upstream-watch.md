# Upstream Watch

Deferred adaptation items for this fork, triggered by future upstream (`mattpocock/skills`) changes. Check this file when merging upstream: an entry fires when its trigger condition lands. Remove the entry once its adaptation is done.

## implement-spec promoted out of in-progress: DONE (2026-09-30)

- Recorded: 2026-08-24, after merging upstream's in-progress `implement-spec` skill (their commits `84b5ee5` / `5b15a47`). Fired and handled when upstream merged `release/v1.3` into main via PR #1120 (`d81f3a1`), fork merge `18ebfc8`.
- Trigger (fired): upstream moved `skills/in-progress/implement-spec/` into a promoted bucket.
- Adaptations applied:
  1. **tasks.md sync**: `implement-spec` gained a close-out step syncing `openspec/changes/<name>/tasks.md` (check off landed slices, confirm `**Ticket:**` backlinks) because `openspec archive` reads only `tasks.md`.
  2. **ask-matt branching**: upstream themselves wrote the two-way ticket execution branch (`/implement` per ticket vs `/implement-spec` for the task graph); the fork's OpenSpec paragraph was merged into it, with a note that `implement-spec` does not know `tasks.md` unless its close-out sync runs. Context-hygiene paragraph keeps both the fork's to-proposal boundary and upstream's retro guidance.
  3. **to-proposal mention**: its Summary now lists `/implement-spec` as a third execution route.
- Side constraint handled upstream: single-PR + `closing`-keyword model now conditional ("if the issue tracker closes work through PRs"), so local `.scratch/` trackers no longer break it.
- Chinese prefix added to implement-spec (`整份规格一次实现时：`); `pr` and `retro` arrived with upstream prefixes already conforming to the trigger style.
- Also in that merge: `resolving-merge-conflicts` removed by upstream (skill dir deleted, docs page kept as archived); `CONTEXT.md` convention renamed to `GLOSSARY.md` repo-wide, fork files checked clean; plugin at 30 skills.
