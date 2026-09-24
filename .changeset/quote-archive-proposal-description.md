---
"mattpocock-skills-openspec": patch
---

archive-proposal: quote the `description` in `SKILL.md` frontmatter. It contained a `: ` sequence, which made the frontmatter invalid YAML, so skill discovery could skip the skill. Introduced when an em-dash cleanup replaced the dash before "check" with a colon.
