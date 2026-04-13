---
name: plugin-guide
user_invocable: true
description: >
  Guide for packaging Claude Code skills into distributable plugins.
  Use after a skill is built (/skill-creator), designed (/skill-jedi), and
  reviewed (/skill-review), and you're ready to distribute it. Covers
  plugin.json setup, marketplace.json configuration, MCP server embedding,
  three-repo model, and choosing repo-checked skills vs plugin marketplace.
  Also use when the user says "publish my skill" or "make a plugin".
---

# Plugin Guide — Packaging & Distribution

## When to Use a Plugin

| Situation | Recommendation |
|-----------|---------------|
| Personal/team skill in one repo | Check into `.claude/skills/` — no plugin needed |
| Share across repos within a team | Plugin in internal marketplace |
| Share publicly | Plugin in public marketplace |

## Plugin Structure (Quick Reference)

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json              # ONLY file here
├── skills/                      # Agent skills
├── commands/                    # Custom slash commands
├── agents/                      # Subagent definitions
├── hooks/hooks.json             # Hook configurations
├── mcp/dist/                    # Embedded MCP server
├── scripts/                     # Utility scripts
├── .mcp.json                    # MCP server declarations
└── settings.json                # Default settings
```

## plugin.json Essentials

```json
{
  "name": "my-plugin",
  "description": "Plugin description",
  "version": "1.0.0"
}
```

Full schema and all component types in [references/plugin-architecture.md](references/plugin-architecture.md).

## Distribution Options

### Repo-Checked Skills (Small Teams)
Check skills into `.claude/skills/` in your repo. Simple but adds to context for every session.

### Plugin Marketplace (Scaling)
Users install what they need. Recommended curation process:

1. **Sandbox** — Upload experimental skill to a sandbox folder in GitHub
2. **Traction** — Share link in Slack/forums, let people try it
3. **Promote** — Once it has traction, PR to move into the marketplace

## Skill Composition

Skills can reference other skills by name. Claude will invoke them if installed:
```markdown
After generating the CSV, use the `/file-upload` skill to upload it.
```

No formal dependency management yet — just reference by name.

## Measuring Skill Usage

Use a `PreToolUse` hook to log which skills get invoked:
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Skill(*)",
      "hooks": [{ "type": "command", "command": "echo \"$(date): $SKILL_NAME\" >> ~/.claude/skill-usage.log" }]
      }]
  }
}
```

Track popular vs under-triggering skills to guide curation.

## Key Variables

| Variable | Purpose |
|----------|---------|
| `${CLAUDE_PLUGIN_ROOT}` | Plugin install path (use for all internal paths) |
| `${CLAUDE_PLUGIN_DATA}` | **Persistent** data folder (survives plugin upgrades) |

Store config, logs, and state in `${CLAUDE_PLUGIN_DATA}`, not in the skill directory.

## Gotchas

- Changed plugin code but didn't bump version → users see stale code forever (cache keys on version)
- Put files other than `plugin.json` inside `.claude-plugin/` → plugin fails to load
- MCP server uses `Bun.spawn` → breaks for users without Bun; use `node:child_process` instead
- MCP tools installed but not visible → requires a new session to load
- Common Pitfalls in [references/plugin-architecture.md](references/plugin-architecture.md) has the full list

## Full Architecture Reference

Three-repo model, marketplace.json schema, hooks system, MCP embedding — see [references/plugin-architecture.md](references/plugin-architecture.md).
