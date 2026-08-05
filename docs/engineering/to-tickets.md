## What it does

`to-tickets` takes a plan, a [spec](https://www.aihero.dev/ai-coding-dictionary/spec), or the conversation you are in, and breaks it into a set of **[tickets](https://www.aihero.dev/ai-coding-dictionary/ticket)** on your issue tracker. Each ticket declares its **blocking edges** — the other tickets that have to finish before it can start.

Every ticket is a **tracer bullet**: a narrow but complete path through every layer of the change — schema, API, UI, tests — that can be demoed on its own the moment it lands. The breakdown is previewed and approved before tracker writes begin.

In an OpenSpec flow, `tasks.md` remains the archive record and owns the vertical-slice boundaries. Promotion adds one detailed tracker ticket per group when ticketing proceeds. The ticket mirrors completion state and adds executable detail, dependencies, lifecycle state, and tracker identity; it does not replace the checklist.

## When to reach for it

You invoke this by typing `/to-tickets` — the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) won't reach for it on its own.

| Where you are | What to run |
| --- | --- |
| You have a spec issue and the build spans several sessions | `/to-tickets`, or `/to-tickets #<spec_issue>` |
| The plan is only in the conversation, never written up | `/to-tickets` reads the thread directly — no spec needed |
| The whole change fits in one context window | [implement](https://aihero.dev/skills-implement) — skip the tickets |
| Nothing is decided yet | [grill-with-docs](https://aihero.dev/skills-grill-with-docs), then [to-spec](https://aihero.dev/skills-to-spec) |
| A [wayfinder](https://aihero.dev/skills-wayfinder) map has cleared | [to-spec](https://aihero.dev/skills-to-spec) first, to collapse the map, then `/to-tickets` |
| An OpenSpec change has unfinished `tasks.md` groups and needs tracker collaboration | `/to-tickets` promotes the groups and writes backlinks |
| Every OpenSpec task is complete and no tickets were ever linked | Skip `/to-tickets`; run [archive-proposal](https://aihero.dev/skills-archive-proposal) |

Tickets that `to-tickets` produced are agent-ready by construction. Don't run [triage](https://aihero.dev/skills-triage) over them — triage is for work that arrived from someone else.

## Prerequisites

`to-tickets` publishes into a tracker, so [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) must have configured one for this repo, along with its status and dependency operations. Either kind works: a real tracker like GitHub or GitLab, or local markdown under `.scratch/`.

The exception is an all-complete OpenSpec change with no backlinks. That path performs no tracker reads or writes and points straight to archive.

## Tracer bullets, not layers

A **horizontal** slice ships one layer of the change. Nothing works until every layer has landed, and each ticket's acceptance criteria reach into work another ticket owns. A **vertical** slice — the tracer bullet — ships one thin path through all layers, so it is verifiable alone and owns everything it grades.

One shape breaks the rule. A **wide refactor** is a single mechanical change whose blast radius fans across the codebase so no vertical slice can land green. `to-tickets` sequences that as expand–contract: add the new form, migrate callers in green batches, then remove the old form.

Before publishing, the skill presents the numbered breakdown and asks you to confirm granularity and blocking edges. In an OpenSpec flow, the preview also shows each group's completion progress, proposed tracker action, completed and remaining items, satisfied dependencies, and any checklist/tracker conflict. Rejection causes no tracker, checklist, dependency, or backlink writes.

## Completion-aware OpenSpec promotion

`tasks.md` checkbox state determines whether work remains and whether the change is archive-ready. Tickets preserve the one-group-to-one-ticket mapping while varying how much executable detail they carry:

| Group state | Ticket representation |
| --- | --- |
| Not started | Open detailed ticket; every unchecked title is retained and expanded with executable acceptance detail |
| Partially complete | Open full-slice ticket; completed titles stay checked and concise, unchecked titles receive the executable detail |
| Complete inside a mixed change | Minimal completed ticket; no work payload or `ready-for-agent`, backlinked and immediately closed/resolved |
| Entire change complete, no backlinks | No tickets or backlinks; proceed to `archive-proposal` |
| Entire change complete, existing backlinks | Reconcile the linked tickets in the preview; close any that remain open without creating duplicates |

Completed tickets remain historical nodes in the dependency graph. A dependent ticket may still name one under **Blocked by**, but the edge is already satisfied because the completed ticket is closed or `resolved`; it does not block the live frontier.

`tasks.md` and the tracker have separate authority. The checklist owns OpenSpec completion, while the linked ticket owns tracker identity and collaboration state. A closed ticket never silently completes an unchecked task. Any disagreement is shown in the preview and resolved explicitly before writes begin.

## Common questions

**It produced twelve tickets for a three-line change.**

Over-decomposition is the most reported friction on this skill. The preview exists for exactly this — ask it to merge before approving. If the whole change fits one context window, skip this skill and go straight to [implement](https://aihero.dev/skills-implement).

**What happens if I run it after implementation has started?**

The tickets still correspond to the original OpenSpec groups. A partially complete group becomes one full-slice ticket: completed task titles are copied as checked context, while only remaining tasks receive detailed implementation and acceptance guidance. A completed group in a mixed change becomes a minimal closed ticket so the group-to-ticket mapping and dependency history remain intact.

**What if every OpenSpec task is already complete?**

If the change has never been promoted, there is no remaining collaboration work to ticket. The skill performs no tracker operation and points to `archive-proposal`. If backlinks already exist, it previews state reconciliation instead so open historical tickets are not left behind.

**The tickets came out one per layer — all the schema in one, all the API in another.**

Catch it in the preview by asking one question per ticket: what can I demo when this is done? A ticket with no answer is a horizontal slice. In OpenSpec mode, changing that boundary is also a deliberate change to the archive record and must be shown before approval.

**The tickets are published. How do I run them?**

Work the frontier: any open ticket whose blockers are complete. Open one fresh agent session per ticket. [implement](https://aihero.dev/skills-implement) drives tracker state first and then checks the matching `tasks.md` lines; completed tickets never enter that queue.

## It's working if

- Every proposed ticket has an answer to "what can I demo when this is done?" — and the answer is behavior, not a layer.
- The numbered breakdown and blocking edges appear before any tracker write, and publication starts only after approval.
- OpenSpec groups retain a one-to-one ticket mapping whenever promotion proceeds.
- A partial group shows completed titles as `[x]`, while only unchecked items carry new executable detail.
- A completed group in a mixed change produces a minimal closed/resolved ticket with no `ready-for-agent` label.
- An all-complete, never-promoted change produces zero tracker writes and points to `archive-proposal`.
- Every promoted group has exactly one backlink, and reruns reuse it instead of creating duplicates.
- Tracker state never silently changes an OpenSpec checkbox.

## Where it fits

`to-tickets` is the optional collaboration step in the build chain:

```text
grill-with-docs → to-spec → to-tickets → implement → code-review
```

In the OpenSpec lifecycle, [to-proposal](https://aihero.dev/skills-to-proposal) supplies the `tasks.md` groups. This skill enriches them as tracker tickets when collaboration needs them; [implement](https://aihero.dev/skills-implement) works each open ticket and keeps the checklist accurate. Without ticketing, `implement` works `tasks.md` directly. Once every checkbox is complete, [archive-proposal](https://aihero.dev/skills-archive-proposal) closes the lifecycle. [ask-matt](https://aihero.dev/skills-ask-matt) routes the full set.
