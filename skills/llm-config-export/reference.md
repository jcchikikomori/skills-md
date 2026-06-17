# LLM Config Export — Reference

Extended schemas, path tables, and restoration guide for [SKILL.md](./SKILL.md).

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
| Plugin data | `~/.claude/plugins/data/*.json` | lightweight per-plugin metadata |
| Custom skills | `~/.claude/skills/` | user-created SKILL.md files |
| Keybindings | `~/.claude/keybindings.json` | custom key bindings |
| Plans | `~/.claude/plans/*.md` | auto-named plan files |
| Tasks | `~/.claude/tasks/<uuid>/` | task state directories |
| Memories (remember plugin) | `~/.claude/projects/<project-slug>/memory/` | per-project memory files |
| MCPs (embedded) | `~/.claude/settings.json` → `mcpServers` key | global MCP server definitions |
| MCPs (project) | `<project>/.mcp.json` | project-local MCP config |

### Memory slug encoding

The `<project-slug>` in memory paths is derived from the project's absolute path:

1. Take the absolute path: `/home/alice/Projects/my-app`
2. Replace every `/` with `-`: `-home-alice-Projects-my-app`

So memory lives at: `~/.claude/projects/-home-alice-Projects-my-app/memory/`

When restoring on a new machine with a different username or path, update the slug accordingly or re-initialize the memory directory under the new path.

---

## opencode Paths

opencode follows XDG Base Directory conventions:

| Item | Path | Notes |
|---|---|---|
| Config root | `$XDG_CONFIG_HOME/opencode/` | defaults to `~/.config/opencode/` |
| Alt config root | `~/.opencode/` | used if XDG not set |
| Main settings | `~/.config/opencode/config.json` | |
| Instructions | `~/.config/opencode/instructions.md` | global custom instructions |
| Skills | same SKILL.md format, location varies | run `opencode config show` |
| MCPs | `~/.config/opencode/mcp.json` or embedded in config | |
| Project instructions | `<project>/CLAUDE.md` | shared format with Claude Code |

> opencode paths may change across versions. Run `opencode config show` or `opencode --help` for authoritative paths for the installed version.

---

## Bundle Layout

```
llm-config-export-<YYYYMMDD>/
├── export-manifest.json          # Path mapping + metadata (always present)
├── settings.json                 # Global settings
├── settings.local.json           # Project-local settings (if included)
├── CLAUDE.md                     # Global instructions
├── project-CLAUDE.md             # Project-level instructions (renamed to avoid collision)
├── installed_plugins.json        # Plugin registry
├── .mcp.json                     # MCP config
├── keybindings.json              # Key bindings
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

---

## Restoring from Export

1. Read `export-manifest.json` to find original paths for each item.
2. Copy files back to their source paths (or the equivalent on the new machine).
3. **Memories**: restore to `~/.claude/projects/<project-slug>/memory/` — create the directory if it doesn't exist. If the project path changed (different username or location), re-derive the slug from the new absolute path.
4. **Plugins**: restore `installed_plugins.json`, then run `claude plugins sync` (or equivalent) to reinstall from the registry. The plugin cache is not included in the export — it will be rebuilt on first use.
5. **MCPs**: confirm server paths, URLs, and credentials are still valid on the destination machine before restoring `.mcp.json`.
6. **Settings with credentials**: `settings.json` may reference MCP auth tokens or API keys in the `env` section. Review before restoring.

---

## What Not to Export

| File | Reason |
|---|---|
| `~/.claude/credentials.json` | Auth tokens — rotate after any migration, never share |
| `~/.claude/history.jsonl` | Full conversation history — large and personal |
| `~/.claude/transcripts/` | Session transcripts |
| `~/.claude/session-env/` | Shell environment snapshots — meaningless on new machine |
| `~/.claude/plugins/cache/` | ~3K files — reinstallable from the plugin registry |
| `~/.claude/file-history/` | Per-file edit history — large, not portable |
| `~/.claude/paste-cache/` | Clipboard history |
| `~/.claude/shell-snapshots/` | Shell state — machine-specific |
