# WCAG 2.2 Full Reference

Detailed criterion tables, implementation roadmap, test protocols, and code patterns.
See [SKILL.md](./SKILL.md) for the actionable checklist.

---

## Success Criteria Reference

### Level A Criteria

#### Perceivable — Level A

| Criterion | Description | Test |
|-----------|-------------|------|
| **1.1.1** Non-text Content | All non-text content has text alternative | Automated + Manual |
| **1.2.1** Audio-only/Video-only (Prerecorded) | Alternative provided | Manual |
| **1.2.2** Captions (Prerecorded) | Captions for synchronized media | Automated + Manual |
| **1.2.3** Audio Description or Media Alternative | Alternative for video | Manual |
| **1.3.1** Info and Relationships | Structure programmatically determinable | Automated + Manual |
| **1.3.2** Meaningful Sequence | Content sequence meaningful when CSS disabled | Automated |
| **1.3.3** Sensory Characteristics | Instructions don't rely on sensory characteristics alone | Manual |
| **1.4.1** Use of Color | Color not sole means of conveying information | Manual |
| **1.4.2** Audio Control | Audio can be paused/stopped or volume controlled | Manual |

#### Operable — Level A

| Criterion | Description | Test |
|-----------|-------------|------|
| **2.1.1** Keyboard | All functionality available via keyboard | Manual |
| **2.1.2** No Keyboard Trap | Keyboard focus not trapped | Manual |
| **2.1.4** Character Key Shortcuts | Single-key shortcuts can be turned off/remapped | Manual |
| **2.2.1** Timing Adjustable | Users can turn off/adjust/extend time limits | Manual |
| **2.2.2** Pause, Stop, Hide | Moving/blinking content can be controlled | Manual |
| **2.3.1** Three Flashes or Below Threshold | No content flashes more than 3 times/second | Automated |
| **2.4.1** Bypass Blocks | Mechanism to bypass blocks of content | Automated |
| **2.4.2** Page Titled | Pages have descriptive titles | Automated |
| **2.4.3** Focus Order | Focus order logical and meaningful | Manual |
| **2.4.4** Link Purpose (In Context) | Link purpose determinable from context | Manual |
| **2.5.1** Pointer Gestures | Complex gestures have single-pointer alternatives | Manual |
| **2.5.2** Pointer Cancellation | Up-event activation or abort mechanism | Manual |
| **2.5.3** Label in Name | Visible label matches accessible name | Automated |
| **2.5.4** Motion Actuation | Functionality not dependent on device motion | Manual |

#### Understandable — Level A

| Criterion | Description | Test |
|-----------|-------------|------|
| **3.1.1** Language of Page | Default language programmatically determined | Automated |
| **3.2.1** On Focus | Focus doesn't change context unexpectedly | Manual |
| **3.2.2** On Input | Input doesn't change context unexpectedly | Manual |
| **3.2.6** Consistent Help | Help mechanisms in consistent locations | Manual |
| **3.3.1** Error Identification | Errors identified in text | Manual |
| **3.3.2** Labels or Instructions | Labels/instructions provided | Automated + Manual |
| **3.3.7** Redundant Entry | Previously entered information auto-populated | Manual |

#### Robust — Level A

| Criterion | Description | Test |
|-----------|-------------|------|
| **4.1.1** Parsing | (Obsolete in WCAG 2.2 — removed) | N/A |
| **4.1.2** Name, Role, Value | UI components have name/role/value | Automated |
| **4.1.3** Status Messages | Status messages programmatically determinable | Manual |

---

### Level AA Criteria

#### Perceivable — Level AA

| Criterion | Description | Test |
|-----------|-------------|------|
| **1.2.4** Captions (Live) | Captions for live audio | Manual |
| **1.2.5** Audio Description (Prerecorded) | Audio description for video | Manual |
| **1.3.4** Orientation | Content not restricted to single orientation | Manual |
| **1.3.5** Identify Input Purpose | Input purposes programmatically determined | Automated |
| **1.4.3** Contrast (Minimum) | 4.5:1 for normal text, 3:1 for large text | Automated |
| **1.4.4** Resize Text | Text resizable to 200% without AT | Manual |
| **1.4.5** Images of Text | Text used instead of images of text | Manual |
| **1.4.10** Reflow | No horizontal scroll at 320px viewport | Manual |
| **1.4.11** Non-text Contrast | 3:1 for UI components and graphics | Automated |
| **1.4.12** Text Spacing | No loss of content with text spacing changes | Manual |
| **1.4.13** Content on Hover or Focus | Hover/focus content dismissible/hoverable/persistent | Manual |

#### Operable — Level AA

| Criterion | Description | Test |
|-----------|-------------|------|
| **2.4.5** Multiple Ways | Multiple ways to find pages | Manual |
| **2.4.6** Headings and Labels | Headings and labels describe topic/purpose | Manual |
| **2.4.7** Focus Visible | Keyboard focus indicator visible | Manual |
| **2.4.11** Focus Not Obscured (Minimum) | Focused element not completely hidden | Manual |
| **2.5.7** Dragging Movements | Dragging has single-pointer alternative | Manual |
| **2.5.8** Target Size (Minimum) | Targets at least 24x24 CSS pixels | Automated |

