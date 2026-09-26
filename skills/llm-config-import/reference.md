# LLM Config Import — Reference

Mapping tables, shell helpers, translation rules, backup layout, and report template for [SKILL.md](./SKILL.md).

---

## Bundle → Target Mapping

The export manifest records only **original** paths. The bundle file names follow a fixed layout, so resolve each
bundle entry through this table. `~/.claude/` means `$CLAUDE_CONFIG_DIR` when set. `<oc>` means the opencode config
directory from `opencode debug paths` (fallback: `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/`). `<oc-config>` is
the config file that already exists there (`opencode.jsonc`, `opencode.json`, or legacy `config.json`).

### Claude Code bundle (`tool: "claude-code"`)

| Manifest key | Bundle entry | Claude Code target | opencode target |
| --- | --- | --- | --- |
| `global_settings` | `settings.json` | `~/.claude/settings.json` | translate keys → `<oc-config>` |
| `project_settings` | `project-settings.json` | `<project>/.claude/settings.json` | translate keys → `<project>/opencode.jsonc` |
| `project_settings` | `settings.local.json` | `<project>/.claude/settings.local.json` | skip — opencode has no gitignored local config |
| `instructions` | `CLAUDE.md` | `~/.claude/CLAUDE.md` | `<oc>/AGENTS.md` |
| `instructions` | `project-CLAUDE.md` | original path from `instructions[]` (`<project>/CLAUDE.md` or `<project>/.claude/CLAUDE.md`) | `<project>/AGENTS.md` |
| `plugins` | `installed_plugins.json` | reinstall via CLI — never copy | skip — no equivalent |
| `plugins` | `known_marketplaces.json` | read marketplace sources only — never copy | skip — no equivalent |
| `mcps` | `.mcp.json` | `<project>/.mcp.json` | translate → `mcp` key in `<project>/opencode.jsonc` |
| `mcps` | `user-mcps.json` | `import_user_mcp` per server | translate → `mcp` key in `<oc-config>` |
| `skills` | `skills/` | `~/.claude/skills/` | `<oc>/skills/` |
| `plans` | `plans/` | `~/.claude/plans/` | skip — no equivalent |
| `memories` | `memories/<slug>/` | `~/.claude/projects/<new-slug>/memory/` | skip — no auto-memory |
| `tasks` | `tasks/` | `~/.claude/tasks/` | skip — no equivalent |
| `keybindings` | `keybindings.json` | `~/.claude/keybindings.json` | skip — different keybind model |
| — (opt-in) | `.credentials.json` | `~/.claude/.credentials.json` (Linux/WSL), then `chmod 600` | skip — never translate credentials |

### opencode bundle (`tool: "opencode"`)

| Manifest key | Bundle entry | opencode target | Claude Code target |
| --- | --- | --- | --- |
| `global_settings` | `opencode.jsonc` | `<oc-config>` | translate keys → `~/.claude/settings.json` |
| `project_settings` | `project-opencode.jsonc` | `<project>/opencode.jsonc` | translate keys → `<project>/.claude/settings.json` |
| `instructions` | `AGENTS.md` | `<oc>/AGENTS.md` | `~/.claude/CLAUDE.md` |
| `instructions` | `project-AGENTS.md` | `<project>/AGENTS.md` | `<project>/CLAUDE.md` |
| `mcps` | `mcp` key in `opencode.jsonc` | restored with the config file | `import_user_mcp` per server (user scope) |
| `mcps` | `mcp` key in `project-opencode.jsonc` | restored with the config file | `<project>/.mcp.json` |
| `plugins` | `plugin` key in `opencode.jsonc` | restored with the config file | skip — npm modules, not Claude plugins |
| `skills` | `skills/` | `<oc>/skills/` | `~/.claude/skills/` |

### Legacy and unknown entries

The manifest has no exporter version, so detect a legacy bundle (exported before skills-md 1.4.0) by shape:

