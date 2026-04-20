---
name: markdown
description: Markdown writing standards, auto-formatting via MCP tools (markitdown, linter), and verification workflow for .md and .mdx files.
---

# Markdown Skill

**Load this skill** when reading, editing, or verifying any `.md` or `.mdx` file.

## MCP Tools Workflow

Run this sequence automatically — do not wait for user to ask:

### 1. Converting Non-Markdown Source → `.md`

If converting a file (HTML, PDF, DOCX, etc.) to markdown:

```
call mcp__markitdown-mcp__convert_to_markdown with the source file path
```

Use the MCP output as the base; then apply writing standards below.

### 2. After Writing or Editing a Markdown File

If `mcp__markitdown-mcp__convert_to_markdown` is available, run a format pass on the final file before delivering output. Treat the result as the canonical version.

### 3. Linting Embedded Code Blocks

If the markdown contains fenced code blocks and `mcp__sonarqube-mcp__analyze_code_snippet` is available, run it on each block with a named language. Report issues inline as comments or in a summary below the edit.

---

## Writing Standards

### Structure

- **One H1 per file** — the document title only.
- **No skipped heading levels** — H2 → H3 → H4 in order; never jump H2 → H4.
- **ATX-style headings only** (`#`, `##`, `###`) — never underline style (`===`, `---`).
- Blank line **before and after** every heading, list, code block, and table.

### Lists

- Unordered: use `-` (not `*` or `+`) for consistency.
- Ordered: always use `1.` — renderer auto-numbers.
- Nested lists: 2-space indent per level.
- No blank lines between simple list items; blank lines only when items contain multiple paragraphs.

### Code Blocks

- Always fenced (` ``` `), never indented.
- Always specify language tag: ` ```python `, ` ```bash `, ` ```yaml `, etc.
- Use `text` for plain output, `console` for terminal sessions.

### Tables

- Pipe-aligned headers and separator row must match column count.
- At least one space padding inside each cell: `| value |` not `|value|`.
- Separator row uses dashes only: `| --- | --- |`.

### Links and Images

- Link text must be descriptive — no "click here", "here", or bare URLs in prose.
- Relative links for files in the same repo; absolute for external.
- Images: always include alt text `![descriptive alt](path)`.

### Prose

- Max **120 characters** per line for prose paragraphs (soft wrap OK in editors).
- No limit inside code blocks or tables.
- One blank line between paragraphs; never two consecutive blank lines outside special blocks.

### Emphasis

- `**bold**` for critical terms, UI labels, warnings.
- `_italic_` for titles, first use of a term, light emphasis.
- `` `backtick` `` for inline code, file paths, CLI flags, and env vars.

---

## Edit Workflow

1. **Read** the target file fully before making any change.
2. **Apply** edits following writing standards above.
3. **Format pass** — if markitdown MCP available, call it and reconcile output.
4. **Verify**:
   - Heading hierarchy correct (no skipped levels)
   - All code blocks have a language tag
   - No bare URLs in prose
   - Tables have matching column counts
   - Blank lines present before/after block-level elements

---

## See Also

- `shared-templates` — output format templates for agent responses
- `docu-component` — structured documentation for components and classes
