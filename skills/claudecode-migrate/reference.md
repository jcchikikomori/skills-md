# Claude Code → OpenCode Migration Reference

Extended reference material for the `claudecode-migrate` skill.

---

## Table of Contents

1. [Full Translation Tables](#full-translation-tables)
2. [Manifest Schema](#manifest-schema)
3. [Gap Analysis Detail](#gap-analysis-detail)
4. [Plugin Hook Migration Patterns](#plugin-hook-migration-patterns)
5. [MCP Server Translation Examples](#mcp-server-translation-examples)
6. [Troubleshooting](#troubleshooting)

---

## Full Translation Tables

### Settings Keys

| Claude Code | OpenCode | Notes |
| --- | --- | --- |
| `permissions.allow` | `"permission": { "tool": { "*": "allow" } }` | Wildcard patterns supported |
| `permissions.deny` | `"permission": { "edit": "deny" }` | Per-tool category |
| `permissions.ask` | `"permission": { "bash": "ask" }` | "Last matching rule wins" |
| `permissions.defaultMode` | Set per-tool | No multi-mode system |
| `model` | `"model": "provider/model-id"` | Provider prefix required |
| `env` | `{env:VAR}` syntax | Used in config values |
| `sandbox` | Document externally | Docker, seccomp, macOS profiles |
| `autoMemoryEnabled` | Manual AGENTS.md | No auto-memory |
| `hooks` | Plugin event hooks | JS/TS-level automation |
| `additionalDirectories` | Launch from project root | Use `external_directory` permission |

### Permission Patterns

```jsonc
// Claude Code
{
  "permissions": {
    "allow": ["Read", "Write", "Edit"],
    "deny": ["Bash"],
    "ask": ["Mcp"]
  }
}

// OpenCode equivalent
{
  "permission": {
    "tool": {
      "*": "allow"
    },
    "bash": {
      "*": "deny"
    },
    "mcp": {
      "*": "ask"
    }
  }
}
```

```jsonc
// Claude Code with wildcards
{
  "permissions": {
    "allow": ["Read", "Write"],
    "deny": ["Edit"],
    "ask": ["Bash"]
  },
  "permissionRules": {
    "Bash": {
      "git *": "allow",
      "npm *": "allow",
      "*": "ask"
    }
  }
}

// OpenCode equivalent (wildcards in bash permission)
{
  "permission": {
    "tool": {
      "*": "allow",
      "edit": "deny"
    },
    "bash": {
      "*": "ask",
      "git *": "allow",
      "npm *": "allow"
    }
  }
}
```

### Model ID Translation

| Claude Code | OpenCode |
| --- | --- |
| `claude-sonnet-4-20250514` | `anthropic/claude-sonnet-4-20250514` |
| `claude-opus-4-20250514` | `anthropic/claude-opus-4-20250514` |
| `claude-haiku-3-5-20241201` | `anthropic/claude-3-5-haiku-20241201` |
| `gpt-4o` | `openai/gpt-4o` |
| `o1-pro` | `openai/o1-pro` |
| `gemini-2.5-pro` | `google/gemini-2.5-pro` |

Provider prefixes: `anthropic/`, `openai/`, `google/`, `amazon-bedrock/`, `github-copilot/`, etc.

---

## Manifest Schema

Migration manifest generated in Phase 1:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["version", "generated_at", "tool", "paths", "missing"],
  "properties": {
    "version": {
      "type": "string",
      "const": "1"
    },
    "generated_at": {
      "type": "string",
      "format": "date-time"
    },
    "tool": {
      "type": "string",
      "enum": ["claude-code"]
    },
    "paths": {
      "type": "object",
      "properties": {
        "global_settings": { "type": ["string", "null"] },
        "project_settings": { "type": "array", "items": { "type": "string" } },
        "instructions": { "type": "array", "items": { "type": "string" } },
        "plugins": { "type": ["string", "null"] },
        "mcps": { "type": "array", "items": { "type": "string" } },
        "skills": { "type": ["string", "null"] },
        "commands": { "type": ["string", "null"] },
        "agents": { "type": ["string", "null"] },
        "memories": { "type": "array", "items": { "type": "string" } }
      }
    },
    "missing": {
      "type": "array",
      "items": { "type": "string" }
    },
    "sensitive_excluded": {
      "type": "array",
      "items": { "type": "string" },
      "default": ["~/.claude/credentials.json"]
    }
  }
}
```

---

## Gap Analysis Detail

### ✗ AgentTeam (Multi-session Coordination)

**Claude Code:** AgentTeam launches multiple subagents in parallel with shared task list. Agents spawn sub-agents and delegate subtasks.

**OpenCode:** No multi-session coordination.

**Replacement strategies:**

```bash
# Option 1: Parallel sessions with different agents
opencode run --agent frontend -p "Review frontend code" &
opencode run --agent backend -p "Review backend code" &
wait
```

```bash
# Option 2: Shared task file for coordination
cat > tasks.md << 'EOF'
- [ ] Refactor auth module
- [ ] Update API endpoints
- [ ] Write migration tests
EOF

# Each agent reads from shared task file
```

```makefile
# Option 3: Makefile orchestration
.PHONY: multi-agent
multi-agent:
	opencode run --agent frontend -f ./frontend -p "Review code" &
	opencode run --agent backend -f ./backend -p "Review code" &
	wait
```

For complex workflows: LangChain, CrewAI, or CI pipeline DAGs.

---

### ✗ Auto Memory

**Claude Code:** Automatically saves learnings, preferences, debugging insights to `~/.claude/projects/<project>/memory/`. Accumulates across sessions.

**OpenCode:** No auto memory. Each session is independent. All project knowledge lives in instruction files.

**Replacement strategy:**

```bash
# 1. Export existing memories before migrating
cat ~/.claude/projects/*/memory/MEMORY.md

# 2. Manually curate into AGENTS.md
# Key conventions, build commands, debugging patterns

# 3. Make instruction updates part of code review
# Add PR checklist item: "Updated AGENTS.md if new conventions discovered"
```

---

### ✗ OS-level Sandboxing

**Claude Code:** Filesystem and network sandbox for Bash commands.

**OpenCode:** No native sandbox.

**Replacement strategies:**

```bash
# Docker container for dangerous operations
docker run --rm -v $(pwd):/workspace alpine sh -c "cd /workspace && <command>"

# macOS sandbox profile
sandbox-exec -f /path/to/profile.sb <command>

# Linux seccomp-bpf
docker run --security-opt seccomp=<profile>.json <image> <command>
```

---

### ◐ Skill Auto-invocation

**Claude Code:** Skills auto-load when task matches description (pattern-matching).

**OpenCode:** Agent calls `skill` tool on demand based on task context.

**Impact:** Skills still load on-demand, but the agent decides when rather than pattern-matching. No action required — skills work the same in practice.

---

### ◐ UltraThink (Extended Reasoning)

**Claude Code:** UltraThink enables extended reasoning with higher thinking budgets.

**OpenCode:** Partial support via model selection and agent configuration.

**Replacement strategy:**

```jsonc
// opencode.jsonc — Dedicated deep-thinking agent
{
  "agent": {
    "deep-thinker": {
      "description": "Extended reasoning for complex architecture",
      "mode": "primary",
      "model": "anthropic/claude-opus-4-20250514",
      "prompt": "Think deeply. Break down problems step by step.",
      "steps": 50
    }
  }
}
```

Use Claude Opus 4.x or OpenAI o-series models which support extended thinking. Pass provider-specific options (like `reasoningEffort`) through agent config.

---

### ◐ Model Switch Mid-session

**Claude Code:** `/model` command switches model mid-session.

**OpenCode:** Must restart to change default model.

**Workaround:** Use different agents with different models:

```jsonc
// opencode.jsonc
{
  "agent": {
    "fast": {
      "description": "Quick tasks",
      "model": "anthropic/claude-3-haiku-20240307"
    },
    "smart": {
      "description": "Complex reasoning",
      "model": "anthropic/claude-opus-4-20250514"
    }
  }
}
```

Press `Tab` in TUI to cycle between agents.

---

## Plugin Hook Migration Patterns

Claude Code hooks are declarative YAML. OpenCode plugin hooks are JS/TS code.

### Common Migration Patterns

#### Lint/Format After Edits

**Claude Code:**

```yaml
# .claude/hooks.yml
PostToolUse:
  Write:
    - type: command
      command: npx prettier --write $FILE
  Edit:
    - type: command
      command: npx eslint --fix $FILE
```

**OpenCode — Formatters (built-in):**

```jsonc
// opencode.jsonc
{
  "formatter": {
    "prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "extensions": [".js", ".ts", ".jsx", ".tsx"]
    },
    "eslint-fix": {
      "command": ["npx", "eslint", "--fix", "$FILE"],
      "extensions": [".js", ".ts", ".jsx", ".tsx"]
    }
  }
}
```

**OpenCode — Plugin hook (JS/TS):**

```typescript
// .opencode/plugins/auto-format.ts
import type { Plugin } from "@opencode-ai/plugin";

export default function autoFormat(): Plugin {
  return {
    "tool.execute.after": async (ctx) => {
      if (ctx.tool === "write" || ctx.tool === "edit") {
        const filePath = ctx.params?.path;
        if (filePath?.endsWith(".ts") || filePath?.endsWith(".tsx")) {
          await ctx.client.app.exec({ command: `npx prettier --write ${filePath}` });
        }
      }
    }
  };
}
```

---

#### Block Dangerous Commands

**Claude Code:**

```yaml
# .claude/hooks.yml
PreToolUse:
  Bash:
    - type: script
      script: |
        if [[ "$COMMAND" == rm* ]] || [[ "$COMMAND" == sudo* ]]; then
          exit 2  # Block
        fi
```

**OpenCode — Permission deny:**

```jsonc
// opencode.jsonc
{
  "permission": {
    "bash": {
      "*": "allow",
      "rm *": "deny",
      "sudo *": "deny",
      "rm -rf *": "ask"
    }
  }
}
```

---

#### Session Start Setup

**Claude Code:**

```yaml
# .claude/hooks.yml
SessionStart:
  - type: script
    script: |
      export NODE_ENV=development
      export API_URL=http://localhost:3000
```

**OpenCode — Plugin hook:**

```typescript
// .opencode/plugins/session-setup.ts
import type { Plugin } from "@opencode-ai/plugin";

export default function sessionSetup(): Plugin {
  return {
    "session.created": async (ctx) => {
      await ctx.client.app.log("info", "Session starting");
      // Set up environment, warm caches, check deps
    },
    "shell.env": () => ({
      NODE_ENV: "development",
      API_URL: "http://localhost:3000"
    })
  };
}
```

---

#### Desktop Notifications

**Claude Code:**

```yaml
# .claude/hooks.yml
Notification:
  - type: script
    script: |
      osascript -e 'display notification "$MESSAGE"'  # macOS
      # notify-send "$MESSAGE"  # Linux
```

**OpenCode — Plugin hook:**

```typescript
// .opencode/plugins/notifications.ts
import type { Plugin } from "@opencode-ai/plugin";
import { exec } from "child_process";

export default function notifications(): Plugin {
  return {
    "tool.execute.after": async (ctx) => {
      if (ctx.tool === "bash" && ctx.result?.exitCode !== 0) {
        const platform = process.platform;
        if (platform === "darwin") {
          exec(`osascript -e 'display notification "Command failed"'`);
        } else if (platform === "linux") {
          exec(`notify-send "Command failed"`);
        }
      }
    }
  };
}
```

---

#### Auto-commit on Change

**Claude Code:**

```yaml
# .claude/hooks.yml
PostToolUse:
  Write:
    - type: script
      script: |
        git add $FILE
        git commit -m "Auto-commit: $FILE"
```

**OpenCode — External watcher or plugin:**

```typescript
// .opencode/plugins/auto-commit.ts
import type { Plugin } from "@opencode-ai/plugin";

export default function autoCommit(): Plugin {
  return {
    "tool.execute.after": async (ctx) => {
      if (ctx.tool === "write" || ctx.tool === "edit") {
        const filePath = ctx.params?.path;
        await ctx.client.app.exec({
          command: `git add ${filePath} && git commit -m "Auto-commit: ${filePath}"`
        });
      }
    }
  };
}
```

**Note:** This conflicts with the git skill's rule that AI should not commit. Use team conventions to decide.

---

### Available Plugin Hook Events

| Event | Trigger |
| --- | --- |
| `session.created` | New session starts |
| `session.updated` | Session context changes |
| `tool.execute.before` | Before any tool runs |
| `tool.execute.after` | After tool completes |
| `file.edited` | File write/edit |
| `shell.env` | Inject environment variables |
| `command.executed` | Slash command runs |
| `tui.command.execute` | TUI command interception |
| `tui.prompt.append` | Prompt input modification |
| `message.updated` | Message content changes |
| `permission.asked` | Permission decision point |
| `experimental.session.compacting` | Context compaction |

---

## MCP Server Translation Examples

### GitHub MCP

```jsonc
// Claude Code: .mcp.json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}

// OpenCode: opencode.jsonc
{
  "mcp": {
    "github": {
      "type": "remote",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer {env:GITHUB_PERSONAL_ACCESS_TOKEN}"
      },
      "enabled": true
    }
  }
}
```

---

### Local Database MCP

```jsonc
// Claude Code: .mcp.json
{
  "mcpServers": {
    "local-db": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@bytebase/dbhub", "--dsn", "postgresql://localhost/mydb"]
    }
  }
}

// OpenCode: opencode.jsonc
{
  "mcp": {
    "local-db": {
      "type": "local",
      "command": ["npx", "-y", "@bytebase/dbhub", "--dsn", "postgresql://localhost/mydb"],
      "enabled": true
    }
  }
}
```

---

### Docker-based MCP

```jsonc
// Claude Code: .mcp.json
{
  "mcpServers": {
    "sonarqube": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run",
        "--pull=always",
        "-i",
        "--rm",
        "-e", "SONARQUBE_TOKEN",
        "-e", "SONARQUBE_URL",
        "mcp/sonarqube"
      ],
      "env": {
        "SONARQUBE_TOKEN": "${SONARQUBE_TOKEN}",
        "SONARQUBE_URL": "${SONARQUBE_URL}"
      }
    }
  }
}

// OpenCode: opencode.jsonc
{
  "mcp": {
    "sonarqube": {
      "type": "local",
      "command": [
        "docker",
        "run",
        "--pull=always",
        "-i",
        "--rm",
        "-e", "SONARQUBE_TOKEN",
        "-e", "SONARQUBE_URL",
        "mcp/sonarqube"
      ],
      "environment": {
        "SONARQUBE_TOKEN": "{env:SONARQUBE_TOKEN}",
        "SONARQUBE_URL": "{env:SONARQUBE_URL}"
      },
      "enabled": true
    }
  }
}
```

---

### OAuth MCP Server

```jsonc
// Claude Code: .mcp.json
{
  "mcpServers": {
    "oauth-server": {
      "type": "http",
      "url": "https://mcp.example.com",
      "oauth": {
        "clientId": "${MCP_CLIENT_ID}",
        "clientSecret": "${MCP_CLIENT_SECRET}",
        "scope": "tools:read tools:execute"
      }
    }
  }
}

// OpenCode: opencode.jsonc
{
  "mcp": {
    "oauth-server": {
      "type": "remote",
      "url": "https://mcp.example.com",
      "oauth": {
        "clientId": "{env:MCP_CLIENT_ID}",
        "clientSecret": "{env:MCP_CLIENT_SECRET}",
        "scope": "tools:read tools:execute"
      },
      "enabled": true
    }
  }
}
```

---

### Tool Management (Per-agent Enable/Disable)

```jsonc
// OpenCode: Disable MCP tools globally, re-enable per-agent
{
  "tools": {
    "github_*": false
  },
  "agent": {
    "build": {
      "tools": {
        "github_*": true
      }
    }
  }
}
```

MCP tools are registered with server name prefix (e.g., `github_issues`, `github_pull_requests`).

---

## Troubleshooting

### opencode.jsonc Syntax Errors

**Symptom:** OpenCode fails to start or shows config errors.

**Fix:**
```bash
# Validate JSONC syntax
node -e "JSON.parse(require('fs').readFileSync('~/.config/opencode/opencode.jsonc', 'utf8').replace(/\\/\\/.*$/gm, ''))"
```

Or use an online JSONC validator.

---

### MCP Server Connection Failures

**Symptom:** MCP tools not appearing or connection errors.

**Checklist:**
1. Verify command path exists: `which npx`, `which docker`
2. Test MCP server manually: `npx -y @bytebase/dbhub --version`
3. Check environment variables: `echo $GITHUB_PERSONAL_ACCESS_TOKEN`
4. Review OpenCode logs for connection errors

---

### Skills Not Loading

**Symptom:** Skills directory exists but skills not available.

**Checklist:**
1. Verify SKILL.md frontmatter has `name` and `description`
2. Check directory structure: `<skill-name>/SKILL.md`
3. Test: `opencode run -p "List available skills"`
4. Review skill loading logs

---

### Permission Rules Not Working

**Symptom:** Commands allowed despite deny rules.

**Remember:** "Last matching rule wins"

```jsonc
// WRONG: Wildcard after specific rule
{
  "bash": {
    "*": "allow",      // ← This wins (last match)
    "rm *": "deny"
  }
}

// CORRECT: Specific rules after wildcard
{
  "bash": {
    "*": "allow",
    "rm *": "deny",    // ← This wins (last match)
    "sudo *": "deny"
  }
}
```

---

### Model Not Found Errors

**Symptom:** "Model X not available" errors.

**Fix:** Ensure provider prefix:
```jsonc
// WRONG
{ "model": "claude-sonnet-4-20250514" }

// CORRECT
{ "model": "anthropic/claude-sonnet-4-20250514" }
```

Check provider configuration in `opencode.jsonc`:
```jsonc
{
  "provider": {
    "anthropic": {},
    "openai": {},
    "github-copilot": {}
  }
}
```

---

### Memory Path Issues

**Symptom:** Memories not found after migration.

**Note:** OpenCode has no auto-memory. Convert memories to AGENTS.md content:

```bash
# Export Claude Code memories
cat ~/.claude/projects/*/memory/MEMORY.md

# Curate into AGENTS.md manually
# Make instruction updates part of code review
```

---

## Migration Checklist

```markdown
## Pre-Migration
- [ ] Run discovery audit (Phase 1)
- [ ] Review migration manifest
- [ ] Backup existing configs (optional)

## Migration
- [ ] Translate settings.json → opencode.jsonc
- [ ] Migrate CLAUDE.md → AGENTS.md
- [ ] Copy skills directory
- [ ] Copy commands directory
- [ ] Translate MCP servers
- [ ] Configure plugins (document hooks)

## Post-Migration
- [ ] Validate opencode.jsonc syntax
- [ ] Start opencode and test `/help`
- [ ] Test `/connect` for provider setup
- [ ] Verify skills load correctly
- [ ] Test MCP tools
- [ ] Review gap analysis report
- [ ] Implement replacement strategies
- [ ] Update team documentation
```
