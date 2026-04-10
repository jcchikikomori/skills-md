# skills-md

Personal skills repository for Claude Code and opencode. Each skill is a Markdown file loaded into the AI agent's context to guide behavior on specific languages, frameworks, or workflows.

## Project Structure

```text
<skill-name>/
├── SKILL.md       # Required — frontmatter + actionable guidance
└── reference.md   # Optional — extended reference material (tables, code examples)
```

One directory per skill. No nesting beyond this.

## SKILL.md Format

Every SKILL.md **must** start with YAML frontmatter:

```yaml
---
name: skill-name
description: One-line description of what the skill covers and when to use it.
---
```

Rules:

- `name` must match the directory name exactly (lowercase, hyphens only, max 64 chars)
- `description` max ~250 chars (truncated in context beyond that)
- No other frontmatter fields required for cross-platform compatibility

## Content Guidelines

- **Max ~500 lines** per SKILL.md — Claude Code's optimal budget. Extract detailed reference material (criterion tables, long code examples, roadmaps) to a `reference.md` supporting file and link to it at the bottom of SKILL.md.
- **No duplication.** If guidance already exists in another skill, reference it with a `## See Also` section rather than repeating it.
- **Framework-specific > generic.** Security sections in framework skills should cover only framework-specific points; generic OWASP guidance lives in the `owasp` skill.
- **No Docker commands** in framework skills — covered by global CLAUDE.md.

## Adding or Modifying Skills

1. **Plan first** — do not edit without a plan. Check if existing content covers the need.
2. Create directory: `mkdir <skill-name>`
3. Write `SKILL.md` with frontmatter + content
4. If content exceeds 500 lines, extract non-actionable reference material to `reference.md`
5. Add a `## See Also` section pointing to related skills

## Naming Conventions

| Pattern | Example |
| ------- | ------- |
| Language | `python`, `ruby`, `java`, `php` |
| Framework | `fastapi`, `ruby-on-rails`, `spring-boot` |
| Database | `postgresql`, `mysql-mariadb`, `oracle-sql` |
| Platform/Tool | `docker`, `kubernetes`, `git` |
| Concern | `owasp`, `web-accessibility`, `debug` |
| Architecture | `backend`, `frontend`, `fullstack` |

## Platform Compatibility

Both Claude Code and opencode use the same SKILL.md format. Avoid Claude Code-specific features if cross-platform compatibility matters:

- No shell injection syntax (`` !`command` ``)
- No `context: fork`, `agent`, `argument-hint` frontmatter fields

## Current Skills Inventory

34 skills across: languages (python, ruby, java, php, nodejs), frameworks (fastapi, ruby-on-rails, spring-boot, grails, reactjs, vuejs, angularjs), databases (postgresql, mysql-mariadb, oracle-sql), ORMs (sqlalchemy, pydantic, rails-migration), architecture (backend, frontend, fullstack), infrastructure (docker, kubernetes, git), security/quality (owasp, web-accessibility, web-audit), mobile (android), and workflow (debug, docu-component, what-is-this, shared-templates).
