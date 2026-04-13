# Skill Design Patterns

Proven patterns for writing effective Claude Code skills. Based on obra/superpowers ecosystem research, Anthropic documentation, Anthropic internal practices, and community best practices (updated 2026-03).

---

## Frontmatter Reference

### Required Fields

| Field | Rules | Notes |
|-------|-------|-------|
| `name` | Letters, numbers, hyphens only; max 64 chars | If omitted, uses directory name |
| `description` | Max 1024 chars; third person; `Use when...` format | Claude uses this to decide whether to invoke |

### Optional Fields

| Field | Type | Purpose |
|-------|------|---------|
| `argument-hint` | string | Autocomplete hint, e.g. `[issue-number]` or `[filename] [format]` |
| `context` | `fork` | Run in isolated subagent context (no conversation history) |
| `agent` | string | Subagent type when `context: fork` — `Explore`, `Plan`, `general-purpose` |
| `model` | string | Override model for this skill |
| `allowed-tools` | list | Tools Claude can use without permission when skill is active |
| `hooks` | object | Lifecycle hooks scoped to this skill |
| `disable-model-invocation` | bool | `true` = only user can `/invoke` (hidden from Claude) |
| `user-invocable` | bool | `false` = only Claude can auto-invoke (hidden from `/` menu) |

### Invocation Control Matrix

| Setting | User invokes | Claude invokes | Description loaded at startup |
|---------|-------------|----------------|-------------------------------|
| Default | Yes | Yes | Yes |
| `disable-model-invocation: true` | Yes | No | No |
| `user-invocable: false` | No | Yes | Yes |

### Frontmatter Principles

- **Description = trigger condition**, not functionality description
- Start with `Use when...`, write in third person
- **Never describe workflow steps in description** — AI may read only the description and act on it prematurely
- Include keywords users would naturally say (improves auto-invocation matching)
- Description budget is 2% of context window, shared across all skills (1M context ≈ 20K chars total). Be concise, but prioritize trigger quality over arbitrary length limits.

---

## Nine Skill Types

Skills cluster into recurring categories. The best skills fit cleanly into one; confusing skills straddle several.

### 1. Library & API Reference

Skills that explain how to correctly use a library, CLI, or SDK. Include reference code snippets and a list of gotchas.

**Examples**: `billing-lib` (internal billing edge cases), `internal-platform-cli` (subcommands with examples), `frontend-design` (your design system)

### 2. Product Verification

Skills that test/verify code works. Often paired with playwright, tmux, or similar tools. **Worth investing heavily** — consider having an engineer spend a week making verification skills excellent.

Techniques: have Claude record video of its output, enforce programmatic assertions at each step, include test scripts in the skill folder.

**Examples**: `signup-flow-driver` (headless browser verification), `checkout-verifier` (Stripe test cards), `tmux-cli-driver` (TTY-based CLI testing)

### 3. Data Fetching & Analysis

Skills that connect to your data and monitoring stacks. Include libraries, credentials references, dashboard IDs, and common query workflows.

**Examples**: `funnel-query` (event joins for signup → activation → paid), `cohort-compare` (retention/conversion with significance testing), `grafana` (datasource UIDs, problem → dashboard lookup)

### 4. Business Process & Team Automation

Skills that automate repetitive workflows into one command. Often depend on other skills or MCPs. Tip: save results in log files to help Claude stay consistent across executions.

**Examples**: `standup-post` (aggregates tracker + GitHub + Slack), `create-ticket` (enforces schema + post-creation workflow), `weekly-recap` (PRs + tickets + deploys → formatted post)

### 5. Code Scaffolding & Templates

Skills that generate boilerplate for your specific codebase. Combine with composable scripts. Especially useful when scaffolding has natural-language requirements beyond pure code.

**Examples**: `new-workflow` (service/handler with your annotations), `new-migration` (template + gotchas), `create-app` (auth, logging, deploy pre-wired)

### 6. Code Quality & Review

Skills that enforce code quality. Can include deterministic scripts for robustness. Consider running via hooks or GitHub Actions.

**Examples**: `adversarial-review` (subagent critique loop), `code-style` (styles Claude defaults poorly on), `testing-practices` (how and what to test)

### 7. CI/CD & Deployment

Skills that help fetch, push, and deploy code. May reference other skills for data collection.

**Examples**: `babysit-pr` (retry flaky CI → resolve conflicts → auto-merge), `deploy-service` (build → smoke → gradual rollout → auto-rollback), `cherry-pick-prod` (worktree → cherry-pick → PR)

### 8. Runbooks

Skills that take a symptom (Slack thread, alert, error signature) and walk through investigation to produce a structured report.

**Examples**: `service-debugging` (symptom → tool → query mapping), `oncall-runner` (fetch alert → check suspects → format finding), `log-correlator` (request ID → cross-system log correlation)

### 9. Infrastructure Operations

Skills for routine maintenance with guardrails on destructive actions.

