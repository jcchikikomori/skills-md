---
name: claudecode-migrate
description: Automated migration from Claude Code to opencode, retaining configuration. Use when migrating from Claude Code to opencode globally.
---

# Claude Code → OpenCode Migration

Automated migration workflow following https://lopince.github.io/claudecode2opencode/

## Prerequisites

Load `skill(name="llm-config-export")` first for discovery logic.

## Phase 1: Discovery & Audit

Use llm-config-export discovery to find all Claude Code artifacts:

### Global paths to scan

```bash
# Core settings
~/.claude/settings.json
~/.claude/settings.local.json
~/.claude/keybindings.json

# Instructions
~/.claude/CLAUDE.md

# Skills, commands, agents
~/.claude/skills/
~/.claude/commands/
~/.claude/agents/

# Plugins
~/.claude/plugins/installed_plugins.json
~/.claude/plugins/data/

# MCP servers
~/.mcp.json

# Memories (plugin-managed — path varies per project)
~/.claude/projects/*/memory/
```

### Discovery commands

```bash
# Check if Claude Code is installed
which claude

# Find all memory directories
find ~/.claude/projects -type d -name memory 2>/dev/null

# Check for each file
test -e ~/.claude/settings.json && echo "Found settings.json"
test -e ~/.claude/CLAUDE.md && echo "Found CLAUDE.md"
test -e ~/.mcp.json && echo "Found MCP config"
```

Generate audit report showing:
- What Claude Code configurations exist
- What will be migrated
- What requires manual intervention
- What is excluded for security

## Phase 2: Configuration Translation

### settings.json → opencode.jsonc

| Claude Code Key | OpenCode Equivalent | Notes |
| --- | --- | --- |
| `permissions.allow` | `"permission": { "tool": { "*": "allow" } }` | Direct mapping |
| `permissions.deny` | `"permission": { "edit": "deny" }` | Direct mapping |
| `permissions.ask` | `"permission": { "bash": "ask" }` | Wildcard patterns supported |
| `permissions.defaultMode` | Set per-tool | No multi-mode system |
| `model` | `"model": "anthropic/claude-sonnet-4-20250514"` | Add provider prefix |
| `env` | `{env:VAR}` syntax | Variable substitution |
| `sandbox` | Document Docker/seccomp | No native sandbox |
| `autoMemoryEnabled` | Manual AGENTS.md | No auto-memory |
| `hooks` | Plugin event hooks | JS/TS-level automation |
| `additionalDirectories` | Launch from project root | Use `external_directory` permission |

**Permission translation example:**

```jsonc
// Claude Code settings.json
{
  "permissions": {
    "allow": ["Read", "Write"],
    "deny": ["Edit"],
    "ask": ["Bash"],
    "defaultMode": "allow"
  }
}

// OpenCode opencode.jsonc
{
  "permission": {
    "tool": {
      "*": "allow"
    },
    "edit": "deny",
    "bash": {
      "*": "ask",
      "git *": "allow",
      "npm *": "allow",
      "rm *": "deny",
      "sudo *": "deny"
    }
  }
}
```

**Model ID translation:**

```jsonc
// Claude Code
{ "model": "claude-sonnet-4-20250514" }

// OpenCode (provider prefix required)
{ "model": "anthropic/claude-sonnet-4-20250514" }
```

**Environment variable syntax:**

```jsonc
// Claude Code: ${ENV_VAR}
{ "url": "https://api.example.com/${API_KEY}" }

// OpenCode: {env:ENV_VAR}
{ "url": "https://api.example.com/{env:API_KEY}" }
```

### CLAUDE.md → AGENTS.md

1. **Run `/init`** in OpenCode to auto-generate `AGENTS.md` (reads existing CLAUDE.md, .cursorrules, .windsurfrules)

2. **List instruction files** in `opencode.jsonc`:

```jsonc
{
  "instructions": [
    "AGENTS.md",
    "CONTRIBUTING.md",
    "docs/guidelines/*.md"
  ]
}
```

3. **Handle CLAUDE.local.md:**
   - Option A: Create `AGENTS.local.md` (gitignored), add to `instructions` array
   - Option B: Use `~/.config/opencode/AGENTS.local.md` for personal overrides

4. **@imports → explicit instructions:**

```markdown
// CLAUDE.md syntax
@docs/architecture.md
@docs/api-spec.md

// OpenCode: List in instructions array
{
  "instructions": [
    "AGENTS.md",
    "docs/architecture.md",
    "docs/api-spec.md"
  ]
}
```

### Skills & Commands

**Skills — Direct migration:**

OpenCode reads `.claude/skills/` natively. Options:
- Leave in place (OpenCode reads from `.claude/skills/`, `.agents/skills/`, `.opencode/skills/`)
- Copy to `~/.config/opencode/skills/`

```bash
# Option 1: Symlink (keeps single source of truth)
ln -s ~/.claude/skills ~/.config/opencode/skills

# Option 2: Copy (independent)
cp -r ~/.claude/skills ~/.config/opencode/skills
```

**Unsupported skill frontmatter fields:**