- `project_settings` lists `.claude/settings.json` but the bundle has no `project-settings.json`. Old exports had
  no separate name for it, so the bundle `settings.json` may be the **project** file. Show this in the plan and ask
  before restoring `settings.json` globally.
- `mcps` holds `~/.claude.json#mcpServers` but the bundle has no `user-mcps.json` → record "not in bundle".
- The bundle has `installed_plugins.json` but no `known_marketplaces.json` → only marketplaces declared in the
  bundle `settings.json` can be re-added.

Any bundle entry missing from both tables → skip with status "not imported (unknown)". A manifest path set to
`null` or listed in `missing[]` → nothing to import for that key.

---

## Executable Entries

Everything below runs code, changes where traffic goes, or loosens approval on the target machine. List each hit
in the plan's warning section.

- **Claude settings**: `hooks.*.command`, `statusLine.command`, `apiKeyHelper`, `awsAuthRefresh`,
  `awsCredentialExport`, `otelHeadersHelper`
- **Claude `env` overrides**: `ANTHROPIC_BASE_URL` (redirects all API traffic), `NODE_OPTIONS`, `*_PROXY`
- **Approval loosening**: `permissions.defaultMode: "bypassPermissions"`, `enableAllProjectMcpServers`,
  `enabledMcpjsonServers`
- **MCP servers**: stdio/local `command` and `args`, http/remote `url`
- **Plugins**: marketplace sources (`extraKnownMarketplaces`, `known_marketplaces.json`), plugin IDs
- **opencode**: `plugin[]` modules (npm packages installed on start), `formatter.*.command`, `lsp.*.command`
- **Skills**: script files inside imported skill directories, and `` !`command` `` shell injection in `SKILL.md`

---

## Memory Slug Derivation

Claude Code stores memories under a folder named after the project's absolute path, with every `/` replaced by
`-` (the home prefix stays):

```text
/home/alice/Projects/my-app  →  -home-alice-Projects-my-app
```

Paths with other punctuation (`.`, `_`, spaces) may be encoded differently. Derive two candidates and use the one
that already exists:

```bash
proj="/home/bob/Projects/my.app"
a="$(printf '%s' "$proj" | sed 's|/|-|g')"             # -home-bob-Projects-my.app
b="$(printf '%s' "$proj" | sed 's|[^A-Za-z0-9]|-|g')"  # -home-bob-Projects-my-app
ls -d ~/.claude/projects/"$a" ~/.claude/projects/"$b" 2>/dev/null
```

When neither exists, open Claude Code once in the project so it creates the folder, then import.

To remap a bundle slug onto the current machine:

1. Read the original memory path from the manifest `memories[]` entry whose slug matches the bundle folder name.
1. Derive the current home prefix: `printf '%s' "$HOME" | sed 's|/|-|g'` (for example `-home-bob`).
1. If the old slug starts with a different home prefix (`-home-alice-`, `-Users-alice-`), swap it for the current
   prefix. Show the candidate in the import plan.
1. If the project lives elsewhere on this machine, ask for its absolute path and derive the slug from that path.

```text
Bundle:  memories/-home-alice-Projects-my-app/
$HOME:   /home/bob
Target:  ~/.claude/projects/-home-bob-Projects-my-app/memory/
```

---

## Shell Helpers

Define these once per run, after setting `B` (backup root), `BUNDLE` (bundle directory), and `P` (target project
root, or empty). They are POSIX `sh` and `python3` only.