#### Understandable — Level AA

| Criterion | Description | Test |
|-----------|-------------|------|
| **3.1.2** Language of Parts | Language of passages programmatically determined | Automated |
| **3.2.3** Consistent Navigation | Navigation in consistent locations | Manual |
| **3.2.4** Consistent Identification | Components identified consistently | Manual |
| **3.3.3** Error Suggestion | Suggestions for error correction provided | Manual |
| **3.3.4** Error Prevention (Legal, Financial, Data) | Reversible/submittable/checkable for sensitive data | Manual |
| **3.3.8** Accessible Authentication (Minimum) | No cognitive test or alternative available | Manual |

---

### Level AAA Criteria

#### Perceivable — Level AAA

| Criterion | Description | Test |
|-----------|-------------|------|
| **1.2.6** Sign Language (Prerecorded) | Sign language interpretation provided | Manual |
| **1.2.7** Extended Audio Description | Extended audio description when needed | Manual |
| **1.2.8** Media Alternative (Prerecorded) | Text alternative for all prerecorded media | Manual |
| **1.2.9** Audio-only (Live) | Text alternative for live audio-only | Manual |
| **1.3.6** Identify Purpose | Purpose of UI components/icons/regions determinable | Manual |
| **1.4.6** Contrast (Enhanced) | 7:1 for normal text, 4.5:1 for large text | Automated |
| **1.4.7** Low or No Background Audio | Audio primarily foreground or background 20dB quieter | Manual |
| **1.4.8** Visual Presentation | Wide range of visual customizations available | Manual |
| **1.4.9** Images of Text (No Exception) | No images of text (with exceptions) | Manual |

#### Operable — Level AAA

| Criterion | Description | Test |
|-----------|-------------|------|
| **2.1.3** Keyboard (No Exception) | All functionality via keyboard, no exceptions | Manual |
| **2.2.3** No Timing | No time limits | Manual |
| **2.2.4** Interruptions | Interruptions can be postponed/suppressed | Manual |
| **2.2.5** Re-authenticating | Data preserved when re-authenticating | Manual |
| **2.2.6** Timeouts | Users warned of timeouts | Manual |
| **2.3.2** Three Flashes | No content flashes more than 3 times/second | Automated |
| **2.3.3** Animation from Interactions | Motion animation can be disabled | Manual |
| **2.4.8** Location | Location within set of pages available | Manual |
| **2.4.9** Link Purpose (Link Only) | Link purpose determinable from link alone | Manual |
| **2.4.10** Section Headings | Sections have headings | Manual |
| **2.4.12** Focus Not Obscured (Enhanced) | No part of focused element hidden | Manual |
| **2.4.13** Focus Appearance | Focus indicator meets size/contrast requirements | Automated |
| **2.5.5** Target Size (Enhanced) | Targets at least 44x44 CSS pixels | Automated |
| **2.5.6** Concurrent Input Mechanisms | Not restricted to specific input types | Manual |

#### Understandable — Level AAA

| Criterion | Description | Test |
|-----------|-------------|------|
| **3.1.3** Unusual Words | Mechanism for identifying definitions | Manual |
| **3.1.4** Abbreviations | Mechanism for identifying expanded forms | Manual |
| **3.1.5** Reading Level | Reading level supplementary content available | Manual |
| **3.1.6** Pronunciation | Mechanism for pronunciation | Manual |
| **3.2.5** Change on Request | Context changes only on user request | Manual |
| **3.3.5** Help | Context-sensitive help available | Manual |
| **3.3.6** Error Prevention (All) | Reversible/submittable/checkable for all data | Manual |
| **3.3.9** Accessible Authentication (Enhanced) | No cognitive test (stricter than 3.3.8) | Manual |

---

## Implementation Roadmap

### Phase 1: Foundation (Level A)

**Week 1–2: Content & Structure**
- [ ] Implement semantic HTML5 elements (`<main>`, `<nav>`, `<article>`, `<section>`, etc.)
- [ ] Add alt text to all images
- [ ] Ensure proper heading hierarchy (h1–h6)
- [ ] Add descriptive page titles
- [ ] Mark up lists and tables correctly

**Week 3: Keyboard & Navigation**
- [ ] Ensure all interactive elements keyboard accessible
- [ ] Implement skip links
- [ ] Test focus order
- [ ] Remove keyboard traps

**Week 4: Forms & Media**
- [ ] Associate all form labels
- [ ] Add error identification to forms
- [ ] Provide transcripts for audio-only content
- [ ] Add captions to prerecorded video

**Testing**: Run automated tests (axe, WAVE) + manual keyboard testing.

### Phase 2: Enhanced (Level AA)

**Week 5–6: Visual Design**
- [ ] Verify 4.5:1 contrast for all text
- [ ] Ensure 3:1 contrast for UI components
- [ ] Test text resizing to 200%
- [ ] Verify reflow at 320px viewport