| Field | OpenCode Support | Conversion |
| --- | --- | --- |
| `model` | No | Convert to agent |
| `allowed-tools` | No | Convert to agent with `permission` |
| `context: fork` | No | Convert to command with `"subtask": true` |
| `arguments` | No | Convert to command with `$ARGUMENTS` |
| `hooks`, `paths` | No | Use plugin hooks or agent scoping |

**Commands — Direct migration:**

```bash
# Copy commands directory
cp -r ~/.claude/commands ~/.config/opencode/commands
```

OpenCode command templates support:
- `$ARGUMENTS`, `$1`, `$2` (positional params)
- ``` `!`cmd`` ``` (shell injection)
- `@filename` (file reference)

### MCP Servers

Translate `.mcp.json` → `opencode.jsonc["mcp"]`:

| Aspect | Claude Code | OpenCode |
| --- | --- | --- |
| Local transport | `type: "stdio"` | `type: "local"` |
| Remote transport | `type: "http"` | `type: "remote"` |
| Command format | `command` + `args` (separate) | `command` (single array) |
| Env var syntax | `${ENV_VAR}` | `{env:ENV_VAR}` |
| OAuth | Supported | Supported with `clientId`, `clientSecret`, `scope` |

**Translation example:**

```jsonc
// Claude Code: .mcp.json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer ${GITHUB_TOKEN}" }
    },
    "local-db": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@bytebase/dbhub", "--dsn", "postgresql://..."]
    }
  }
}

// OpenCode: opencode.jsonc
{
  "mcp": {
    "github": {
      "type": "remote",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer {env:GITHUB_TOKEN}" },
      "enabled": true
    },
    "local-db": {
      "type": "local",
      "command": ["npx", "-y", "@bytebase/dbhub", "--dsn", "postgresql://..."],
      "enabled": true
    }
  }
}
```

## Phase 3: Generate opencode Configuration

Write to `~/.config/opencode/opencode.jsonc`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "autoupdate": true,
  "instructions": [
    "AGENTS.md"
  ],
  "plugin": [
    // From plugin discovery
  ],
  "model": "{env:OPENCODE_MODEL}",
  "small_model": "{env:OPENCODE_SMALL_MODEL}",
  "permission": {
    // Translated from settings.json
  },
  "provider": {
    // Provider configurations
  },
  "mcp": {
    // Translated from .mcp.json
  }
}
```

## Phase 4: Gap Analysis Report

Generate `migration-report.md` with:

| Claude Code Feature | OpenCode Status | Replacement Strategy |
| --- | --- | --- |
| **AgentTeam** | ✗ Not available | Parallel sessions + shared task files; external orchestration (LangChain, CrewAI, Makefile DAG) |
| **Auto memory** | ✗ Not available | Maintain AGENTS.md manually; make updates part of code review |
| **OS sandbox** | ✗ Not available | Docker containers, macOS sandbox profiles, Linux seccomp |
| **Skill auto-invocation** | ◐ Agent calls skill tool | Agent decides when to load based on task context |
| **UltraThink** | ◐ Partial | Use Claude Opus 4.x or OpenAI o-series with thinking budgets; dedicated agent with high `steps` |
| **Model switch mid-session** | ◐ Must restart | Switch agents (`Tab`) to use different models per-agent |
| **Plugin namespacing** | ✗ No namespace | Unique command name prefixes; document naming conventions |
| **Plugin marketplace** | ✗ No centralized discovery | Distribute via npm; document in team wiki |
| **Read/Edit path deny rules** | ✗ Gitignore-pattern rules | OS-level file permissions; containerization |

See [reference.md](./reference.md) for detailed replacement strategies with code examples.

## Phase 5: Validation

```bash
# 1. Validate opencode.jsonc syntax
# (OpenCode will fail to start if invalid)

# 2. Test MCP server connectivity
# Start opencode and verify MCP tools are available

# 3. Verify skills load correctly
opencode run -p "List available skills"

# 4. Check permission rules
opencode run -p "What are my current permissions?"
```

## Security

**Excluded from migration (require explicit opt-in):**

| File | Why excluded |
| --- | --- |
| `~/.claude/credentials.json` | Auth tokens — rotate after migration, never share |
| `~/.claude/history.jsonl` | Full conversation history — large and personal |
| `~/.claude/transcripts/` | Session transcripts |
| `~/.claude/session-env/` | Shell environment snapshots — meaningless on new machine |
| `~/.claude/plugins/cache/` | ~3K files — reinstall from plugin registry |
| `~/.claude/file-history/` | Per-file edit history — large, not portable |

## Post-Migration Checklist

1. Start opencode: `opencode`
2. Test basic commands: `/help`, `/init`, `/connect`
3. Verify skills load: `/skill-name` or natural language trigger
4. Test MCP tools if configured
5. Review gap analysis report and implement replacement strategies
6. Update team documentation with new workflows

## See Also

- [llm-config-export](../llm-config-export/SKILL.md) — Discovery and manifest generation
- [reference.md](./reference.md) — Full translation tables, gap analysis details, plugin hook patterns