```bash
# Backup mirror path for a target: project/<rel>, home/<rel>, or abs/<absolute-path>
mirror() {
  case "$1" in
    "${P:-/dev/null/no-project}"/*) printf '%s/project/%s\n' "$B" "${1#"$P"/}" ;;
    "$HOME"/*) printf '%s/home/%s\n' "$B" "${1#"$HOME"/}" ;;
    *) printf '%s/abs%s\n' "$B" "$1" ;;
  esac
}

# Phase 4 only. Back up a target once per run; returns 0 when it is safe to write.
backup_one() {
  t="$1"; m="$(mirror "$t")"
  if [ -e "$m" ] || [ -L "$m" ]; then return 0; fi       # already backed up this run
  if [ ! -e "$t" ] && [ ! -L "$t" ]; then return 0; fi    # absent: action is create
  mkdir -p "$(dirname "$m")" && cp -a "$t" "$m" || return 1
  if [ -L "$t" ] || { [ -d "$t" ] && [ -n "$(find "$t" -type l -print -quit)" ]; }; then
    r="$B/resolved/${m#"$B"/}"                            # content behind the links
    mkdir -p "$(dirname "$r")" && cp -RL "$t" "$r" || return 1
  fi
}

# Overwrite or create one file. Plain cp writes through a symlinked target.
write_file() {  # write_file <source> <target>
  mkdir -p "$(dirname "$2")" && cp "$1" "$2"
}

# Replace each top-level entry of a bundle directory inside the target directory.
# Same-named entries are replaced, symlinked entries are written through, target-only entries stay.
write_entries() {  # write_entries <bundle-dir> <target-dir>
  mkdir -p "$2" || return 1
  for e in "$1"/* "$1"/.[!.]*; do
    [ -e "$e" ] || continue
    [ -L "$e" ] && continue                               # bundle symlinks are skipped
    d="$2/$(basename "$e")"
    if [ -L "$d" ] && [ -d "$d" ]; then cp -R "$e/." "$d/"
    elif [ -L "$d" ]; then cp "$e" "$d"
    else rm -rf "$d" && cp -a "$e" "$d"
    fi || return 1
  done
}

# Files a directory import will create. Run BEFORE writing; the report and rollback need the list.
list_created() {  # list_created <bundle-dir> <target-dir>
  (cd "$1" && find . -type f) | while IFS= read -r f; do
    [ -e "$2/${f#./}" ] || printf '%s\n' "$2/${f#./}"
  done
}

# User-scope MCP servers live in ~/.claude.json (inside $CLAUDE_CONFIG_DIR when that is set).
CJ="${CLAUDE_CONFIG_DIR:+$CLAUDE_CONFIG_DIR/.claude.json}"; CJ="${CJ:-$HOME/.claude.json}"

mcp_payload() {  # mcp_payload <file-with-mcpServers> <name>
  python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1]))["mcpServers"][sys.argv[2]]))' "$1" "$2"
}

has_user_mcp() {  # has_user_mcp <name>
  [ -f "$CJ" ] && python3 -c 'import json,sys; sys.exit(0 if sys.argv[2] in json.load(open(sys.argv[1])).get("mcpServers", {}) else 1)' "$CJ" "$1"
}

# Back up, replace, and on failure restore one user-scope MCP server. Fail-closed.
import_user_mcp() {  # import_user_mcp <name> <json>
  n="$1"; bk="$B/claude-mcp/$n.json"
  mkdir -p "$B/claude-mcp" || return 1
  if has_user_mcp "$n"; then
    mcp_payload "$CJ" "$n" > "$bk.tmp" && mv "$bk.tmp" "$bk" || return 1
    claude mcp remove "$n" -s user || return 1
  fi
  claude mcp add-json "$n" "$2" -s user && return 0
  [ -s "$bk" ] && claude mcp add-json "$n" "$(cat "$bk")" -s user   # put the old server back
  return 1
}

# One line per install: <id> <scope> <projectPath|->. Handles v1 (object) and v2 (list) registries.
list_plugins() {  # list_plugins <installed_plugins.json>
  python3 - "$1" <<'EOF'
import json, sys
for pid, v in json.load(open(sys.argv[1]))["plugins"].items():
    for e in (v if isinstance(v, list) else [v]):
        print(pid, e.get("scope", "user"), e.get("projectPath") or "-")
EOF
}

# Argument for `claude plugin marketplace add`, read from the bundle copies only. Empty output = unknown source.
market_source() {  # market_source <marketplace-name>
  python3 - "$BUNDLE" "$1" <<'EOF'
import json, os, sys
bundle, name = sys.argv[1:]
for f, key in (("settings.json", "extraKnownMarketplaces"), ("known_marketplaces.json", None)):
    p = os.path.join(bundle, f)
    if not os.path.exists(p):
        continue
    d = json.load(open(p))
    d = d.get(key, {}) if key else d
    if name in d:
        s = d[name].get("source", {})
        print(s.get("repo") or s.get("url") or s.get("path") or "")
        break
EOF
}

# Parse JSONC to plain JSON: strips // and /* */ comments and trailing commas outside strings.
load_jsonc() {  # load_jsonc <file>
  python3 - "$1" <<'EOF'
import json, re, sys
s = open(sys.argv[1]).read()
s = re.sub(r'("(?:\\.|[^"\\])*")|//[^\n]*|/\*.*?\*/|,(?=\s*[}\]])', lambda m: m.group(1) or "", s, flags=re.S)
print(json.dumps(json.loads(s), indent=2))
EOF
}
```

