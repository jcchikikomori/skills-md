# License Reference

Supporting tables for the `license` skill. Data generated from
[github/choosealicense.com](https://github.com/github/choosealicense.com) `_licenses/*.txt` and
`_data/rules.yml` (47 licenses, October 2026). Re-check upstream if a license looks missing.

## Comparison Table

Every license here permits commercial use, modification, distribution, and private use, and
(unless noted) disclaims warranty and liability. The columns show what differs.

- **Patent grant** — `yes`: license grants patent rights. `no (explicit)`: license says it grants
  none (riskier for users than silence).
- **Conditions** — what downstream users must do:
  - `notice`: keep the license and copyright notice (`(source only)`: binaries are exempt).
  - `state changes`: mark modified files.
  - `disclose source`: ship source when distributing.
  - `network = distribution`: offering it over a network counts as distributing (AGPL-style).
  - `same license`: derivatives use the same license; `(file)` / `(library)` narrow the scope.
- **Extra limits** — trademark rights explicitly not granted.

The choosealicense key (used in fetch URLs) is the SPDX id in lowercase, e.g. `BSD-3-Clause` →
`bsd-3-clause`.

| SPDX id | Patent grant | Conditions | Extra limits |
| ------- | ------------ | ---------- | ------------ |
| `0BSD` | no | — | — |
| `AFL-3.0` | yes | notice, state changes | trademark |
| `AGPL-3.0` | yes | notice, state changes, disclose source, network = distribution, same license | — |
| `Apache-2.0` | yes | notice, state changes | trademark |
| `Artistic-2.0` | yes | notice, state changes | trademark |
| `BlueOak-1.0.0` | yes | notice | — |
| `BSD-2-Clause-Patent` | yes | notice | — |
| `BSD-2-Clause` | no | notice | — |
| `BSD-3-Clause-Clear` | **no (explicit)** | notice | — |
| `BSD-3-Clause` | no | notice | — |
| `BSD-4-Clause` | no | notice | — |
| `BSL-1.0` | no | notice (source only) | — |
| `CC-BY-4.0` | **no (explicit)** | notice, state changes | trademark |
| `CC-BY-SA-4.0` | **no (explicit)** | notice, state changes, same license | trademark |
| `CC0-1.0` | **no (explicit)** | — | trademark |
| `CECILL-2.1` | yes | notice, network = distribution, disclose source, same license | — |
| `CERN-OHL-P-2.0` | yes | notice, state changes | — |
| `CERN-OHL-S-2.0` | yes | notice, state changes, disclose source, same license | — |
| `CERN-OHL-W-2.0` | yes | notice, state changes, disclose source, same license (library) | — |
| `ECL-2.0` | yes | notice, state changes | trademark |
| `EPL-1.0` | yes | disclose source, notice, same license | — |
| `EPL-2.0` | yes | disclose source, notice, same license | — |
| `EUPL-1.1` | yes | notice, disclose source, state changes, network = distribution, same license | trademark |
| `EUPL-1.2` | yes | notice, disclose source, state changes, network = distribution, same license | trademark |
| `GFDL-1.3` | no | notice, disclose source, same license, state changes | — |
| `GPL-2.0` | no | notice, state changes, disclose source, same license | — |
| `GPL-3.0` | yes | notice, state changes, disclose source, same license | — |
| `ISC` | no | notice | — |
| `LGPL-2.1` | no | notice, disclose source, state changes, same license (library) | — |
| `LGPL-3.0` | yes | notice, disclose source, state changes, same license (library) | — |
| `LPPL-1.3c` | no | notice, state changes, disclose source | — |
| `MIT-0` | no | — | — |
| `MIT` | no | notice | — |
| `MPL-2.0` | yes | disclose source, notice, same license (file) | trademark |
| `MS-PL` | yes | notice | trademark |
| `MS-RL` | yes | disclose source, notice, same license (file) | trademark |
| `MulanPSL-2.0` | yes | notice | trademark |
| `NCSA` | no | notice | — |
| `ODbL-1.0` | **no (explicit)** | disclose source, notice, same license | trademark |
| `OFL-1.1` | no | notice, same license | — |
| `OSL-3.0` | yes | notice, disclose source, state changes, network = distribution, same license | trademark |
| `PostgreSQL` | no | notice | — |
| `Unlicense` | no | — | — |
| `UPL-1.0` | yes | notice | — |
| `Vim` | no | notice, state changes, disclose source, same license | no warranty/liability disclaimer |
| `WTFPL` | no | — | no warranty/liability disclaimer |
| `Zlib` | no | notice (source only), state changes | — |

### Quick families

| Family | Licenses |
| ------ | -------- |
| Permissive, short | `MIT`, `ISC`, `BSD-2-Clause`, `BSD-3-Clause`, `0BSD`, `MIT-0`, `Zlib`, `BSL-1.0` |
| Permissive + patent grant | `Apache-2.0`, `BSD-2-Clause-Patent`, `UPL-1.0`, `BlueOak-1.0.0`, `MS-PL` |
| Weak copyleft (file/library) | `MPL-2.0`, `LGPL-2.1`, `LGPL-3.0`, `EPL-2.0`, `MS-RL` |
| Strong copyleft | `GPL-2.0`, `GPL-3.0` |
| Network copyleft | `AGPL-3.0`, `EUPL-1.2`, `OSL-3.0` |
| Public domain dedication | `Unlicense`, `CC0-1.0` |
| Non-software | `CC-BY-4.0`, `CC-BY-SA-4.0`, `OFL-1.1` (fonts), `ODbL-1.0` (data), `GFDL-1.3` (docs) |
| Hardware | `CERN-OHL-P-2.0`, `CERN-OHL-W-2.0`, `CERN-OHL-S-2.0` |

## Manifest Fields

Use an [SPDX license expression](https://spdx.org/licenses/): a single id, or `A OR B` / `A AND B`.

| Ecosystem | File | Syntax |
| --------- | ---- | ------ |
| npm | `package.json` | `"license": "MIT"` |
| PyPI (PEP 639) | `pyproject.toml` | `license = "MIT"` + `license-files = ["LICENSE"]` under `[project]` |
| PyPI (legacy) | `pyproject.toml` | `license = { text = "MIT" }` — only for build backends without PEP 639 support |
| Cargo | `Cargo.toml` | `license = "MIT OR Apache-2.0"` under `[package]` |
| RubyGems | `*.gemspec` | `spec.license = "MIT"` (or `spec.licenses = ["MIT", "Apache-2.0"]`) |
| Composer | `composer.json` | `"license": "MIT"` (or `["MIT", "GPL-3.0-or-later"]` for OR) |
| Maven | `pom.xml` | `<licenses><license><name>MIT</name><url>https://spdx.org/licenses/MIT.html</url></license></licenses>` |
| NuGet | `*.csproj` | `<PackageLicenseExpression>MIT</PackageLicenseExpression>` |
| Go | — | No field; pkg.go.dev reads the `LICENSE` file |

## SPDX Id Notes

choosealicense frontmatter uses older short ids for GNU licenses. Those are **deprecated** in
the SPDX list. Use the current form in manifests:

| choosealicense `spdx-id` | Current SPDX ids |
| ------------------------ | ---------------- |
| `GPL-2.0` | `GPL-2.0-only`, `GPL-2.0-or-later` |
| `GPL-3.0` | `GPL-3.0-only`, `GPL-3.0-or-later` |
| `LGPL-2.1` | `LGPL-2.1-only`, `LGPL-2.1-or-later` |
| `LGPL-3.0` | `LGPL-3.0-only`, `LGPL-3.0-or-later` |
| `AGPL-3.0` | `AGPL-3.0-only`, `AGPL-3.0-or-later` |
| `GFDL-1.3` | `GFDL-1.3-only`, `GFDL-1.3-or-later` |

`-or-later` matches the FSF's recommended header ("either version 3 of the License, or (at your
option) any later version"). `-only` drops that clause, so pick it only on purpose.
