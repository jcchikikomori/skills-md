---
name: llm-config-export
description: Export Claude Code or opencode configuration (settings, plugins, MCPs, skills, memories, plans, tasks) to a portable bundle. Use when the user wants to back up, migrate, or share their AI assistant setup.
---

# LLM Config Export

Export Claude Code or opencode configuration into a portable snapshot for backup, migration, or sharing. Produces a manifest-first bundle so the export is reproducible even when file structures differ between machines.

## Phase 1: Discover

Probe what actually exists before assuming any path is present. A missing path is not an error — document it in `missing[]`.

### Claude Code — paths to check

```bash
# Core
~/.claude/settings.json
~/.claude/keybindings.json
~/.claude/CLAUDE.md

# Plugins
~/.claude/plugins/installed_plugins.json
~/.claude/plugins/data/

# User content
~/.claude/skills/
~/.claude/plans/
~/.claude/tasks/

# Memories (plugin-managed — path varies per project)
~/.claude/projects/*/memory/

# Project-local (run from the project root)
./.claude/settings.json
./.claude/settings.local.json
./.mcp.json
./CLAUDE.md
```

Use `test -e <path>` or `ls <path> 2>/dev/null` to check each. Collect all found paths into the manifest.

### Memory path pattern

Memory directories follow this encoding: absolute project path → replace `/` with `-` → strip leading `-home-<user>-`:

```
Project: /home/alice/Projects/my-app
Memory:  ~/.claude/projects/-home-alice-Projects-my-app/memory/
```

To find all memory locations:

```bash
find ~/.claude/projects -type d -name memory 2>/dev/null
```

### Detect the tool

```bash
which claude    # → claude-code
which opencode  # → opencode
```

Check `~/.claude/` for Claude Code, `~/.config/opencode/` or `~/.opencode/` for opencode.
See [reference.md](./reference.md) for opencode-specific paths.

## Phase 2: Generate Manifest

Write `export-manifest.json` to the destination directory **before copying anything**. This is the most important file — it maps original paths so the bundle can be restored correctly on a different machine.

```json
{
  "version": "1",
  "generated_at": "<ISO8601>",
  "tool": "claude-code",
  "paths": {
    "global_settings": "~/.claude/settings.json",
    "project_settings": [".claude/settings.json"],
    "instructions": ["~/.claude/CLAUDE.md", "CLAUDE.md"],
    "plugins": "~/.claude/plugins/installed_plugins.json",
    "mcps": [".mcp.json"],
    "skills": "~/.claude/skills/",
    "plans": "~/.claude/plans/",
    "memories": ["~/.claude/projects/-home-alice-Projects-my-app/memory/"],
    "tasks": "~/.claude/tasks/",
    "keybindings": "~/.claude/keybindings.json"
  },
  "missing": [],
  "sensitive_excluded": ["~/.claude/credentials.json"]
}
```

Null out any path not found. Memories not found → empty array `[]`.
Full schema in [reference.md → Manifest Schema](./reference.md#manifest-schema).

## Phase 3: Select & Configure

Present this default set and let the user override:

| Category | Default |
| --- | --- |
| Global settings (`settings.json`) | ✓ include |
| Project settings (`.claude/settings*.json`) | ✓ include |
| Custom instructions (`CLAUDE.md`) | ✓ include |
| Plugins registry | ✓ include |
| MCPs (`.mcp.json`) | ✓ include |
| Custom skills | ✓ include |
| Keybindings | ✓ include |
| Plans | ask user |
| Memories | ask user |
| Tasks | ask user |
| Credentials (`credentials.json`) | ✗ opt-in only |

If the user says "everything" or "all", include all except credentials.

## Phase 4: Export

Resolve the home directory first, then ask:

```bash
# Unix / macOS / WSL
echo "$HOME/Documents"

# Windows — PowerShell
echo $HOME\Documents
# Windows — cmd.exe fallback
echo %USERPROFILE%\Documents
```

> Note: `~` is not reliable on Windows cmd.exe. Always expand to the full path before showing the prompt. On Windows with OneDrive, `Documents` may resolve to `C:\Users\<user>\<organization> - OneDrive\Documents` — show the resolved path so the user can correct it.

Ask the user where to save the export before creating anything:

> "Where should the export be saved?
> (default: `<resolved-home>/Documents/llm-config-export-<YYYYMMDD>/`)"

Accept any absolute path the user provides. If they provide a directory without a trailing folder name, append `llm-config-export-<YYYYMMDD>/`. If they skip (empty input / "default"), use the resolved default.

Create destination only after the user confirms the path.

```
~/Documents/llm-config-export-20260617/
├── export-manifest.json          ← always first
├── settings.json
├── settings.local.json
├── CLAUDE.md
├── project-CLAUDE.md             ← project-level, renamed to avoid collision
├── installed_plugins.json
├── .mcp.json
├── keybindings.json
├── skills/                       ← copied verbatim
├── plans/
├── memories/
│   └── <project-slug>/           ← flattened from detected paths
└── tasks/
```

For memories at non-standard paths, flatten to `memories/<project-slug>/` and record the original path in the manifest so restoration can target the correct location.

To create a tarball after export:

```bash
tar -czf ~/Documents/llm-config-export-<date>.tar.gz ~/Documents/llm-config-export-<date>/
```

## Security

Never include by default — these require explicit opt-in:

| File | Why excluded |
| --- | --- |
| `~/.claude/credentials.json` | Auth tokens — rotate after migration, never share |
| `~/.claude/history.jsonl` | Full conversation history — large and personal |
| `~/.claude/transcripts/` | Session transcripts |
| `~/.claude/session-env/` | Shell environment snapshots — meaningless on new machine |
| `~/.claude/plugins/cache/` | ~3K files — reinstall from plugin registry |
| `~/.claude/file-history/` | Per-file edit history — large, not portable |

If the user explicitly requests credentials, warn: credentials.json contains auth tokens — only include for exports to systems you fully control and trust, and rotate the tokens afterward.

## See Also

- [reference.md](./reference.md) — full manifest JSON schema, opencode paths, restoration guide
