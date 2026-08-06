---
name: css
description: CSS and SASS/SCSS best practices including 7-1 architecture, avoiding inline styles, external file organization, and performance. Use when writing or reviewing CSS/SCSS.
---

# CSS Developer Skill

**Roadmap Alignment:** [roadmap.sh/frontend](https://roadmap.sh/frontend) | [roadmap.sh/css](https://roadmap.sh/css)

## Core Principle: Separation of Concerns

Structure (HTML), presentation (CSS), and behavior (JavaScript) must remain separate. This is non-negotiable for maintainable, performant, and accessible code.

---

## 1. Never Use Inline CSS

Inline CSS is an anti-pattern. Do not write `style="..."` attributes in HTML or inject styles via JavaScript's `element.style.prop = "value"`.

### Why Inline CSS Is Harmful

| Issue | Explanation |
| ------- | ------------- |
| **Specificity hell** | Inline styles have the highest specificity (`1,0,0,0`). They override everything and make overrides impossible without `!important`, which compounds the problem. |
| **No reuse** | Every inline style is a one-off. Duplication spreads across the codebase. |
| **No media queries** | Inline styles cannot respond to `@media` breakpoints. Responsive design becomes impossible. |
| **No pseudo-classes** | `:hover`, `:focus`, `:active`, `::before`, `::after` — none work with inline styles. |
| **No caching** | Inline styles are repeated in every HTML response. External `.css` files are cached by the browser after the first request. |
| **CSP violations** | Content Security Policy often blocks `style="..."` via `style-src: 'unsafe-inline'`. Inline styles weaken your security posture. |
| **Maintenance burden** | Changes require finding every HTML file or JS template that duplicates the same style. |

### What To Do Instead

```html
<!-- ❌ BAD: Inline CSS -->
<button style="background: blue; color: white; padding: 12px 24px; border-radius: 4px;">
  Submit
</button>

<!-- ✅ GOOD: Class-based external CSS -->
<button class="btn btn--primary">
  Submit
</button>
```

### Inline Styles in JavaScript

```javascript
// ❌ BAD: Direct style manipulation
element.style.display = 'flex';
element.style.justifyContent = 'center';
element.style.padding = '16px';

// ✅ GOOD: Toggle classes
element.classList.add('modal--open');
element.classList.remove('modal--open');

// ✅ GOOD: Use CSS custom properties for dynamic values
element.style.setProperty('--modal-offset', `${scrollY}px`);
```

**Exception:** CSS custom properties (`var(--x)`) set via JavaScript `style.setProperty()` are acceptable for truly dynamic values that cannot be known at build time (e.g., scroll position, mouse coordinates, user-picked colors).

---

## 2. Always Use External CSS Files

CSS belongs in `.css` files (or `.scss`/`.sass` for Sass). Load them via `<link>` in the `<head>`.

```html
<!-- ✅ GOOD: External stylesheet -->
<link rel="stylesheet" href="styles/main.css">

<!-- ✅ GOOD: With media query support -->
<link rel="stylesheet" href="styles/print.css" media="print">
```

### File Organization (Generic)

```
styles/
├── main.css          # Entry point — imports only
├── base/             # Reset, typography, base styles
├── components/       # Reusable UI component styles
├── layout/           # Page layout (header, footer, grid)
└── utilities/        # Helper classes (.sr-only, .text-center)
```

---

## 3. SASS/SCSS: The 7-1 Architecture Pattern

The 7-1 pattern is the industry standard for organizing Sass projects: **7 folders, 1 main file**.

### Folder Structure

```
styles/
├── abstracts/        # Tools — no CSS output here
│   ├── _variables.scss
│   ├── _mixins.scss
│   ├── _functions.scss
│   └── _placeholders.scss
├── base/            # Boilerplate
│   ├── _reset.scss    # or _normalize.scss
│   ├── _typography.scss
│   └── _base.scss
├── components/      # UI components (one file per component)
│   ├── _button.scss
│   ├── _card.scss
│   ├── _modal.scss
│   ├── _form.scss
│   └── _navigation.scss
├── layout/          # Major layout sections
│   ├── _header.scss
│   ├── _footer.scss
│   ├── _sidebar.scss
│   ├── _grid.scss
│   └── _section.scss
├── pages/           # Page-specific overrides (use sparingly)
│   ├── _home.scss
│   ├── _about.scss
│   └── _contact.scss
├── themes/          # Theme variants
│   ├── _theme-default.scss
│   └── _theme-dark.scss
├── vendors/         # Third-party CSS (reset, libraries)
│   ├── _bootstrap.scss
│   └── _slick-carousel.scss
└── main.scss        # THE ONE — imports everything in order
```

### The Single Entry Point (`main.scss`)

```scss
// 1. Abstracts — no output, only tools
@import 'abstracts/variables';
@import 'abstracts/mixins';
@import 'abstracts/functions';

// 2. Vendors — third-party styles
@import 'vendors/bootstrap';

// 3. Base — reset and defaults
@import 'base/reset';
@import 'base/typography';

// 4. Layout — major structural elements
@import 'layout/header';
@import 'layout/grid';
@import 'layout/footer';

// 5. Components — UI pieces
@import 'components/button';
@import 'components/card';
@import 'components/modal';

// 6. Pages — page-specific overrides
@import 'pages/home';

// 7. Themes — theme variants
@import 'themes/theme-dark';
```

**Import order matters.** Abstracts first (they're dependencies), then vendors, then base, then layout, then components, then pages, then themes. Each layer builds on the previous.

### Key Rules for 7-1

- **Abstracts never produce CSS output** — variables, mixins, functions, placeholders only.
- **One component per file** in `components/`. If a file exceeds 200 lines, split the component.
- **Pages folder should be thin** — 90% of styles live in `components/` and `layout/`.
- **Partials use underscore prefix** (`_button.scss`) — tells Sass not to compile them individually.
- **No nesting deeper than 3 levels** — prevents specificity bloat. If you're nesting 4+, extract a new component.

---

## 4. SASS/SCSS Best Practices

### Variables First

```scss
// ❌ BAD: Magic numbers
.card {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

// ✅ GOOD: Semantic variables
$border-radius-md: 8px;
$shadow-card: 0 2px 8px rgba(0, 0, 0, 0.1);

.card {
  border-radius: $border-radius-md;
  box-shadow: $shadow-card;
}
```

### Nesting Discipline

```scss
// ❌ BAD: 5 levels of nesting
.nav {
  .nav__list {
    .nav__item {
      .nav__link {
        &:hover { color: red; }
      }
    }
  }
}

// ✅ GOOD: BEM + 1 level of nesting
.nav {
  &__list {
    display: flex;
  }
  &__link {
    &:hover { color: red; }
  }
}
```

### Mixins vs Placeholders

```scss
// Mixin — use when arguments are needed
@mixin flex-center($direction: row) {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: $direction;
}

// Placeholder — use for repeated static blocks
%text-truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
```

### Use Sass Modules (`@use`)

```scss
// ❌ BAD: @import is deprecated
@import 'variables';

// ✅ GOOD: @use with namespace
@use 'abstracts/variables' as var;
@use 'abstracts/mixins' as mix;

.card {
  background: var.$color-surface;
  @include mix.flex-center;
}
```

---

## 5. CSS Methodologies

Choose one methodology and stick to it across the project.

| Methodology | Best For | Key Idea |
| ------------- | ---------- | ---------- |
| **BEM** | Traditional multi-page apps | `.block__element--modifier` |
| **CSS Modules** | Component-based frameworks (React, Vue) | Scoped class names via build tool |
| **Utility-First (Tailwind)** | Rapid prototyping, design systems | Composable utility classes |
| **ITCSS** | Large-scale projects | Inverted Triangle: generic → explicit |

### BEM Example

```scss
// Block: standalone component
.card { }

// Element: part of block
.card__title { }
.card__body { }

// Modifier: variant of block/element
.card--featured { }
.card__title--large { }
```

---

## 6. Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
| -------------- | --------- | ----- |
| `!important` | Breaks cascade, undebuggable | Increase specificity legitimately or restructure |
| `#id` selectors | Too high specificity, not reusable | Use classes |
| Deep nesting | `.a .b .c .d .e` — fragile, slow | Use BEM or flatten |
| `*` universal selector | Performance issues on large DOMs | Use targeted selectors |
| Inline CSS in JS | See section 1 above | Use classes or CSS-in-JS libraries properly |
| Overqualified selectors | `div.container` — redundant | `.container` is sufficient |
| Magic numbers | `margin-top: 37px` — no rationale | Name the value as a variable |

---

## 7. CSS-in-JS (When You Must Use It)

CSS-in-JS (styled-components, Emotion) is acceptable when:

- The styles depend on runtime props that cannot be expressed via CSS custom properties.
- You are building a shared component library where co-location of styles and logic is required.
- Dead style elimination is critical (styles are removed when the component is unused).

**Best practices when using CSS-in-JS:**

```javascript
// ✅ GOOD: Use styled components properly
const Button = styled.button`
  background: ${props => props.variant === 'primary' ? 'blue' : 'gray'};
  padding: 12px 24px;
  border-radius: 4px;
`;

// ❌ BAD: Inline styles in JSX
<button style={{ background: 'blue', padding: '12px 24px' }} />

// ✅ GOOD: CSS custom properties for dynamic values
// JS:
element.style.setProperty('--x-offset', `${x}px`);
// CSS:
.tooltip { transform: translateX(var(--x-offset)); }
```

---

## See Also

- `frontend` — Broader frontend development including HTML semantics and frameworks
- `web-accessibility` — WCAG compliance, color contrast, and accessible styling
- `reactjs` / `vuejs` / `angularjs` — Framework-specific styling conventions
- `markdown` — Documentation formatting standards
