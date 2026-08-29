---
"mattpocock-skills-openspec": patch
---

implement: add an acceptance step after code-review; run the full suite, run E2E journeys for UI-touching changes when the repo has browser E2E infrastructure, and never skip silently when the repo has no test infrastructure at all: report the uncovered spec scenarios and ask to scaffold minimal infrastructure or record the gap. archive-proposal: report scenario verification coverage (total/covered/uncovered) in the pre-flight summary without blocking the archive.
