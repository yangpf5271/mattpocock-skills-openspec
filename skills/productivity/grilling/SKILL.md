---
name: grilling
description: 想压力测试某个想法时：Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommended answer.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent with a fresh context window to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

A premise the user states is also a fact. When a decision rests on a claim about what already exists ("already in place", "the system supports that today", "phase one shipped it"), treat the claim as something to check, not as given: verify it against the codebase or environment before the decision lands. A premise that fails is a new question on the frontier; a premise nothing available can verify is marked as unverified and never built on silently.

Changing the middle of an existing flow owns the exit as well as the entry. Enumerate what the changed behavior feeds out to: probe the code for its downstream consumers, and put a contract question on the frontier for each - does its assumption still hold under the new behavior, or does it need retrofitting? Each consumer's joint ends up as a scenario, so what gets built and accepted walks the whole flow instead of the middle alone; a tail left silent is the gap this rule closes.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
