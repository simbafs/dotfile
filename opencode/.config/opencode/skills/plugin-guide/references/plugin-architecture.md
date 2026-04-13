# Plugin Architecture Guide

Complete guide to packaging Claude Code skills and MCP servers into distributable plugins. Updated 2026-03.

---

## Three-Repo Separation Architecture

```
marketplace repo  ← Plugin catalog only, minimal
plugin repo       ← Skills + embedded MCP dist, the installable unit
mcp server repo   ← Standalone MCP server, usable outside Claude Code
```

### Why Three Repos?

- **Marketplace** can host multiple plugins; not tied to a single plugin
- **MCP server** stays independent — usable with any MCP client, not just Claude Code
- **Plugin** is the glue layer: packages MCP + Skills into one-click install

### When to Use Fewer

| Situation | Recommendation |
|---|---|
| Skills only, no MCP tools | Single repo, no need for three |
| MCP server for Claude Code only | Two repos (marketplace + plugin with embedded MCP) |
| MCP server used by multiple clients | Full three-repo separation |

---

## Plugin Repo Structure

### Standard Layout

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json              # ONLY file in .claude-plugin/
├── skills/                       # Agent skills
│   └── my-skill/
│       ├── SKILL.md
│       └── references/
├── commands/                     # Custom slash commands
│   └── deploy.md
├── agents/                       # Subagent definitions
│   └── reviewer.md
├── hooks/
│   └── hooks.json               # Hook configurations
├── mcp/dist/                     # Embedded MCP server
├── .mcp.json                    # MCP server declarations
├── .lsp.json                    # LSP server declarations
├── settings.json                # Default settings
├── scripts/                     # Utility scripts
├── LICENSE
└── README.md
```

**Critical rule**: Only `plugin.json` goes in `.claude-plugin/`. All other config files live at plugin root.

### plugin.json — Complete Schema

```json
{
  "name": "my-plugin",
  "description": "Plugin description",
  "version": "1.0.0",
  "author": { "name": "...", "email": "..." },
  "homepage": "https://...",
  "repository": "https://github.com/...",
  "license": "MIT",
  "keywords": ["skill", "linting"],

  "skills": "skills/",
  "commands": "commands/",
  "agents": "agents/",
  "hooks": "hooks/hooks.json",
  "outputStyles": ["styles/custom.md"],

  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/mcp/dist/index.js"],
      "env": {
        "DATA_PATH": "${CLAUDE_PLUGIN_ROOT}/data"
      }
    }
  },

  "lspServers": {
    "go": {
      "command": "gopls",
      "args": ["serve"],
      "extensionToLanguage": { ".go": "go" }
    }
  }
}
```

### Component Types

| Field | Type | Description |
|-------|------|-------------|
| `skills` | string/array | Skill directory paths |
| `commands` | string/array | Custom slash command files |
| `agents` | string/array | Subagent definition files |
| `hooks` | string/array/object | Hook config or paths |
| `mcpServers` | string/array/object | MCP server config or path |
| `lspServers` | string/array/object | LSP server config or path |
| `outputStyles` | string/array | Output style file paths |

`${CLAUDE_PLUGIN_ROOT}` resolves to the plugin's install path. Use it in all paths.

### Version Management

Follow semver. **Claude Code caches plugins and uses version to detect updates.** If you change code without bumping version, users won't see changes.

---

## Marketplace Format

Reference: [obra/superpowers-marketplace](https://github.com/obra/superpowers-marketplace)

### Marketplace Repo Structure

```
.claude-plugin/marketplace.json    # plugin catalog
README.md
```

### marketplace.json

```json
{
  "name": "marketplace-name",
  "owner": { "name": "...", "email": "..." },
  "metadata": {
    "description": "...",
    "version": "1.0.0",
    "pluginRoot": "./plugins"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": { "source": "github", "repo": "owner/repo", "ref": "v1.0.0" },
      "description": "...",
      "version": "1.0.0",
      "category": "productivity",
      "tags": ["linting", "i18n"],
      "strict": true
    }
  ]
}
```

### Plugin Source Types

| Type | Format | Use case |
|------|--------|----------|
| Relative path | `"./plugins/my-plugin"` | Monorepo / dev marketplace |
| GitHub | `{ "source": "github", "repo": "owner/repo", "ref": "v1.0.0", "sha": "..." }` | Most common |
| Git URL | `{ "source": "url", "url": "https://gitlab.com/..." }` | Non-GitHub hosts |
| Git subdirectory | `{ "source": "git-subdir", "url": "...", "path": "tools/plugin" }` | Plugin in a subdirectory |
| npm | `{ "source": "npm", "package": "@org/plugin", "version": "2.1.0" }` | npm registry |
| pip | `{ "source": "pip", "package": "my_plugin", "version": "1.0.0" }` | PyPI registry |

### Strict Mode

- `strict: true` (default) — `plugin.json` is authority; marketplace supplements it
- `strict: false` — Marketplace entry is the entire definition (for marketplace curators)

### Dev Marketplace (Self-Install)

Plugin repo includes its own `.claude-plugin/marketplace.json` with `source: "./"`:

```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./",
      "description": "...",
      "version": "1.0.0"
    }
  ]
}
```

Install via: `/plugin marketplace add <user>/<plugin-repo>`

### Release Channels

Use different git refs to maintain stable vs latest:

```json
{
  "plugins": [{
    "name": "formatter",
    "source": { "source": "github", "repo": "acme/formatter", "ref": "stable" }
  }]
}
```

---

## Hooks System

### Overview

Hooks are lifecycle event listeners that execute shell commands at specific moments. 17 events available as of 2026-03.

### Key Events

| Event | Can block? | Use case |
|-------|-----------|----------|
| `PreToolUse` | Yes | Security gates, file protection |
| `PostToolUse` | No | Auto-validation, logging |
| `Elicitation` | Yes | Intercept MCP user-input requests |
| `PostCompact` | No | Post-compaction cleanup |

### Handler Types

1. **Command** — Shell command (simple checks, fast)
2. **Prompt** — LLM evaluation (semantic analysis)
3. **Agent** — Deep analysis requiring tool access

### Plugin-Level Hooks

Define in `hooks/hooks.json` or inline in `plugin.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit(**/production/**)",
        "hooks": [
          { "type": "command", "command": "echo 'Production file edit detected' >&2" }
        ]
      }
    ]
  }
}
```

### Skill-Scoped Hooks

Define directly in SKILL.md frontmatter — scoped to that skill's execution only.

---

## MCP Server Development

### Project Structure

```
src/
├── index.ts          # McpServer + StdioServerTransport
├── lib/
│   ├── exec.ts       # CLI executor (child_process)
│   └── parsers.ts    # CLI output parsers
└── tools/            # one file per tool
    └── tool-name.ts  # export function registerToolName(server)
```

### Tool Registration Pattern

```typescript
import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";

export function registerToolName(server: McpServer) {
  server.tool(
    "tool_name",
    "Description of what this tool does",
    { param: z.string().describe("Parameter description") },
    async ({ param }) => {
      // implementation
      return { content: [{ type: "text", text: result }] };
    },
  );
}
```

### Caching Strategy

For expensive CLI calls (e.g., `+show-config --default --docs` ~120KB output):
- Cache in-memory, keyed by version
- Share cache across multiple tools
- Invalidate on version change

### Testing via JSON-RPC

```bash
printf '{"jsonrpc":"2.0","method":"initialize","params":{...},"id":1}\n{"jsonrpc":"2.0","method":"notifications/initialized"}\n{"jsonrpc":"2.0","method":"tools/call","params":{"name":"tool_name","arguments":{}},"id":2}\n' \
  | node dist/index.js 2>/dev/null
```

### Build Process

```bash
bun build src/index.ts --target=node --outfile=dist/index.js
```

### MCP Server Embedding

**Recommended: Embed + npm dual-track**

| Approach | Pros | Cons |
|---|---|---|
| Embed (plugin includes dist/) | Install-and-go, no network needed | Must sync updates |
| External (npx) | Plugin stays minimal | Slow first launch, needs network |
| **Embed + npm dual-track** | Best of both | Maintain two release paths |

---

## Runtime Compatibility

**Problem**: Developed with Bun, but plugin users may not have Bun installed.

**Solution**: Target Node.js for distribution.

- Replace `Bun.spawn` with `node:child_process` (works in both Bun and Node.js)
- Build with `bun build --target=node` for Node.js-compatible output
- Develop with `bun run dev`, distribute with `node dist/index.js`

**Key insight**: `node:child_process` is fully compatible in Bun — no runtime detection needed.

---

## Plugin Caching & Path Rules

- Marketplace plugins are **copied** to `~/.claude/plugins/cache`, not used in-place
- Cannot reference `../shared-utils` (outside plugin directory)
- Symlinks within plugin directory are followed (content is copied)
- Always use `${CLAUDE_PLUGIN_ROOT}` for dynamic paths

---

## Release Checklist

1. MCP server: `bun run build` produces `dist/index.js`
2. MCP server: verify `node dist/index.js` runs (Node.js compatibility)
3. Plugin: copy `dist/index.js` to `mcp/dist/`
4. Plugin: bump `plugin.json` version (**required** — cache uses version to detect updates)
5. Marketplace: bump `marketplace.json` version
6. Commit and push all repos
7. New session: test `/plugin install` end-to-end
8. Verify skills load with `/skill-name`
9. Verify MCP tools appear in new session
10. Test with a fresh user perspective (no local state)

---

## Common Pitfalls

| Issue | Solution |
|---|---|
| MCP stdio transport: output goes to stdout | Never write to `process.stdout`; use `console.error` for debug |
| `Bun.spawn` not available | Use `node:child_process` — works in both runtimes |
| Zod v4 import path | MCP SDK v1.26+ supports Zod v4; use `import { z } from "zod"` (not `zod/v4`) |
| `server.tool()` API confusion | v1 raw shape API still works and is simpler than `registerTool()` |
| Plugin installed but MCP tools missing | MCP tools require a new session to load |
| Unicode quotes in CLI output | Parser must handle `\u201c\u201d` (smart quotes), not just `""` |
| Version not bumped → users see stale code | Always bump version — plugin cache keys on it |
| `plugin.json` not alone in `.claude-plugin/` | Only `plugin.json` goes there; everything else at plugin root |
| Referencing files outside plugin dir | Use `${CLAUDE_PLUGIN_ROOT}`; no `../` paths (sandbox) |
