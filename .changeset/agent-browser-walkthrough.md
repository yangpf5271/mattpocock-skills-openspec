---
"mattpocock-skills-openspec": patch
---

implement: UI-scenario acceptance grows from two ways to three, taken in order unless the user says otherwise: committed E2E (preferred where infrastructure exists, since the specs re-run as regression), a new agent browser walkthrough (when the harness provides browser automation tools: the agent starts the dev server, walks one route per scenario with a screenshot per step, judges each against the scenario's expected result, and defers look-and-feel calls to the user; nothing is committed, so it verifies this change only), and the manual acceptance route for the user. archive-proposal: walkthrough-verified scenarios count as covered, noted as verified by walkthrough or by hand.
