## What it does

`to-tickets` takes a plan, a [spec](https://www.aihero.dev/ai-coding-dictionary/spec), or the conversation you are in, and breaks it into a set of **[tickets](https://www.aihero.dev/ai-coding-dictionary/ticket)** on your issue tracker. Each ticket declares its **blocking edges**: the other tickets that have to finish before it can start.

Every ticket is a **tracer bullet**: a narrow but complete path through every layer of the change (schema, API, UI, tests) that can be demoed on its own the moment it lands. That is the constraint that makes it behave differently from the obvious way to split work, which is to cut one layer at a time and integrate at the end. It also sizes each ticket to fit in a single fresh [context window](https://www.aihero.dev/ai-coding-dictionary/context-window), because the thing that will pick the ticket up is a [session](https://www.aihero.dev/ai-coding-dictionary/session) that has never seen your spec.

In an OpenSpec flow, `tasks.md` remains the archive record and owns the vertical-slice boundaries. Promotion adds one detailed tracker ticket per group when ticketing proceeds. The ticket mirrors completion state and adds executable detail, dependencies, lifecycle state, and tracker identity; it does not replace the checklist. The skill owns the breakdown and proceeds once the tickets are internally coherent; it stops only for missing or contradictory requirements, ambiguous configured tracker workflows, or OpenSpec checklist revisions that would change agreed scope or discard completed work.

## When to reach for it

You invoke this by typing `/to-tickets`. The [agent](https://www.aihero.dev/ai-coding-dictionary/agent) won't reach for it on its own.

| Where you are | What to run |
| --- | --- |
| You have a spec issue and the build spans several sessions | `/to-tickets`, or `/to-tickets #<spec_issue>` |
| The plan is only in the conversation, never written up | `/to-tickets` reads the thread directly, no spec needed |
| The whole change fits in one context window | [implement](https://aihero.dev/skills-implement), skip the tickets |
| Nothing is decided yet | [grill-with-docs](https://aihero.dev/skills-grill-with-docs), then [to-spec](https://aihero.dev/skills-to-spec) |
| A [wayfinder](https://aihero.dev/skills-wayfinder) map has cleared | [to-spec](https://aihero.dev/skills-to-spec) first, to collapse the map, then `/to-tickets` |
| An OpenSpec change has unfinished `tasks.md` groups and needs tracker collaboration | `/to-tickets` promotes the groups and writes backlinks |
| Every OpenSpec task is complete and no tickets were ever linked | Skip `/to-tickets`; run [archive-proposal](https://aihero.dev/skills-archive-proposal) |

Tickets that `to-tickets` produced are agent-ready by construction. Don't run [triage](https://aihero.dev/skills-triage) over them. Triage is for work that arrived from someone else.

## Prerequisites

`to-tickets` publishes into a tracker. If [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) has recorded one in `docs/agents/issue-tracker.md`, it uses that workflow. If no tracker config exists, it uses the local markdown fallback instead and writes one ticket per file under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, with `ready-for-agent` as the default open status. This lets public projects use the skill locally without committing personal tracker configuration.

The exception is an all-complete OpenSpec change with no backlinks. That path performs no tracker reads or writes and points straight to archive.

## Tracer bullets, not layers

A **horizontal** slice ships one layer of the change. Nothing works until every layer has landed, and each ticket's acceptance criteria have to reach into work that another ticket owns. A **vertical** slice (the tracer bullet) ships one thin path through all the layers at once, so it is verifiable alone and owns everything it grades.

This is the rule people break most often, and the consequences are well documented. One team ran a 26-ticket stack sliced by layer (corpus, producer, aggregator, selector) and got roughly twenty agent runs per closed ticket, about three quarters of them rework. Their own post-mortem traced every failure class back to the horizontal slicing rather than to the implementations.

When the source doesn't already dictate a boundary, the skill draws one from standard patterns (workflow steps, operations/CRUD, simple to complex, spike) and checks each slice verifies alone, can be deferred, and reduces to one sentence of acceptance; see its `SKILL.md` for the operative checklist. This guidance applies whether the source is an OpenSpec `tasks.md`, a tracker spec, or just the conversation: `/to-tickets` works without `/to-proposal`.

One shape breaks the rule. A **wide refactor** is a single mechanical change whose blast radius fans across the codebase so no vertical slice can land green. `to-tickets` sequences that as expand-contract: add the new form, migrate callers in green batches, then remove the old form.

Before publishing, the skill checks that each ticket has a demoable vertical-slice outcome and that each blocking edge genuinely gates the dependent ticket. In an OpenSpec flow, it also respects each group's completion progress, tracker action, completed and remaining items, satisfied dependencies, and any checklist/tracker conflict. It writes only when it can make a defensible decision from the spec, codebase, and tracker state.

## Completion-aware OpenSpec promotion

`tasks.md` checkbox state determines whether work remains and whether the change is archive-ready. Tickets preserve the one-group-to-one-ticket mapping while varying how much executable detail they carry:

| Group state | Ticket representation |
| --- | --- |
| Not started | Open detailed ticket; every unchecked title is retained and expanded with executable acceptance detail |
| Partially complete | Open full-slice ticket; completed titles stay checked and concise, unchecked titles receive the executable detail |
| Complete inside a mixed change | Minimal completed ticket; no work payload or `ready-for-agent`, backlinked and immediately closed/resolved |
| Entire change complete, no backlinks | No tickets or backlinks; proceed to `archive-proposal` |
| Entire change complete, existing backlinks | Reconcile the linked tickets; close any that remain open without creating duplicates |

Completed tickets remain historical nodes in the dependency graph. A dependent ticket may still name one under **Blocked by**, but the edge is already satisfied because the completed ticket is closed or `resolved`; it does not block the live frontier. The edges live in the ticket either way. The medium only decides whether anything can act on them in parallel. `to-tickets` produces the artifact; running it (one session at a time, or a fleet) is your job, not the skill's.

`tasks.md` and the tracker have separate authority. The checklist owns OpenSpec completion, while the linked ticket owns tracker identity and collaboration state. A closed ticket never silently completes an unchecked task. Any disagreement is resolved explicitly before writes begin.

## Tasks vs tickets: what each one owns

One shape breaks the tracer-bullet rule. A **wide refactor** is a single mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so one edit breaks thousands of call sites and no vertical slice can land green.

- **Expand**: add the new form beside the old, so nothing breaks.
- **Migrate**: move call sites over in batches sized by blast radius (per package, per directory), one ticket per batch, each blocked by the expand. CI stays green because the old form still exists.
- **Contract**: delete the old form once no caller remains, in a ticket blocked by every migrate batch.

A ticket is a **scheduling and collaboration unit**. It carries assignee, status, native blocking edges (the dependency DAG that decides what can be worked now), comments, and a tracker identity. It lives on the tracker, not in the repo, and a closed ticket stays in tracker history rather than becoming an in-repo artifact.

That split maps directly onto what `/implement` needs from each:

- **Scheduling** — which slice to work, whether it can start yet, who is on it — the ticket is the authority. Its blocking edges answer "can this run now?" in a way `tasks.md` cannot, because the checklist only *implies* order through writing convention ("blockers first"), not a real dependency graph.
- **Completion** — whether a slice is actually done, and whether the whole change is done — `tasks.md` is the authority. A ticket's "closed" status is collaboration state, not verification; it says nobody is still working on it, not that the work passes its acceptance bar.

This is why `/implement` runs in two modes. With promoted tickets it drives the ticket first (the scheduling surface) and then checks the matching `tasks.md` lines (the completion surface). Without tickets it works the checklist directly, because nothing needs scheduling — a solo session has no frontier to resolve. And it is why the guardrail above exists: the moment ticket state could rewrite the checklist, the archive record would stop matching what was actually built, and the two surfaces would lose their separate authority.

## Common questions

**It produced twelve tickets for a three-line change.**

Over-decomposition is the most reported friction on this skill, and it is consistent across practitioners: the [model](https://www.aihero.dev/ai-coding-dictionary/model) defaults to atomic units and loses the grouping that would make them meaningful. The current rule is stricter: the skill should not make a ticket unless it can name what is demoable when that ticket is done. If the whole change fits one context window, skip this skill and go straight to [implement](https://aihero.dev/skills-implement).

**What happens if I run it after implementation has started?**

The tickets still correspond to the original OpenSpec groups. A partially complete group becomes one full-slice ticket: completed task titles are copied as checked context, while only remaining tasks receive detailed implementation and acceptance guidance. A completed group in a mixed change becomes a minimal closed ticket so the group-to-ticket mapping and dependency history remain intact.

**What if every OpenSpec task is already complete?**

If the change has never been promoted, there is no remaining collaboration work to ticket. The skill performs no tracker operation and points to `archive-proposal`. If backlinks already exist, it reconciles linked ticket state so open historical tickets are not left behind.

**The tickets came out one per layer: all the schema in one, all the API in another.**
This is the failure the vertical-slice rule is written against, and the skill still produces it sometimes. A ticket with no answer to "what can I demo when this is done?" is a horizontal slice and should be fixed by the skill before publishing. In OpenSpec mode, changing that boundary is also a deliberate change to the archive record, so the skill stops only when the revision would change agreed scope, discard completed work, or depends on missing/contradictory requirements.

**The tickets are published. How do I run them?**

Work the frontier: any open ticket whose blockers are complete. Open one fresh agent session per ticket. [implement](https://aihero.dev/skills-implement) drives tracker state first and then checks the matching `tasks.md` lines; completed tickets never enter that queue.

**"Blocked by" was written into the issue body instead of a real blocking link.**
Same class of problem, [reported in issue #513](https://github.com/mattpocock/skills/issues/513), where the agent went as far as asserting GitHub has no native blocking relationship at all. It does. Body text is meant to be the fallback for trackers with no native edge, not the default.

**Where do the local tickets go? The v1.1 notes said a root-level `tickets.md`.**
They did, and that was a bug: a single shared file also raced when parallel agents wrote to it. Local mode now writes one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, in dependency order, matching the layout the local tracker template already described. The `NN` prefix is a real ticket ID, so `/implement 03` works instead of retyping a long title.

**It kept truncating when it tried to read my spec.**
A very large spec can outgrow what a tracker issue serves back cleanly, and there is no local copy to fall back on, so the agent then burns [tool calls](https://www.aihero.dev/ai-coding-dictionary/tool-call) re-fetching chunks and never reaches the end. Don't [clear](https://www.aihero.dev/ai-coding-dictionary/clearing) or [compact](https://www.aihero.dev/ai-coding-dictionary/compaction) between `/to-spec` and `/to-tickets`. Run them in the same context window and the spec never has to be fetched back at all.

**The acceptance criteria graded nothing: some passed before any work was done.**
The template asks for criteria and says nothing about whether they can fail, so this happens. Three shapes recur: a criterion already true at the base commit, a criterion that can only be satisfied by work another ticket owns, and one that restates the request rather than deriving from the artifact. Vertical slicing prevents most of it (a slice that delivers behaviour which didn't exist before is red at the base commit by construction), but the check is worth doing by hand. For each criterion, name the observation that would show it false, and confirm it fails at the commit the implementer starts from.

## It's working if

- Every ticket has an answer to "what can I demo when this is done?", and the answer is behaviour, not a layer.
- The ticket at the top has no blockers and can be started immediately.
- Nothing in a ticket body is a file path or a line number, except a snippet a prototype produced.
- Each ticket reads like something a fresh session could finish without you in the room.
- Prefactoring, where it found any, is at the front of the order rather than mixed into feature tickets.
- The skill publishes only after the breakdown and blocking edges are internally coherent; user input is reserved for missing/contradictory requirements, ambiguous configured tracker workflows, or risky OpenSpec checklist revisions.
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

Upstream is [to-spec](https://aihero.dev/skills-to-spec), which hands it a settled spec to slice against; keep both in one unbroken context window. Downstream is [implement](https://aihero.dev/skills-implement), which builds one ticket per fresh session, driving [tdd](https://aihero.dev/skills-tdd) for the tests and closing with [code-review](https://aihero.dev/skills-code-review).

`to-tickets` is complete as a *publishing* step under either entry. The skill has dedicated non-OpenSpec branches in its gather/draft/publish steps, and skips the OpenSpec verification step entirely when no change exists, so it can run straight from a conversation or spec with no `/to-proposal` before it. What differs is the close-out, not the publishing:

- **With `/to-proposal`**: a change exists, so the loop is `/implement` then `/archive-proposal`. The OpenSpec checklist is the completion record and the tracker is the collaboration surface.
- **Without `/to-proposal`**: there is no change to archive, so completion is tracked on the tracker. Every ticket closed is the signal the work is done. `/archive-proposal` is not part of this path, because there is no OpenSpec lifecycle to close.

Both paths publish the same agent-ready tracer-bullet tickets; only the lifecycle around them changes.
