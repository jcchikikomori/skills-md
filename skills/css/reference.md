# CSS Skill — Reference

## 7-1 Scaffold Script

Generate the full 7-1 directory tree:

```bash
mkdir -p styles/{abstracts,base,components,layout,pages,themes,vendors}
touch styles/main.scss
touch styles/abstracts/_{variables,mixins,functions,placeholders}.scss
touch styles/base/{_reset,_typography,_base}.scss
touch styles/components/{_button,_card,_modal,_form,_navigation}.scss
touch styles/layout/{_header,_footer,_sidebar,_grid,_section}.scss
touch styles/pages/{_home,_about,_contact}.scss
touch styles/themes/{_theme-default,_theme-dark}.scss
touch styles/vendors/{_bootstrap,_external-lib}.scss
```

## Inline CSS: Good vs Bad Examples

### In HTML

```html
<!-- ❌ BAD: Inline everywhere -->
<div style="display: flex; gap: 16px;">
  <p style="font-size: 14px; color: #333;">Text</p>
</div>

<!-- ✅ GOOD: External classes -->
<div class="flex gap-md">
  <p class="text-body">Text</p>
</div>
```

### In JavaScript (DOM manipulation)

```javascript
// ❌ BAD: Inline via JS
const el = document.getElementById('toast');
el.style.position = 'fixed';
el.style.bottom = '20px';
el.style.right = '20px';
el.style.padding = '16px';
el.style.borderRadius = '8px';
el.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';

// ✅ GOOD: Toggle a class
el.classList.add('toast--visible');
```

### In React

```javascript
// ❌ BAD: Inline style objects
function BadComponent() {
  return (
    <div style={{
      display: 'flex',
      padding: '16px',
      borderRadius: '8px',
      backgroundColor: '#f5f5f5'
    }}>
      <p style={{ fontSize: '14px', color: '#666' }}>Content</p>
    </div>
  );
}

// ✅ GOOD: External CSS modules
import styles from './Card.module.css';

function GoodComponent() {
  return (
    <div className={styles.card}>
      <p className={styles.text}>Content</p>
    </div>
  );
}
```

### In Vue

```html
<!-- ❌ BAD: Inline styles in template -->
<template>
  <div :style="{ display: 'flex', padding: '16px' }">
    <p :style="{ fontSize: '14px', color: '#666' }">Content</p>
  </div>
</template>

<!-- ✅ GOOD: Scoped styles -->
<template>
  <div class="card">
    <p class="card__text">Content</p>
  </div>
</template>

<style scoped>
.card {
  display: flex;
  padding: 16px;
}
.card__text {
  font-size: 14px;
  color: #666;
}
</style>
```

## SASS/SCSS Patterns

### Variables Map

```scss
// abstracts/_variables.scss

// Colors
$color-primary: #0066ff;
$color-primary-dark: #0052cc;
$color-secondary: #6c757d;
$color-success: #28a745;
$color-danger: #dc3545;
$color-warning: #ffc107;
$color-info: #17a2b8;

// Surfaces
$color-surface: #ffffff;
$color-surface-alt: #f8f9fa;
$color-background: #f0f2f5;

// Text
$color-text-primary: #212529;
$color-text-secondary: #6c757d;
$color-text-disabled: #adb5bd;

// Spacing (4px base)
$spacing-xs: 4px;
$spacing-sm: 8px;
$spacing-md: 16px;
$spacing-lg: 24px;
$spacing-xl: 32px;
$spacing-xxl: 48px;

// Typography
$font-family-base: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
$font-family-mono: 'JetBrains Mono', 'Fira Code', monospace;
$font-size-xs: 12px;
$font-size-sm: 14px;
$font-size-base: 16px;
$font-size-lg: 20px;
$font-size-xl: 24px;
$font-size-xxl: 32px;
$font-size-huge: 48px;

// Breakpoints
$breakpoint-sm: 576px;
$breakpoint-md: 768px;
$breakpoint-lg: 992px;
$breakpoint-xl: 1200px;

// Shadows
$shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
$shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07);
$shadow-lg: 0 10px 25px rgba(0, 0, 0, 0.1);
$shadow-xl: 0 20px 50px rgba(0, 0, 0, 0.15);

// Z-index
$z-dropdown: 100;
$z-sticky: 200;
$z-modal-backdrop: 300;
$z-modal: 400;
$z-toast: 500;
$z-tooltip: 600;
```

