# LLM Config Export — Reference

Extended schemas, path tables, and bundle layouts for [SKILL.md](./SKILL.md). To restore a bundle, use
[llm-config-import](../llm-config-import/SKILL.md).

---

## Manifest Schema

Full JSON Schema for `export-manifest.json`:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "required": ["version", "generated_at", "tool", "paths"],
  "properties": {
    "version": { "type": "string", "enum": ["1"] },
    "generated_at": { "type": "string", "format": "date-time" },
    "tool": {
      "type": "string",
      "enum": ["claude-code", "opencode", "unknown"]
    },
    "paths": {
      "type": "object",
      "properties": {
        "global_settings":  { "type": ["string", "null"] },
        "project_settings": { "type": "array", "items": { "type": "string" } },
        "instructions":     { "type": "array", "items": { "type": "string" } },
        "plugins":          { "type": ["string", "null"] },
        "mcps":             { "type": "array", "items": { "type": "string" } },
        "skills":           { "type": ["string", "null"] },
        "plans":            { "type": ["string", "null"] },
        "memories":         { "type": "array", "items": { "type": "string" } },
        "tasks":            { "type": ["string", "null"] },
        "keybindings":      { "type": ["string", "null"] }
      }
    },
    "missing":            { "type": "array", "items": { "type": "string" } },
    "sensitive_excluded": { "type": "array", "items": { "type": "string" } }
  }
}
```

---

## Claude Code Paths

| Item | Path | Notes |
|---|---|---|
| Main settings | `~/.claude/settings.json` | permissions, enabled plugins, marketplace sources |
| Project settings | `<project>/.claude/settings.json` | |
| Project settings (local) | `<project>/.claude/settings.local.json` | gitignored overrides |
| Global instructions | `~/.claude/CLAUDE.md` | |
| Project instructions | `<project>/CLAUDE.md` | checked first by Claude Code |
| Project instructions (alt) | `<project>/.claude/CLAUDE.md` | fallback location |
| Plugins registry | `~/.claude/plugins/installed_plugins.json` | plugin list + versions |
| Marketplaces | `~/.claude/plugins/known_marketplaces.json` | marketplace sources (`github`, `git`, `directory`) |
| Plugin data | `~/.claude/plugins/data/*.json` | lightweight per-plugin metadata |
| Custom skills | `~/.claude/skills/` | user-created SKILL.md files |
| Keybindings | `~/.claude/keybindings.json` | custom key bindings |
| Plans | `~/.claude/plans/*.md` | auto-named plan files |
| Tasks | `~/.claude/tasks/<uuid>/` | task state directories |
| Memories (remember plugin) | `~/.claude/projects/<project-slug>/memory/` | per-project memory files |
| MCPs (user scope) | `~/.claude.json` → `mcpServers` key | export this key only — the file also holds account state |
| MCPs (project) | `<project>/.mcp.json` | project-local MCP config |

### Memory slug encoding

The `<project-slug>` in memory paths is derived from the project's absolute path:

1. Take the absolute path: `/home/alice/Projects/my-app`
2. Replace every `/` with `-`: `-home-alice-Projects-my-app`

So memory lives at: `~/.claude/projects/-home-alice-Projects-my-app/memory/`

When restoring on a new machine with a different username or path, update the slug accordingly or re-initialize the memory directory under the new path.

---

## opencode Paths

opencode follows XDG Base Directory conventions (verified against opencode 1.18.30):

| Item | Path | Notes |
|---|---|---|
| Config root | `$XDG_CONFIG_HOME/opencode/` | defaults to `~/.config/opencode/` |
| Main settings | `~/.config/opencode/opencode.jsonc` | JSONC; holds `permission`, `instructions`, `mcp`, `plugin`, `provider` |
| Instructions | `~/.config/opencode/AGENTS.md` | global custom instructions |
| Skills | `~/.config/opencode/skills/` | same SKILL.md format as Claude Code |
| Agents | `~/.config/opencode/agents/` | |
| Commands | `~/.config/opencode/commands/` | |
| MCPs | `mcp` key inside `opencode.jsonc` | no separate MCP file |
| Plugins | `plugin` key inside `opencode.jsonc` | npm module names, installed on start |
| Project settings | `<project>/opencode.jsonc` | |
| Project instructions | `<project>/AGENTS.md` | |

> opencode paths may change across versions. Run `opencode debug paths` for the global directories and
> `opencode debug config` for the resolved configuration of the installed version.

---

## Bundle Layout

### Claude Code bundle

```text
llm-config-export-<YYYYMMDD>/
├── export-manifest.json          # Path mapping + metadata (always present)
├── settings.json                 # Global settings
├── project-settings.json         # Project .claude/settings.json (renamed to avoid collision)
├── settings.local.json           # Project-local settings (if included)
├── CLAUDE.md                     # Global instructions
├── project-CLAUDE.md             # Project-level instructions (renamed to avoid collision)
├── installed_plugins.json        # Plugin registry (import reinstalls from it, never copies it)
├── known_marketplaces.json       # Marketplace sources (import reads the `source` fields only)
├── .mcp.json                     # Project MCP config
├── user-mcps.json                # {"mcpServers": {...}} extracted from ~/.claude.json
├── keybindings.json              # Key bindings
├── .credentials.json             # Opt-in only — auth tokens
├── skills/                       # Custom skills (directory copied verbatim)
│   └── <skill-name>/
│       └── SKILL.md
├── plans/
│   └── *.md
├── memories/
│   └── <project-slug>/           # Original slug preserved for restoration
│       └── *.md
└── tasks/
    └── <uuid>/
```

### opencode bundle

MCPs and plugins live inside `opencode.jsonc`, so the manifest's `mcps` and `plugins` point at that file.

```text
llm-config-export-<YYYYMMDD>/
├── export-manifest.json          # "tool": "opencode"
├── opencode.jsonc                # Global settings, incl. mcp and plugin keys
├── project-opencode.jsonc        # Project opencode.jsonc (renamed to avoid collision)
├── AGENTS.md                     # Global instructions
├── project-AGENTS.md             # Project-level instructions (renamed to avoid collision)
└── skills/
    └── <skill-name>/
        └── SKILL.md
```

---

## Restoring from Export

Use [llm-config-import](../llm-config-import/SKILL.md). It maps each bundle entry back to its target, backs up
what it overwrites, reinstalls plugins through the CLI instead of copying `installed_plugins.json`, and writes an
import report.

---

## What Not to Export

| File | Reason |
|---|---|
| `~/.claude/.credentials.json` | Auth tokens — rotate after any migration, never share |
| `~/.claude.json` (whole file) | Account state and per-project history — export only its `mcpServers` key |
| `~/.claude/history.jsonl` | Full conversation history — large and personal |
| `~/.claude/transcripts/` | Session transcripts |
| `~/.claude/session-env/` | Shell environment snapshots — meaningless on new machine |
| `~/.claude/plugins/cache/` | ~3K files — reinstallable from the plugin registry |
| `~/.claude/file-history/` | Per-file edit history — large, not portable |
| `~/.claude/paste-cache/` | Clipboard history |
| `~/.claude/shell-snapshots/` | Shell state — machine-specific |