---

## Claude Plugin Reinstall

Never copy `installed_plugins.json`. Each entry holds an absolute `installPath` into `~/.claude/plugins/cache/` and
a commit SHA, which are machine state, not configuration. Reinstall from the plugin IDs instead.

1. Snapshot what is already installed. Rollback uninstalls only IDs missing from this snapshot:
   `claude plugin list --json > "$B/plugins-before.json"`.
1. List the installs in the bundle: `list_plugins "$BUNDLE/installed_plugins.json"`.
1. Skip, and report with the reason:
   - `managed` scope — admin-managed, not user config
   - IDs already in the snapshot — "already installed"
   - `project`/`local` installs whose `projectPath` is not the project the user named in Phase 2 — "other project"
1. For each marketplace in the remaining IDs (`<plugin>@<marketplace>`) that `claude plugin marketplace list` does
   not show yet:

   | Source (from `market_source`) | Command |
   | --- | --- |
   | `github` repo `owner/repo` | `claude plugin marketplace add owner/repo` |
   | `git` or `url` URL | `claude plugin marketplace add <url>` |
   | `directory` path | `claude plugin marketplace add <path>` — only if the path exists here, else skip |
   | `claude-plugins-official` | built in — no add needed |
   | empty output | skip its plugins — "marketplace source unknown" |

1. Install each plugin with its original scope: `claude plugin install <plugin>@<marketplace> -s <scope>`. Run
   `project` and `local` installs from inside the target project root.
1. The final `settings.json` write restores `enabledPlugins`, including disabled ones. When the user dropped
   `settings.json` from the plan, run `claude plugin disable <id> -s <scope>` for every entry set to `false`.

Rollback for a newly installed plugin: `claude plugin uninstall <plugin>@<marketplace> -s <scope>`.

---

## Claude User MCP Import

User-scope MCP servers live in `~/.claude.json` under `mcpServers`. That file also holds account state and
per-project history, so never overwrite or hand-edit it. The bundle's `user-mcps.json` has the same
`{"mcpServers": {...}}` shape as `.mcp.json`; each value is one `add-json` payload.

```bash
for n in $(python3 -c 'import json,sys; print(*json.load(open(sys.argv[1]))["mcpServers"])' "$BUNDLE/user-mcps.json"); do
  import_user_mcp "$n" "$(mcp_payload "$BUNDLE/user-mcps.json" "$n")" \
    && echo "reinstalled: $n" || echo "FAILED: $n (old server restored when one existed)"
done
```

`import_user_mcp` passes the payload through command substitution, so `${VAR}` references and single quotes inside
it stay intact. Rollback: `claude mcp remove <name> -s user`, then
`claude mcp add-json <name> "$(cat "$B/claude-mcp/<name>.json")" -s user`.

---

## Cross-Tool Translation

### Claude Code → opencode

Use the tables in `claudecode-migrate` — do not re-derive them:

