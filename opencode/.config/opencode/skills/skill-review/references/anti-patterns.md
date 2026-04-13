# Skill & Plugin Anti-Patterns

22 common design mistakes that degrade skill effectiveness, waste tokens, or introduce security risks. Use this as a checklist when reviewing existing skills or validating new ones.

Format: **Symptom** (what you observe) → **Problem** (root cause) → **Fix** (what to do instead).

---

## Trigger & Matching

### 1. Phantom Trigger

| Symptom | Problem | Fix |
|---|---|---|
| Skill fires on unrelated prompts, or never fires at all | Description too vague — matches everything or nothing | Write specific trigger conditions with concrete keywords users would actually say. Test with 5+ prompts spanning intended scope and boundary cases. |

```markdown
# Bad
description: "Helps with code"

# Good
description: >
  Use when reviewing pull requests for security vulnerabilities,
  checking authentication flows, or auditing input validation.
```

### 2. Silent Misfire

| Symptom | Problem | Fix |
|---|---|---|
| Skill should trigger but doesn't (~20% activation with naive descriptions) | Description lacks the exact words users say; no example trigger phrases | Add multiple phrasings of the same intent. Optimized descriptions reach ~90% activation. |

```markdown
# Bad
description: "Assists with deployment workflows"

# Good
description: >
  Use when deploying to production, running release scripts,
  pushing to staging, or when the user says "ship it" or "deploy".
```

### 3. Cross-Fire

| Symptom | Problem | Fix |
|---|---|---|
| Wrong skill triggers — "create a plan to lint" fires `/lint` instead of `/planner` | Keyword overlap between skill descriptions | Audit all skill descriptions together. Use distinct, non-overlapping vocabulary. Add `disable-model-invocation: true` for side-effectful skills. |

### 4. Third-Person Mismatch

| Symptom | Problem | Fix |
|---|---|---|
| Inconsistent activation; discovery problems | Description uses first/second person ("I help...", "You should...") | Always write in third person: "Use when..." — this is how the description gets injected into system prompt. |

---

## Content Design

### 5. Kitchen Sink

| Symptom | Problem | Fix |
|---|---|---|
| SKILL.md exceeds 500 lines; token cost is high even when skill isn't needed | Everything crammed into one file; no progressive loading | Split: SKILL.md as hub (< 200 words), details in `references/`. Claude loads references on demand. |

### 6. God Skill

| Symptom | Problem | Fix |
|---|---|---|
| One skill covers reviewing, testing, deploying, and documenting | Too many responsibilities; description becomes vague; triggers unreliably | One skill = one job. Split into focused skills that can compose. |

### 7. Soft Language Trap

| Symptom | Problem | Fix |
|---|---|---|
| Claude treats your rules as optional suggestions | Words like "consider", "might want to", "you could" | Use commands: "Always", "Never", "YOU MUST". Community testing: flipping 10 soft rules to directives cut violations ~50%. |

```markdown
# Bad
Consider adding error handling for async operations.

# Good
Always wrap async operations in try/catch with typed error responses.
```

### 8. Over-Teaching

| Symptom | Problem | Fix |
|---|---|---|
| Skill wastes 200+ words explaining basics Claude already knows | Author explains what PDF is, how Python works, basic CS concepts | Delete all basic explanations. Focus on expert decisions, trade-offs, and project-specific conventions only. |

### 9. Procedural Straitjacket

| Symptom | Problem | Fix |
|---|---|---|
| Claude follows steps rigidly, can't adapt when reality diverges | Written as "Step 1, Step 2, Step 3..." mechanical procedure | Write decision frameworks: "Before doing X, evaluate Y." Use Phase-Gate pattern for ordering, but keep each phase's content principle-based. |

### 10. Workflow Description

| Symptom | Problem | Fix |
|---|---|---|
| Claude reads description and starts executing steps before loading the full skill | Description contains workflow steps instead of trigger conditions | Description = when to use. Body = what to do. Never put procedure in description. |

---

## Reference & Structure

### 11. Force Loader

| Symptom | Problem | Fix |
|---|---|---|
| Context window fills up immediately when skill activates | Using `@` links that force-load entire files into context | Use relative markdown links. Claude reads references on demand via hub-and-spoke. |

### 12. Nested References

| Symptom | Problem | Fix |
|---|---|---|
| Claude reads a reference, which points to another reference, which points to another... | References referencing references; unbounded depth | One level deep only. SKILL.md → references/. References never link to other references. |

