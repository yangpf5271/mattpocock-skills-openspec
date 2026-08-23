# Upstream Watch

Deferred adaptation items for this fork, triggered by future upstream (`mattpocock/skills`) changes. Check this file when merging upstream: an entry fires when its trigger condition lands. Remove the entry once its adaptation is done.

## implement-spec promoted out of in-progress

- Recorded: 2026-08-24, after merging upstream's in-progress `implement-spec` skill (their commits `84b5ee5` / `5b15a47`).
- Trigger: upstream moves `skills/in-progress/implement-spec/` into a promoted bucket (it appears in their `plugin.json` or top-level README).
- Why it matters here: it executes a spec plus its tickets as a task graph with concurrent implementer subagents folding into one PR. It knows nothing about this fork's OpenSpec authority model: `tasks.md` checkboxes are the completion authority, and `implement`'s rule is to drive tracker state first, then check the matching `tasks.md` lines. Run on `/to-tickets` tickets inside an OpenSpec change, tickets would complete while `tasks.md` stays unchecked, and `openspec archive` (which reads only `tasks.md`) would report incomplete work.
- Adaptation when the trigger fires:
  1. Teach it, or wrap it, to sync `tasks.md` checkboxes and `**Ticket:**` backlinks as each ticket completes.
  2. Update `ask-matt` to branch between concurrent execution (`implement-spec`) and serial per-ticket sessions (`implement`).
  3. Mention it in `to-proposal`'s summary as a third execution route.
- Side constraint: its single-PR + `closing`-keyword model assumes a GitHub-type tracker; local `.scratch/` tracker tickets do not close via PR.