- Settings keys, permission patterns, model IDs: `claudecode-migrate` reference → **Full Translation Tables**.
- MCP servers: `claudecode-migrate` reference → **MCP Server Translation Examples**.
- Instructions and `@imports`: `claudecode-migrate` SKILL.md → **CLAUDE.md → AGENTS.md**.
- Skill frontmatter fields opencode ignores: `claudecode-migrate` SKILL.md → **Skills & Commands**.

### opencode → Claude Code

The reverse of the `claudecode-migrate` tables.

#### Settings keys

Claude Code checks deny, then ask, then allow, no matter where a rule sits in the file. A catch-all `"*"` next to
specific patterns therefore needs care:

| opencode | Claude Code | Notes |
| --- | --- | --- |
| `permission.bash["git push *"]: "deny"` | `permissions.deny: ["Bash(git push:*)"]` | Replace the trailing space + `*` with `:*` |
| `permission.bash["*"]: "allow"` | `permissions.allow: ["Bash"]` | Specific deny rules still win in Claude |
| `permission.bash["*"]: "ask"` beside specific patterns | drop it | Claude already asks for unlisted commands; `ask: ["Bash"]` would override every allow |
| `permission.bash["*"]: "deny"` beside specific allows | report for manual review | Claude has no allow-over-deny; `deny: ["Bash"]` blocks everything |
| `permission.edit: "deny"` | `permissions.deny: ["Edit"]` | `Edit` covers the file-editing tools |
| `permission.webfetch: "ask"` | `permissions.ask: ["WebFetch"]` | |
| `permission.tool["*"]`, `permission.skill` | no equivalent | Skip, report — set `permissions.defaultMode` by hand |
| `model: "anthropic/<id>"` | `model: "<id>"` | Strip the provider prefix |
| `model` with another provider or `{env:…}` | no equivalent | Skip, report — Claude reads `ANTHROPIC_MODEL` from the environment |
| `{env:VAR}` in MCP fields | `${VAR}` | Claude expands variables only in MCP config (`command`, `args`, `env`, `url`, `headers`) |
| `{env:VAR}` anywhere else | no equivalent | Skip, report — `settings.json` values are literal |
| `{file:path}` | no equivalent | Skip, report — check the file for literal secrets |
| `provider`, `small_model`, `autoupdate`, `agent`, `plugin`, `formatter`, `lsp`, `$schema` | no equivalent | Skip, report |

#### MCP servers

| opencode | Claude Code |
| --- | --- |
| `type: "local"` | `type: "stdio"` |
| `type: "remote"` | `type: "http"` |
| `command: ["npx", "-y", "pkg"]` | `command: "npx"`, `args: ["-y", "pkg"]` |
| `environment: {...}` | `env: {...}` |
| `headers: {...}` | `headers: {...}` |
| `enabled: false` | skip the server, report "disabled in source" |
| `oauth: {...}` | drop — authenticate with `/mcp` after import |
| global config `mcp` | user scope via `import_user_mcp` |
| project config `mcp` | `<project>/.mcp.json` under `mcpServers` |

```jsonc
// opencode: opencode.jsonc → mcp
"sonarqube-mcp": {
  "type": "local",
  "command": ["docker", "run", "-i", "--rm", "mcp/sonarqube"],
  "environment": { "SONARQUBE_TOKEN": "{env:SONARQUBE_TOKEN}" },
  "enabled": true
}
```

```bash
# Claude Code equivalent
import_user_mcp sonarqube-mcp \
  '{"type":"stdio","command":"docker","args":["run","-i","--rm","mcp/sonarqube"],"env":{"SONARQUBE_TOKEN":"${SONARQUBE_TOKEN}"}}'
```

#### Instructions

- `AGENTS.md` → `CLAUDE.md` (same content).
- `instructions[]` → one `@path` line per file, appended to the translated `CLAUDE.md` in the same write.
- Expand globs (`docs/*.md`) into one line per matched file. Rewrite each path relative to the target `CLAUDE.md`.
- URLs have no `@import` equivalent — report them. Referenced files that are not in the bundle and do not exist on
  this machine — report them as missing.

