---
name: web-accessibility
description: WCAG 2.2 implementation guide covering POUR principles, AA/AAA conformance, ARIA, keyboard navigation, assistive-tech testing, and the EAA/ADA conformance deadlines. Use when building or auditing accessible UI.
---

# Web Accessibility Skill

WCAG 2.2 is the current W3C Recommendation (**12 December 2024**; first published October 2023). Target: **AA minimum**, AAA where feasible.

WCAG 3.0 is a Working Draft, not a conformance target — see [WCAG 3.0 Watch](#wcag-30-watch) below.

## POUR Principles

| Principle | Key Requirement |
| ----------- | ---------------- |
| **Perceivable** | Text alternatives, captions, adaptable layout, sufficient contrast |
| **Operable** | Keyboard accessible, enough time, no seizure triggers, navigable |
| **Understandable** | Readable, predictable, input assistance |
| **Robust** | Compatible with current and future assistive technologies |

## Conformance Levels

| Level | Contrast | Target Size | Notes |
| ------- | ---------- | ------------- | ------- |
| **A** | — | — | Minimum; covers semantic HTML, keyboard, alt text |
| **AA** | 4.5:1 text / 3:1 UI | 24x24px | **Required minimum** |
| **AAA** | 7:1 text / 4.5:1 large | 44x44px | Preferred goal |

## Which Standard Applies

| Jurisdiction / Scope | Standard | WCAG Level | Deadline |
| ---------------------- | ---------- | ------------ | ---------- |
| EU private sector, consumer-facing (EAA) | EN 301 549 v4.1.1 | 2.2 AA | Enforceable since 28 Jun 2025 |
| EU public sector (Web Accessibility Directive) | EN 301 549 | 2.1 AA (2.2 AA in v4.1.1) | In force |
| US state/local gov — large entities (ADA Title II) | DOJ web rule | 2.1 AA | 26 Apr 2027 |
| US state/local gov — small & special district (ADA Title II) | DOJ web rule | 2.1 AA | 26 Apr 2028 |
| US federal (Section 508) | 508 refresh | 2.0 AA baseline | In force |

> Build to **WCAG 2.2 AA everywhere**. It is a superset of 2.1 AA, so one target satisfies the ADA Title II bar too.

## Pre-Launch AA Checklist

- [ ] Automated tests pass (`axe`, Lighthouse)
- [ ] All interactive elements reachable via keyboard; no keyboard traps
- [ ] Focus indicators visible and logical tab order
- [ ] Color contrast verified (4.5:1 text, 3:1 UI components)
- [ ] Screen reader tested (NVDA or VoiceOver)
- [ ] Text resizable to 200% without loss of content
- [ ] Images have descriptive `alt` text; decorative images use `alt=""`
- [ ] Form labels associated with inputs; errors linked to fields
- [ ] Skip link implemented (`<a href="#main-content">`)
- [ ] Page titles are descriptive
- [ ] Videos have captions
- [ ] Target size minimum 24x24px
- [ ] Focused element not completely hidden behind sticky headers

## AAA Enhancements

- [ ] Contrast ratio 7:1 for body text
- [ ] Target size 44x44px
- [ ] Focus appearance: 3px outline meeting contrast requirements
- [ ] No cognitive test for authentication (allow paste, password managers)
- [ ] Motion animations can be disabled (`prefers-reduced-motion`)
- [ ] Location information (breadcrumbs/sitemap)

## ARIA

ARIA 1.2 is the stable W3C Recommendation; ARIA 1.3 is still a Working Draft. Author against **1.2 plus the [ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)**.

First rule of ARIA: use native HTML semantics (`<button>`, `<nav>`, `<dialog>`) before reaching for a role. A wrong role is worse than no role.

## Testing Tools

| Tool | Type | Use When |
| ------ | ------ | ---------- |
| **axe DevTools** | Browser extension | Developer testing |
| **WAVE** | Browser extension | Quick visual check |
| **jest-axe** | Testing library | Unit/component tests |
| **@axe-core/playwright** | E2E runner | Full-page scans in CI |
| **Lighthouse CI** / **Pa11y CI** | Pipeline gate | Block regressions on PR |
| **NVDA** / **VoiceOver** | Screen reader | Manual AT testing |

Automated tools catch roughly a third of issues. Keyboard and screen-reader passes stay manual.

## WCAG 2.2 New Criteria

| Criterion | Level | Description |
| ----------- | ------- | ------------- |
| **2.4.11** Focus Not Obscured (Minimum) | AA | Focused element not completely hidden |
| **2.4.12** Focus Not Obscured (Enhanced) | AAA | No part of focused element hidden |
| **2.4.13** Focus Appearance | AAA | Focus indicator size/contrast requirements |
| **2.5.7** Dragging Movements | AA | Dragging has single-pointer alternative |
| **2.5.8** Target Size (Minimum) | AA | Targets at least 24x24 CSS pixels |
| **3.2.6** Consistent Help | A | Help in same location across pages |
| **3.3.7** Redundant Entry | A | Previously entered info auto-populated |
| **3.3.8** Accessible Authentication (Minimum) | AA | No cognitive test or provide alternative |
| **3.3.9** Accessible Authentication (Enhanced) | AAA | No cognitive test, no exceptions |

WCAG 2.2 also **removed 4.1.1 Parsing**. Do not report it as a finding.

## WCAG 3.0 Watch

- Latest [Working Draft: September 2026](https://www.w3.org/WAI/news/2026-09-10/wcag3/).
- Replaces A/AA/AAA with outcome-based requirements and assertions.
- Candidate Recommendation expected ~Q4 2027; Recommendation not before 2028.
- **Do not build to it.** No regulation references it. A solid 2.2 AA program carries forward.

> Full WCAG 2.2 criterion reference, conformance and regulation detail, implementation patterns, and test protocols: [reference.md](./reference.md)
