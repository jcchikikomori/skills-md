---
name: license
description: Choose and generate a software LICENSE file from choosealicense.com data — decision guide, verbatim text fetch, placeholder fill, SPDX manifest sync. Use when adding, picking, or changing a project's license.
---

# License Skill (choosealicense.com)

**Source of truth:** [choosealicense.com](https://choosealicense.com/), built from
[github/choosealicense.com](https://github.com/github/choosealicense.com). The same data feeds
GitHub's license picker and the `GET /licenses` API.

Pick a license with the user, fetch its **verbatim** text, fill the placeholders, write `LICENSE`,
and keep manifest `license` fields in sync. Comparison table and manifest syntax live in
[reference.md](reference.md).

## Rules

- **Never write license text from memory.** Legal text has to be byte-exact; a "close enough" GPL
  is not the GPL. Always fetch it (Phase 3). If every fetch fails, stop and tell the user.
- **Never relicense silently.** If a `LICENSE`/`COPYING` already exists or a manifest declares a
  license, confirm before replacing it. Relicensing code with outside contributors usually needs
  their consent.
- **Not legal advice.** Say so once when recommending, then move on. No disclaimers on every line.
- **The user picks.** Recommend one option first, but the copyright holder decides.

## Phase 1: Detect

Gather facts before asking anything.

```bash
# Existing license files
ls -1 | grep -iE '^(licen[cs]e|copying|unlicense)'

# Manifest license fields
grep -s '"license"' package.json composer.json
grep -s -E '^\s*license' pyproject.toml Cargo.toml *.gemspec
grep -s -A3 '<licenses>' pom.xml
grep -s 'PackageLicenseExpression' *.csproj

# Copyright holder + year
git config user.name
git log --reverse --format=%ad --date=format:%Y | head -1   # first-commit year
date +%Y
```

Also note the ecosystem (npm, Cargo, PyPI, RubyGems, Maven, NuGet). It shapes the default.

## Phase 2: Choose

choosealicense.com starts from three questions. Use them as the front door:

| The user wants... | Recommend | Why |
| ----------------- | --------- | --- |
| Simple and permissive, minimal fuss | `MIT` | Short, widely understood; only asks to keep the notice |
| Permissive, but patents matter | `Apache-2.0` | Explicit patent grant + patent-retaliation clause |
| Improvements must stay open (share-alike) | `GPL-3.0` | Copyleft: distributed derivatives must ship source under GPL |

Then refine:

- **Network service** (SaaS, web app) and they want copyleft → `AGPL-3.0`. Plain GPL does not
  trigger on network use; AGPL does ("network use is distribution").
- **Library**, wants copyleft on the library but lets apps link freely → `LGPL-3.0` or `MPL-2.0`
  (file-level copyleft, simpler to comply with).
- **Rust crate** → `MIT OR Apache-2.0` (ecosystem convention, two files — see Phase 5).
- **Public-domain-like** → `Unlicense` or `CC0-1.0` for code; `0BSD`/`MIT-0` if they want a
  permissive license with no attribution requirement.
- **Not software** (docs, media, datasets) → `CC-BY-4.0`, `CC-BY-SA-4.0`, `ODbL-1.0`. Creative
  Commons does not recommend CC licenses for code, except CC0.
- **Contributing to an existing project** → use that project's license. No choice to make.
- **No license at all** → valid, but means all rights reserved: others cannot legally use, copy,
  or modify the code. Say this plainly if the user picks it.

Ask with `AskUserQuestion` when the request does not settle it. Put the recommended option first
with "(Recommended)", one line per option on what it obliges downstream users to do.

All 47 choosealicense licenses, with patent grants and conditions, are in
[reference.md](reference.md#comparison-table).

## Phase 3: Fetch the verbatim text

The license id in the URL is the **lowercase** choosealicense key (`mit`, `apache-2.0`, `gpl-3.0`,
`bsd-3-clause`). Each file is YAML frontmatter, a `---` line, then the license text.

```bash
KEY=mit
curl -fsSL "https://raw.githubusercontent.com/github/choosealicense.com/gh-pages/_licenses/${KEY}.txt" \
  -o /tmp/license-src.txt

# Body = everything after the second '---', minus the leading blank line
awk 'f>=2 && (NF || seen++){print} /^---$/{f++}' /tmp/license-src.txt > LICENSE

# Frontmatter is worth reading: `how:` says exactly what to replace, `note:` lists extra steps
sed -n '2,/^---$/p' /tmp/license-src.txt | grep -E '^(title|spdx-id|how|note):'
```

Fallback when raw.githubusercontent.com is blocked — GitHub's licenses API (same data, 13 keys:
`agpl-3.0 apache-2.0 bsd-2-clause bsd-3-clause bsl-1.0 cc0-1.0 epl-2.0 gpl-2.0 gpl-3.0 lgpl-2.1 mit mpl-2.0 unlicense`):

```bash
gh api "/licenses/${KEY}" --jq .body > LICENSE
# or without gh:
curl -fsSL "https://api.github.com/licenses/${KEY}" | jq -r .body > LICENSE
```

If both fail, stop. Do not reconstruct the text.

## Phase 4: Fill placeholders

Only these bracket tokens are placeholders in choosealicense texts:

| Token | Replace with | Appears in |
| ----- | ------------ | ---------- |
| `[year]` | Current year, or `first-current` range (e.g. `2023-2026`) | MIT, BSD-*, ISC, 0BSD, MIT-0, Zlib, UPL, PostgreSQL, NCSA, OFL |
| `[fullname]` | Copyright holder: person or organization (names as given) | Same as `[year]` |
| `[project]` | Project name | BSD-4-Clause, NCSA, Vim |
| `[projecturl]` | Project homepage or repo URL | NCSA |
| `[email]` | Contact email for the holder | OFL-1.1 |

```bash
sed -i -e "s|\[year\]|2026|g" -e "s|\[fullname\]|Jane Doe|g" LICENSE
```

Escape `&`, `|`, and `\` in the values before using `sed`, or make the edit with the Edit tool.

**Gotchas:**

- **Apache-2.0 and ECL-2.0 have no placeholders in the license body.** The appendix line
  `Copyright [yyyy] [name of copyright owner]` is a template for the per-file header notice,
  so it must stay untouched. Leaving it as-is is correct; filling it in alters the license text.
  Put the copyright line in a `NOTICE` file or file headers instead, if wanted.
- **GPL/LGPL/AGPL have no bracket placeholders either.** Their `<year>  <name of author>` lines sit
  inside "How to Apply These Terms", which is instructions, not the license. Leave them.
- **Which holder?** For work done for an employer, the holder is usually the employer, not the
  developer. Ask instead of defaulting to `git config user.name` when it looks like company code.
- Year: choosealicense says "current year". A range from the first-commit year is also common;
  offer it when the repo predates this year.

## Phase 5: Write and sync

1. **File name:** `LICENSE` at the repo root (GitHub detects `LICENSE`, `LICENSE.md`,
   `LICENSE.txt`, `COPYING`). GNU projects traditionally use `COPYING`; use it only if the user asks.
1. **Dual license** (`MIT OR Apache-2.0`): write `LICENSE-MIT` and `LICENSE-APACHE`, no single
   `LICENSE`. Mention both in the README.
1. **Manifest fields:** set the SPDX expression in every manifest found in Phase 1. Syntax per
   ecosystem is in [reference.md](reference.md#manifest-fields).
   - Use **current** SPDX ids in manifests: `GPL-3.0-only` or `GPL-3.0-or-later`, not `GPL-3.0`
     (deprecated; npm warns). Same for `GPL-2.0`, `LGPL-2.1`, `LGPL-3.0`, `AGPL-3.0`, `GFDL-1.3`.
     Ask which one; the FSF's own header text means "or later".
   - choosealicense's `spdx-id` frontmatter uses the old short form — do not copy it blindly.
1. **README:** update a `## License` section only if one exists; otherwise offer one line
   (`Licensed under the [MIT License](LICENSE).`). No badge unless the README already has badges.
1. **Extra steps from `note:`** — apply only if the user wants them:
   - GPL family / Apache-2.0: recommended per-file header notice.
   - Apache-2.0: optional `NOTICE` file for attribution.

## Verify

```bash
# 1. No leftover placeholders (Apache/ECL appendix [yyyy] is expected and fine)
grep -nE '\[(year|fullname|project|projecturl|email)\]' LICENSE && echo "unfilled placeholder"

# 2. Only placeholder lines differ from the fetched source
diff <(awk 'f>=2 && (NF || seen++){print} /^---$/{f++}' /tmp/license-src.txt) LICENSE

# 3. Manifest agrees with the file
grep -s '"license"' package.json
```

Expected `diff` output: only the copyright line(s). Anything else means the text was altered.

## See Also

- [reference.md](reference.md) — all 47 licenses compared, manifest field syntax, SPDX notes
- `git` — staging the new `LICENSE` (the user commits)
- `markdown` — README License section formatting
- `what-is-this` — detecting ecosystem/manifests in an unfamiliar repo