**Examples**: `orphan-cleanup` (find orphaned resources → Slack → soak → confirm → cleanup), `dependency-management` (org approval workflow), `cost-investigation` (storage/egress spike analysis)

---

## Dynamic Content Injection

### String Substitutions

```yaml
---
name: fix-issue
argument-hint: "[issue-number]"
---

Fix GitHub issue $ARGUMENTS following our coding standards.
Use $0 as the issue number.
Session: ${CLAUDE_SESSION_ID}
Skill dir: ${CLAUDE_SKILL_DIR}
```

| Variable | Resolves to |
|----------|-------------|
| `$ARGUMENTS` | All arguments after `/skill-name` |
| `$0`, `$1`, `$2` | Individual positional arguments |
| `$ARGUMENTS[0]` | Alternative syntax for positional |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Absolute path to skill directory |
| `${CLAUDE_PLUGIN_DATA}` | Persistent data folder (survives plugin upgrades) |

### Shell Command Injection

Pre-render skill content with live data using the `!` + backtick-wrapped command syntax:

```markdown
## Current PR context
- Diff: !`gh pr diff`
- Comments: !`gh pr view --comments`

Review this PR based on our standards.
```

The command executes **before** Claude sees the skill content. Output replaces the placeholder inline. Use for injecting dynamic context (git state, PR info, env data).

---

## Context Modes

### Inline (default)

Skill runs in the main conversation. Has access to full conversation history. Best for reference material, guidelines, and skills that need conversational context.

### Forked (`context: fork`)

Skill runs in an isolated subagent. No conversation history. Best for:
- Scoped tasks with explicit, self-contained instructions
- Heavy operations that shouldn't pollute main context
- Tasks that benefit from a specific agent type

```yaml
---
name: deep-review
context: fork
agent: Explore
---

Thoroughly analyze the codebase for security issues...
```

---

## Content Structure Template

```
Overview        → Core principle in 1-2 sentences
When to Use     → Symptom/scenario list + when NOT to use
Core Pattern    → Decision flow or key rules
Gotchas         → Common failure points (highest-value content)
Quick Reference → Scannable lookup table
Implementation  → Concrete steps
Common Mistakes → Frequent errors + corrections
```

Keep the structure flat. Readers (AI and human) scan top-down. Put the most important information first.

---

## Six Key Patterns

### 1. Iron Law

A single, absolute rule placed in a code block. No exceptions, no qualifiers.

```
NEVER skip the confirmation step before destructive operations.
```

Works because it removes ambiguity. AI has no room to interpret or negotiate.

### 2. Rationalization Table

Pre-empt the ways AI will justify skipping your rules. Format as a two-column table:

| AI thinks... | Correct response |
|---|---|
| "This is a simple case, I can skip validation" | Always validate. Simple cases become complex. |
| "The user seems to want speed over safety" | Safety is non-negotiable unless explicitly overridden. |
| "I already checked this in a previous step" | Re-check. Context may have changed. |

This is the most underrated pattern. Without it, AI will find creative reasons to bypass your carefully written rules.

### 3. Red Flags

Self-check triggers. When AI notices itself thinking certain thoughts, it should pause and reconsider.

> **Red flags** — If you catch yourself thinking any of these, STOP:
> - "This is probably fine..."
> - "I'll clean this up later..."
> - "The user won't notice..."

### 4. Phase-Gate

For complex workflows, define sequential phases. Each phase must complete before the next begins.

```
Phase 1: Research → Read all relevant files. Do NOT write code yet.
Phase 2: Plan    → Present approach to user. Wait for approval.
Phase 3: Execute → Implement the approved plan.
Phase 4: Verify  → Run tests. Confirm no regressions.
```

Prevents the AI from jumping ahead to implementation before understanding the problem.

### 5. Hub-and-Spoke

SKILL.md is the hub — concise, scannable, always loaded. Detailed references live in `references/` and are loaded on demand.

```
skills/my-skill/
├── SKILL.md              # < 200 words, links to references
└── references/
    ├── api-guide.md      # loaded when AI needs API details
    └── error-catalog.md  # loaded when debugging
```

Rules:
- References only one level deep (no nested references)
- Never use `@` links (force-loads entire file into context)
- SKILL.md should be useful even without loading references

This pattern is now the **official recommended architecture** — Claude Code's progressive loading system is designed around it: startup loads name+description, invocation loads SKILL.md, references load on demand.

### 6. Concrete Verification

Show correct and incorrect examples side by side. AI learns faster from contrast than from description.

```markdown
## Wrong
git add -A && git commit -m "fix"

## Right
git add src/specific-file.ts
git commit -m "fix: resolve null check in user validation"
```

---

## Best Practices

### Build a Gotchas Section

The **highest-signal content** in any skill is the Gotchas section. Build it from real failure points Claude encounters when using your skill. Update it over time — good skills are maintained, not just written.

```markdown
## Gotchas
- `createUser()` silently succeeds with duplicate emails — always check existence first
- The staging API returns 200 even on auth failure — check the response body
- Date fields use UTC but the dashboard displays local time — specify timezone explicitly
```