### Responsive Mixins

```scss
// abstracts/_mixins.scss

@use 'variables' as *;

// Breakpoint mixins (mobile-first)
@mixin respond-to($breakpoint) {
  @if $breakpoint == 'sm' {
    @media (min-width: $breakpoint-sm) { @content; }
  } @else if $breakpoint == 'md' {
    @media (min-width: $breakpoint-md) { @content; }
  } @else if $breakpoint == 'lg' {
    @media (min-width: $breakpoint-lg) { @content; }
  } @else if $breakpoint == 'xl' {
    @media (min-width: $breakpoint-xl) { @content; }
  }
}

@mixin respond-down($breakpoint) {
  @if $breakpoint == 'sm' {
    @media (max-width: ($breakpoint-sm - 1px)) { @content; }
  } @else if $breakpoint == 'md' {
    @media (max-width: ($breakpoint-md - 1px)) { @content; }
  } @else if $breakpoint == 'lg' {
    @media (max-width: ($breakpoint-lg - 1px)) { @content; }
  } @else if $breakpoint == 'xl' {
    @media (max-width: ($breakpoint-xl - 1px)) { @content; }
  }
}
```

### Button Component (BEM + SCSS)

```scss
// components/_button.scss

@use '../abstracts/variables' as *;
@use '../abstracts/mixins' as *;

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: $spacing-sm;
  padding: $spacing-sm $spacing-lg;
  font-family: $font-family-base;
  font-size: $font-size-base;
  font-weight: 500;
  line-height: 1.5;
  border: 1px solid transparent;
  border-radius: 6px;
  cursor: pointer;
  transition: background-color 0.2s, box-shadow 0.2s, transform 0.1s;

  // Variants
  &--primary {
    background-color: $color-primary;
    color: #fff;
    &:hover {
      background-color: $color-primary-dark;
      box-shadow: $shadow-md;
    }
  }

  &--secondary {
    background-color: transparent;
    color: $color-primary;
    border-color: $color-primary;
    &:hover {
      background-color: rgba($color-primary, 0.08);
    }
  }

  &--danger {
    background-color: $color-danger;
    color: #fff;
    &:hover {
      background-color: darken($color-danger, 10%);
    }
  }

  // Sizes
  &--sm {
    padding: $spacing-xs $spacing-sm;
    font-size: $font-size-sm;
  }

  &--lg {
    padding: $spacing-md $spacing-xl;
    font-size: $font-size-lg;
  }

  // States
  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    pointer-events: none;
  }

  &:active {
    transform: scale(0.98);
  }
}
```

### Theme Support with CSS Custom Properties

```scss
// themes/_theme-default.scss
:root {
  --color-primary: #0066ff;
  --color-surface: #ffffff;
  --color-text: #212529;
  --color-border: #dee2e6;
}

// themes/_theme-dark.scss
[data-theme='dark'] {
  --color-primary: #3b82f6;
  --color-surface: #1e1e2e;
  --color-text: #e2e8f0;
  --color-border: #334155;
}
```

## Critical CSS Strategy

For production, inline above-the-fold Critical CSS in `<head>` and defer the full stylesheet:

```html
<head>
  <!-- Critical CSS inlined for first paint -->
  <style>
    /* hero, nav, above-the-fold styles only */
    .header { ... }
    .hero { ... }
  </style>

  <!-- Full stylesheet loaded asynchronously -->
  <link rel="preload" href="styles/main.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
  <noscript><link rel="stylesheet" href="styles/main.css"></noscript>
</head>
```

## Reference

- [Sass Guidelines (7-1 Pattern)](https://sass-guidelin.es/)
- [BEM Methodology](https://en.bem.info/methodology/)
- [CSS Specificity Calculator](https://specificity.keegan.st/)
- [Critical CSS Strategy](https://web.dev/extract-critical-css/)