**Week 7: Navigation & Input**
- [ ] Implement multiple ways to find pages
- [ ] Ensure consistent navigation
- [ ] Make focus indicators visible
- [ ] Verify target sizes minimum 24x24px

**Week 8–10: Forms & Authentication**
- [ ] Implement error prevention for sensitive data
- [ ] Add error suggestions
- [ ] Provide accessible authentication methods
- [ ] Implement redundant entry prevention

**Testing**: Automated contrast checks + screen reader testing.

### Phase 3: Excellence (Level AAA)

- Achieve 7:1 contrast for text
- Implement 44x44px target size
- Provide location information (breadcrumbs)
- Add focus appearance enhancements
- Implement `prefers-reduced-motion` for animations
- Error prevention for all data inputs

**Testing**: Full AT testing + user testing with people with disabilities.

---

## Test Protocols

### Keyboard Accessibility

1. Unplug mouse / disable trackpad
2. Navigate entire page using only Tab key
3. Verify all interactive elements can be reached
4. Test arrow keys, Enter, Space, Escape
5. Verify focus order matches visual order

### Screen Reader (NVDA/VoiceOver)

1. Navigate page; verify headings announced correctly
2. Verify list items, table headers, form labels associated
3. Trigger form errors; verify error messages announced
4. Verify loading states and status messages are announced
5. Check all links have meaningful text (no "click here")

### Automated (axe-core)

```javascript
describe('WCAG 2.2 Automated Tests', () => {
  test('All images have alt text', async () => {
    const results = await axe(container);
    expect(results).toHaveNoViolations('image-alt');
  });

  test('Text meets minimum contrast', async () => {
    const results = await axe(container);
    expect(results).toHaveNoViolations('color-contrast');
  });

  test('Interactive elements minimum 24x24px', () => {
    const targets = document.querySelectorAll('button, a, input, select, textarea');
    targets.forEach((target) => {
      const rect = target.getBoundingClientRect();
      expect(rect.width).toBeGreaterThanOrEqual(24);
      expect(rect.height).toBeGreaterThanOrEqual(24);
    });
  });
});
```

---

## Common Implementation Patterns

### Skip Link

```html
<a href="#main-content" class="skip-link">Skip to main content</a>
<main id="main-content" tabindex="-1">
  <!-- Main content -->
</main>
```

```css
:focus-visible {
  outline: 3px solid #0056b3;
  outline-offset: 2px;
}

.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
}

.skip-link:focus {
  top: 0;
}
```

### Accessible Form with Error Handling

```html
<label for="email">Email Address</label>
<input
  type="email"
  id="email"
  name="email"
  required
  aria-required="true"
  aria-describedby="email-error"
/>
<div id="email-error" role="alert" aria-live="polite"></div>

<fieldset>
  <legend>Preferred Contact Method</legend>
  <input type="radio" id="contact-email" name="contact" value="email" />
  <label for="contact-email">Email</label>
  <input type="radio" id="contact-phone" name="contact" value="phone" />
  <label for="contact-phone">Phone</label>
</fieldset>
```

### Accessible Authentication (3.3.8)

```html
<!-- Allow password managers (autocomplete attributes) -->
<form>
  <label for="username">Username</label>
  <input type="text" id="username" name="username" autocomplete="username" />

  <label for="password">Password</label>
  <input type="password" id="password" name="password" autocomplete="current-password" />

  <!-- Alternative method — no cognitive test required -->
  <button type="button">Email me a sign-in link</button>
</form>
```

### Target Size

```css
/* AA — 24x24px minimum */
.btn {
  min-width: 24px;
  min-height: 24px;
  padding: 8px 16px;
}

/* AAA — 44x44px */
.btn-aaa {
  min-width: 44px;
  min-height: 44px;
  padding: 12px 24px;
}
```

### Dragging Alternative (2.5.7)

```html
<div class="drag-container">
  <div draggable="true" class="draggable">Item</div>
  <div class="movement-controls">
    <button aria-label="Move up">Up</button>
    <button aria-label="Move down">Down</button>
  </div>
</div>
```

### Redundant Entry (3.3.7)

```javascript
function populateShippingFromBilling() {
  const billing = document.getElementById('billing-address').value;
  document.getElementById('shipping-address').value = billing;
}
```

---

## Resources

### Official
- [WCAG 2.2 Specification](https://www.w3.org/TR/WCAG22/)
- [How to Meet WCAG 2.2 (Quick Reference)](https://www.w3.org/WAI/WCAG22/quickref/)
- [Understanding WCAG 2.2](https://www.w3.org/WAI/WCAG22/Understanding/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

### Training
- [WAI Tutorials](https://www.w3.org/WAI/tutorials/)
- [Web Accessibility Perspectives](https://www.w3.org/WAI/perspective-videos/)

### Legal
- [Section 508](https://www.section508.gov/) (US)
- [EN 301 549](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/) (Europe)
- [European Accessibility Act](https://ec.europa.eu/social/main.jsp?catId=1202) (EU)