### Don't State the Obvious

Focus on information that pushes Claude out of its normal way of thinking. Delete basic explanations. Include only expert decisions, trade-offs, and project-specific conventions.

### Setup & Config Pattern

For skills that need user-specific context (channels, credentials, preferences), store setup in a config file:

```markdown
## Setup
If `${CLAUDE_PLUGIN_DATA}/config.json` does not exist, ask the user:
1. Which Slack channel to post to?
2. What timezone for timestamps?

Store answers in `${CLAUDE_PLUGIN_DATA}/config.json`.
Use the AskUserQuestion tool for structured, multiple-choice questions.
```

### Scripts & Code Composition

Include helper scripts and libraries in the skill folder. Claude composes them at runtime instead of reconstructing boilerplate.

```
skills/data-analysis/
├── SKILL.md
├── lib/
│   ├── fetch_events.py     # query event source
│   ├── compute_funnel.py   # funnel analysis
│   └── format_report.py    # output formatting
```

Claude reads these helpers and generates glue code to compose them for complex analysis tasks.

### Skill Composition

Skills can reference other skills by name. Claude will invoke them if installed:

```markdown
After generating the report, use the `/file-upload` skill to share it.
```

No formal dependency management — just reference by name and document the dependency.

---

## Persuasion Principles

Based on Meincke et al. (2025) — which influence techniques work on LLMs:

| Principle | How to apply | Example |
|---|---|---|
| **Authority** | `YOU MUST` / `Never` / `No exceptions` | Most effective for disciplinary skills |
| **Commitment** | Require explicit declaration of choice | "State which approach you chose and why" |
| **Scarcity** | Time/order constraints | "Before proceeding, verify X" |
| **Social Proof** | Universal patterns, failure modes | "Every successful deployment includes..." |

**Avoid**:
- **Reciprocity** — feels manipulative, AI may over-comply
- **Liking** — produces sycophantic behavior

---

## Token Efficiency

### Budget Mechanics

- **Description budget**: 2% of context window, shared across all skills. If you have many skills, low-priority descriptions get excluded.
- Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable
- Fallback: 16,000 characters total for all descriptions

### Guidelines

| Component | Budget |
|-----------|--------|
| Description | Concise but complete — prioritize trigger quality (budget: 2% of context window) |
| SKILL.md body | < 500 words, < 500 lines |
| Frequently loaded skills | < 200 words body |
| References | One level deep, loaded on demand |

### Progressive Loading (Official)

```
Startup     → name + description only (always in context)
Invocation  → SKILL.md body loaded
On demand   → references/ files loaded as needed
```

This is not a suggestion — it's how the system works. Design your skill to be useful at each level.

---

## TDD Development Process

### RED — Establish Baseline

1. Create a realistic pressure scenario where AI typically fails
2. Run the scenario **without** the skill
3. Record exact failure behavior (screenshots, logs, transcripts)
4. This is your regression test

### GREEN — Write and Validate

1. Write the skill following the patterns above
2. Run the same scenario **with** the skill loaded
3. Verify the behavior improves
4. Check token cost — is the skill worth the context it consumes?

### REFACTOR — Harden

1. Run more scenarios. Find new ways AI rationalizes bypassing your rules
2. Add these to the Rationalization Table
3. Trim unnecessary words — every token costs context
4. Retest to ensure changes don't regress behavior

This cycle continues. Good skills are maintained, not just written.

---

## Skill-Scoped Hooks

Skills can define lifecycle hooks in frontmatter:

```yaml
---
name: deploy
hooks:
  PostToolUse:
    - matcher: "Bash(npm *)"
      hooks:
        - type: command
          command: "npm audit"
---
```

Hook events include `PreToolUse` (can block), `PostToolUse`, `Elicitation`, `PostCompact`, and 13 others. Use hooks for safety gates, auto-validation, and workflow enforcement within a skill's scope.

### On-Demand Hooks Pattern

Use skill-scoped hooks for opinionated safety that you only want sometimes:

```yaml
---
name: careful
hooks:
  PreToolUse:
    - matcher: "Bash(rm -rf *)"
      hooks:
        - type: command
          command: "echo 'BLOCKED: rm -rf in careful mode' >&2 && exit 1"
    - matcher: "Bash(*force*push*)"
      hooks:
        - type: command
          command: "echo 'BLOCKED: force push in careful mode' >&2 && exit 1"
---
```

Invoke `/careful` when touching production. Having these hooks always-on would be too restrictive.

---

## Memory & Persistent Data

Skills can maintain state across invocations by storing data in `${CLAUDE_PLUGIN_DATA}`:

```markdown
After posting standup, append a summary to `${CLAUDE_PLUGIN_DATA}/standups.log`.
Next invocation, read the log to identify what changed since yesterday.
```

**Important**: Data in the skill directory (`${CLAUDE_SKILL_DIR}`) may be deleted on plugin upgrade. Always use `${CLAUDE_PLUGIN_DATA}` for persistent state.

Formats range from simple (append-only text log) to complex (SQLite database).
