---
name: skill-jedi
user_invocable: true
description: >
  Design patterns and architecture guide for Claude Code skills.
  Use after /skill-creator builds a working skill and you want to elevate its
  design — choosing the right skill type, applying proven patterns (Iron Law,
  Hub-and-Spoke, Rationalization Table), optimizing token budget, or deciding
  between MCP vs skill vs plugin. Complements /skill-creator (which handles
  building and testing) by teaching how to design well.
  Not for reviewing existing skills (use /skill-review) or plugin packaging (use /plugin-guide).
---

# Skill Jedi — Design Guide for Claude Code Skills

## Core Philosophy

> "MCP provides *capability*, skill provides *judgment*."

MCP tools give Claude new abilities (API calls, file ops). Skills shape *how* Claude thinks and decides. A well-designed skill changes behavior, not just adds features.

**A skill is a folder, not just a markdown file.** Include scripts, assets, data, config — Claude can discover, explore, and manipulate the entire folder.

## Architecture Decision

| Need | Solution | Complexity |
|------|----------|------------|
| Teach Claude a workflow or pattern | Skill only | Low |
| Give Claude new capabilities + guidance | MCP server + Skill | Medium |
| Distribute to other users | Plugin (use `/plugin-guide`) | High |

## Nine Skill Types

Choose the right type — details and examples in [references/design-patterns.md](references/design-patterns.md):

| Type | Purpose |
|------|---------|
| **Library & API Reference** | Explain how to use a library, CLI, or SDK correctly |
| **Product Verification** | Test/verify code works (often with playwright, tmux) |
| **Data Fetching & Analysis** | Connect to data and monitoring stacks |
| **Business Process** | Automate repetitive workflows into one command |
| **Code Scaffolding** | Generate framework boilerplate for your codebase |
| **Code Quality & Review** | Enforce code quality, review code |
| **CI/CD & Deployment** | Fetch, push, deploy code |
| **Runbooks** | Investigate symptoms, produce structured reports |
| **Infrastructure Ops** | Routine maintenance with guardrails |

## Frontmatter Quick Reference

Required: `name`, `description`. Key optional fields:

| Field | Purpose |
|-------|---------|
| `argument-hint` | Autocomplete hint, e.g. `[issue-number]` |
| `context: fork` | Run in isolated subagent (no conversation history) |
| `agent` | Subagent type for forked context (`Explore`, `Plan`, etc.) |
| `model` | Override model for this skill |
| `allowed-tools` | Tools that skip permission prompt |
| `hooks` | Skill-scoped lifecycle hooks |
| `disable-model-invocation` | Only user can `/invoke` |
| `user-invocable: false` | Only Claude auto-invokes |

Full details in [references/design-patterns.md](references/design-patterns.md).

## Dynamic Content

Skills support runtime injection:

- **Arguments**: `$ARGUMENTS`, `$0`, `$1` — from `/skill-name arg0 arg1`
- **Variables**: `${CLAUDE_SESSION_ID}`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PLUGIN_DATA}`
- **Shell**: `!` + backtick-wrapped command — executes before Claude sees the skill

## Six Design Patterns

Quick reference — details in [references/design-patterns.md](references/design-patterns.md):

1. **Iron Law** — One absolute rule in a code block. No exceptions.
2. **Rationalization Table** — Pre-empt AI self-justification for skipping rules.
3. **Red Flags** — Trigger self-check when AI detects risky thought patterns.
4. **Phase-Gate** — Sequential stages; must complete each before proceeding.
5. **Hub-and-Spoke** — SKILL.md as concise hub; details in references/.
6. **Concrete Verification** — Show correct vs incorrect examples side by side.

## Token Budget

- Description budget: **2% of context window** (dynamic, shared across all skills)
- SKILL.md body: < 500 words, < 500 lines
- References: one level deep, loaded on demand — never use `@` links
- Progressive loading: startup = name+description only → invocation = SKILL.md → on-demand = references/

## TDD Workflow

**RED**: Build a pressure scenario. Test without the skill. Record baseline.
**GREEN**: Write the skill. Test with it. Verify improvement.
**REFACTOR**: Find new rationalizations AI uses to bypass rules. Add to rationalization table. Retest.

## Gotchas

- Beginners jump to Nine Skill Types and start writing — always check Architecture Decision first to confirm a skill is the right solution
- Hub-and-Spoke "summary" easily becomes copy-paste — summaries should say *what* and *when*, never restate reference details
- Description length vs trigger quality: the 2% budget is shared across all installed skills — 10 plugins can exhaust it, causing low-priority descriptions to be excluded
- "I'll add a Rationalization Table later" — you won't. Write it with the Iron Law or it won't exist
- Skills that teach patterns (like this one) feel complete on first draft — they aren't. Real gotchas only emerge after Claude fails in production use

## Related Skills

- `/skill-review` — Audit an existing skill against anti-patterns checklist
- `/plugin-guide` — Package skills into plugins for marketplace distribution
