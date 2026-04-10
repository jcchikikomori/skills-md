---
name: web-accessibility
description: WCAG 2.2 standards implementation guide. Covers POUR principles, AA/AAA conformance, ARIA, keyboard navigation, and assistive technology testing.
---

# Web Accessibility Skill

WCAG 2.2 is the current W3C recommendation (October 2023). Target: **AA minimum**, AAA where feasible.

## POUR Principles

| Principle | Key Requirement |
|-----------|----------------|
| **Perceivable** | Text alternatives, captions, adaptable layout, sufficient contrast |
| **Operable** | Keyboard accessible, enough time, no seizure triggers, navigable |
| **Understandable** | Readable, predictable, input assistance |
| **Robust** | Compatible with current and future assistive technologies |

## Conformance Levels

| Level | Contrast | Target Size | Notes |
|-------|----------|-------------|-------|
| **A** | — | — | Minimum; covers semantic HTML, keyboard, alt text |
| **AA** | 4.5:1 text / 3:1 UI | 24x24px | **Required minimum** |
| **AAA** | 7:1 text / 4.5:1 large | 44x44px | Preferred goal |

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

## Testing Tools

| Tool | Type | Use When |
|------|------|----------|
| **axe DevTools** | Browser extension | Developer testing |
| **WAVE** | Browser extension | Quick visual check |
| **Lighthouse** | Chrome DevTools / CI | Automated pipeline |
| **jest-axe** | Testing library | Unit/integration tests |
| **NVDA** | Screen reader (Windows) | Manual SR testing |
| **VoiceOver** | Screen reader (macOS/iOS) | Manual SR testing |

## WCAG 2.2 New Criteria

| Criterion | Level | Description |
|-----------|-------|-------------|
| **2.4.11** Focus Not Obscured (Minimum) | AA | Focused element not completely hidden |
| **2.4.12** Focus Not Obscured (Enhanced) | AAA | No part of focused element hidden |
| **2.4.13** Focus Appearance | AAA | Focus indicator size/contrast requirements |
| **2.5.7** Dragging Movements | AA | Dragging has single-pointer alternative |
| **2.5.8** Target Size (Minimum) | AA | Targets at least 24x24 CSS pixels |
| **3.2.6** Consistent Help | A | Help in same location across pages |
| **3.3.7** Redundant Entry | A | Previously entered info auto-populated |
| **3.3.8** Accessible Authentication (Minimum) | AA | No cognitive test or provide alternative |
| **3.3.9** Accessible Authentication (Enhanced) | AAA | No cognitive test, no exceptions |

> Full WCAG 2.2 criterion reference, implementation patterns, test protocols, and resources: [reference.md](./reference.md)