### 13. Orphan Reference

| Symptom | Problem | Fix |
|---|---|---|
| Reference files exist in `references/` but are never loaded | SKILL.md doesn't mention them or provide explicit loading triggers | Add clear loading cues in SKILL.md: "For full API reference, see references/api-guide.md" at the decision point where Claude would need it. |

### 14. Redundant Duplication

| Symptom | Problem | Fix |
|---|---|---|
| Same concept explained in multiple files; updates miss one copy | Copy-paste between SKILL.md and references, or across skills | Single source of truth. SKILL.md summarizes; reference holds the detail. Never duplicate content across files. |

---

## Rule Enforcement

### 15. Naked Rule

| Symptom | Problem | Fix |
|---|---|---|
| Claude follows the rule initially, then starts skipping it mid-session | Iron Law exists but no Rationalization Table to block self-justification | Every Iron Law needs a companion Rationalization Table. Anticipate how Claude will justify bypassing the rule. |

### 16. Training-Data Override

| Symptom | Problem | Fix |
|---|---|---|
| Claude ignores explicit instructions, falls back to training-data habits | Skill's assertion is weaker than deeply-trained patterns | Use stronger authority signals: `YOU MUST`, code blocks for rules, Red Flags pattern. Repeat critical rules at decision points, not just at the top. |

---

## Security & Operations

### 17. Over-Permissioned

| Symptom | Problem | Fix |
|---|---|---|
| Skill has access to tools it doesn't need; expanded attack surface | `allowed-tools` lists everything available | Principle of least privilege. Only list tools the skill actually uses. A read-only review skill should not have Write or Bash. |

```yaml
# Bad
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Agent, WebFetch

# Good
allowed-tools: Read, Grep, Glob
```

### 18. Toxic Skill (Supply Chain Risk)

| Symptom | Problem | Fix |
|---|---|---|
| Installed skill runs unexpected commands or exfiltrates data | Skill bundles executable scripts with malicious payloads | Audit all scripts in skills before installing. Skills with scripts are 2.12x more likely to contain vulnerabilities (Snyk ToxicSkills study, n=3,984). Prefer instruction-only skills. |

### 19. Exclamation Mark Bomb

| Symptom | Problem | Fix |
|---|---|---|
| Skill silently fails to load; no error message | `!` inside inline code spans in SKILL.md breaks the skill parser | Avoid `!` in inline code. Use code blocks instead, or rephrase. Test that your skill actually loads after every edit. |

---

## Context Management (Usage-Level)

These are not skill design issues per se, but they affect how well any skill performs in practice.

### Context Bleed

Long sessions bury skill instructions under thousands of tokens of file reads and failed attempts. A clean 160K-token context outperforms a polluted 80K one. **Fix**: Start fresh sessions for new tasks. Use `/clear` when context is polluted.

### Correction Loop Pollution

After two failed corrections, the conversation context actively works against you — Claude has seen multiple wrong approaches and gets confused. **Fix**: `/clear` and rewrite the prompt from scratch instead of continuing to correct.

### Contradictory Multi-Layer Rules

Project CLAUDE.md says one thing, personal `~/.claude/CLAUDE.md` says the opposite. Claude has no principled way to resolve the conflict. **Fix**: Audit all CLAUDE.md layers together. Use project-level for project rules, personal-level for personal preferences. Never contradict.

---

## Effectiveness

### 20. Missing Gotchas

| Symptom | Problem | Fix |
|---|---|---|
| Claude keeps hitting the same failure modes; skill doesn't improve over time | No gotchas section, or gotchas not maintained | Build a Gotchas section from real Claude failures. Update it every time Claude fails in a new way. This is the highest-value content in any skill. |

### 21. No Persistent Memory

| Symptom | Problem | Fix |
|---|---|---|
| Skill can't learn from previous executions; each run starts from scratch | Data stored in skill directory (deleted on upgrade) or not stored at all | Use `${CLAUDE_PLUGIN_DATA}` for persistent state. Log previous executions so Claude can read its own history. |

### 22. Missed Composition

| Symptom | Problem | Fix |
|---|---|---|
| Skill reimplements functionality that another installed skill already provides | No awareness of related skills; duplicated effort | Reference other skills by name. Claude will invoke them if installed. Document skill dependencies. |