### Partial overwrite rule

A translated config contains only the keys that have an equivalent. Replace **only those top-level keys** in the
target file, and keep every other key (for example opencode `provider`, Claude `statusLine`). Merge all translated
keys for one file into a single write. Parse the existing target with `load_jsonc`. Rewriting a JSONC file drops
its comments — the backup keeps them, and the report says so.

---

## Backup Layout

```text
llm-config-import-backup-<YYYYMMDD-HHMMSS>/     # mode 700
├── import-report.md
├── plugins-before.json       # `claude plugin list --json` snapshot
├── home/                     # exact copies (cp -a), mirrored relative to $HOME; symlinks kept as links
│   ├── .claude/settings.json
│   ├── .claude/CLAUDE.md     # a symlink, copied as a link (a relative link may dangle here)
│   └── .config/opencode/opencode.jsonc
├── project/                  # mirrored relative to the project root
│   └── .mcp.json
├── abs/                      # targets outside $HOME and the project, by absolute path
├── resolved/                 # dereferenced copies (cp -RL) of symlinks and of directories holding symlinks
│   └── home/.claude/CLAUDE.md
└── claude-mcp/               # add-json-ready copies of replaced user MCP servers
    └── <name>.json
```

---

## `import-report.md` Template

```markdown
# LLM Config Import Report

- **Generated:** <ISO8601>
- **Bundle:** `<bundle-path>` (tool: `<manifest.tool>`, exported: `<manifest.generated_at>`)
- **Target:** `<claude-code|opencode>` — direction: `<restore|translate>`
- **Project root:** `<path or none>`
- **Backup root:** `<backup-root>`

## Summary

| Action | Count |
| --- | --- |
| Overwritten | 0 |
| Created | 0 |
| Translated | 0 |
| Reinstalled | 0 |
| Skipped | 0 |

## Overwritten

| Target | Backup | Notes |
| --- | --- | --- |
| `~/.claude/settings.json` | `<backup-root>/home/.claude/settings.json` | |
| `~/.claude/CLAUDE.md` | `<backup-root>/home/.claude/CLAUDE.md`, `<backup-root>/resolved/home/.claude/CLAUDE.md` | symlink — wrote through to `<readlink -f path>` |

## Created

| Target (per file) | Source |
| --- | --- |

## Translated

| Source key | Target file → key | Notes |
| --- | --- | --- |

## Reinstalled

| Item | Command | Result |
| --- | --- | --- |

## Skipped

| Item | Reason |
| --- | --- |

## Executable Entries Imported

| Where | Command or value |
| --- | --- |

## Manual Follow-ups

- Rotate any imported credentials.
- Authenticate OAuth MCP servers (`/mcp` in Claude Code, `opencode mcp auth <name>` in opencode).
- Review orphaned memory files no longer listed in `MEMORY.md`.

## Verification

<command → result for each Phase 6 check>

## Rollback

<exact commands from the Rollback section, filled in with real paths>
```

---

## Rollback

```bash
B="<backup-root>"
cp -a "$B/home/." "$HOME/"                    # regular files and directories
cp -a "$B/project/." "<project-root>/"        # project-level files
# every symlinked target: restore the content through the link
cp "$B/resolved/home/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"      # file
write_entries "$B/resolved/home/.claude/skills" "$HOME/.claude/skills" # directory
```

- Use `write_entries` (Shell Helpers) for directories. Plain `cp -R` refuses to copy a directory onto a nested
  symlinked entry (`cannot overwrite non-directory … with directory`).
- `cp -a` restores backed-up entries but does not delete what the import **created**. Remove every file in the
  report's **Created** table by hand.
- Files under `abs/` go back to their absolute path (`abs/<path>` → `/<path>`).
- Plugins and MCP servers: run the rollback commands from the Claude Plugin Reinstall and Claude User MCP Import
  sections.
