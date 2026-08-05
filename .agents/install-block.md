# The canonical install block

One install story, one wording. `README.md`, `.changeset/*`, and install references must say **this** and nothing else. Change it here first, then propagate.

This OpenSpec-enabled fork is distributed through [skills.sh](https://skills.sh/yangpf5271/mattpocock-skills-openspec). Claude Code's official marketplace package named `mattpocock-skills` installs the upstream repository and does not contain this fork's OpenSpec additions.

## Claude Code, Codex, and other agents

<canonical-block name="skills-sh-whole-set">

```bash
npx skills@latest add yangpf5271/mattpocock-skills-openspec
```

Pick the skills and coding agents to install them on. **Make sure `setup-matt-pocock-skills` is included.**

</canonical-block>

For one skill:

<canonical-block name="skills-sh-one-skill">

```bash
npx skills@latest add yangpf5271/mattpocock-skills-openspec --skill=<name>
```

```bash
npx skills@latest update <name>
```

</canonical-block>

Pages under `docs/` do not carry these commands: ai-hero renders the install widget above the body. See [writing-docs.md](./writing-docs.md).

## Official upstream Claude plugin

Users who do not need the OpenSpec additions can install Matt Pocock's official upstream package:

```bash
claude plugins install mattpocock-skills
```

Or, from inside a session:

```text
/plugin install mattpocock-skills
```

That route and this fork's skills.sh route are alternatives. Installing both gives Claude Code duplicate copies of the shared skills.

## Direct marketplace fallback

`.claude-plugin/marketplace.json` exposes this repository as a single-plugin marketplace for direct testing. It is not the documented installation route because skills.sh installs the same fork into Claude Code, Codex, and other supported agents.
