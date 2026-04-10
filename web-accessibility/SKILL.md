# Web Accessibility Skill

Comprehensive guide for implementing WCAG 2.2 standards with focus on achieving AAA compliance (with AA as minimum).

## Overview

Web Content Accessibility Guidelines (WCAG) 2.2 is the current W3C recommendation for making web content accessible to people with disabilities. It addresses:

- Visual impairments (blindness, low vision)
- Auditory impairments (deafness, hearing loss)
- Physical disabilities (limited movement)
- Cognitive and learning disabilities
- Photosensitivity
- Speech disabilities

**Key Principle**: Content that conforms to WCAG 2.2 also conforms to WCAG 2.1 and 2.0 (backwards compatible).

## The Four POUR Principles

WCAG 2.2 is organized under four foundational principles:

### 1. Perceivable

Information and user interface components must be presentable to users in ways they can perceive.

**Guidelines:**

- **1.1 Text Alternatives**: Provide text alternatives for non-text content
- **1.2 Time-based Media**: Provide alternatives for time-based media
- **1.3 Adaptable**: Create content that can be presented in different ways
- **1.4 Distinguishable**: Make it easier for users to see and hear content

### 2. Operable

User interface components and navigation must be operable.

**Guidelines:**

- **2.1 Keyboard Accessible**: Make all functionality available from a keyboard
- **2.2 Enough Time**: Provide users enough time to read and use content
- **2.3 Seizures and Physical Reactions**: Don't design content that causes seizures
- **2.4 Navigable**: Provide ways to help users navigate
- **2.5 Input Modalities**: Make it easier to operate functionality through various inputs

### 3. Understandable

Information and the operation of user interface must be understandable.

**Guidelines:**

- **3.1 Readable**: Make text content readable and understandable
- **3.2 Predictable**: Make web pages appear and operate in predictable ways
- **3.3 Input Assistance**: Help users avoid and correct mistakes

### 4. Robust

Content must be robust enough to work with current and future assistive technologies.

**Guidelines:**

- **4.1 Compatible**: Maximize compatibility with current and future user agents

---

## Conformance Levels

| Level   | Description                                      | Priority           |
| ------- | ------------------------------------------------ | ------------------ |
| **A**   | Minimum level - basic accessibility requirements | Essential          |
| **AA**  | Acceptable level - removes significant barriers  | **Target Minimum** |
| **AAA** | Maximum level - enhanced accessibility           | **Preferred Goal** |

### AAA Considerations

- Not required by current laws/regulations
- May not be applicable to all content types
- Represents best practice for maximum inclusion
- Some AAA criteria are challenging to implement universally

---

## Success Criteria Reference

### Level A Criteria (30 total)

#### 1. Perceivable - Level A

| Criterion                                        | Description                                               | Test Approach      |
| ------------------------------------------------ | --------------------------------------------------------- | ------------------ |
| **1.1.1** Non-text Content                       | All non-text content has text alternative                 | Automated + Manual |
| **1.2.1** Audio-only/Video-only (Prerecorded)    | Alternative provided for audio-only and video-only        | Manual             |
| **1.2.2** Captions (Prerecorded)                 | Captions provided for synchronized media                  | Automated + Manual |
| **1.2.3** Audio Description or Media Alternative | Alternative provided for video content                    | Manual             |
| **1.3.1** Info and Relationships                 | Information structure programmatically determinable       | Automated + Manual |
| **1.3.2** Meaningful Sequence                    | Content sequence meaningful when CSS disabled             | Automated          |
| **1.3.3** Sensory Characteristics                | Instructions don't rely solely on sensory characteristics | Manual             |
| **1.4.1** Use of Color                           | Color not sole means of conveying information             | Manual             |
| **1.4.2** Audio Control                          | Audio can be paused/stopped or volume controlled          | Manual             |

#### 2. Operable - Level A

| Criterion                                  | Description                                       | Test Approach |
| ------------------------------------------ | ------------------------------------------------- | ------------- |
| **2.1.1** Keyboard                         | All functionality available via keyboard          | Manual        |
| **2.1.2** No Keyboard Trap                 | Keyboard focus not trapped                        | Manual        |
| **2.1.4** Character Key Shortcuts          | Single-key shortcuts can be turned off/remapped   | Manual        |
| **2.2.1** Timing Adjustable                | Users can turn off/adjust/extend time limits      | Manual        |
| **2.2.2** Pause, Stop, Hide                | Moving/blinking content can be controlled         | Manual        |
| **2.3.1** Three Flashes or Below Threshold | No content flashes more than 3 times/second       | Automated     |
| **2.4.1** Bypass Blocks                    | Mechanism to bypass blocks of content             | Automated     |
| **2.4.2** Page Titled                      | Pages have descriptive titles                     | Automated     |
| **2.4.3** Focus Order                      | Focus order logical and meaningful                | Manual        |
| **2.4.4** Link Purpose (In Context)        | Link purpose determinable from context            | Manual        |
| **2.5.1** Pointer Gestures                 | Complex gestures have single-pointer alternatives | Manual        |
| **2.5.2** Pointer Cancellation             | Up-event activation or abort mechanism            | Manual        |
| **2.5.3** Label in Name                    | Visible label matches accessible name             | Automated     |
| **2.5.4** Motion Actuation                 | Functionality not dependent on device motion      | Manual        |

#### 3. Understandable - Level A

| Criterion                        | Description                                   | Test Approach      |
| -------------------------------- | --------------------------------------------- | ------------------ |
| **3.1.1** Language of Page       | Default language programmatically determined  | Automated          |
| **3.2.1** On Focus               | Focus doesn't change context unexpectedly     | Manual             |
| **3.2.2** On Input               | Input doesn't change context unexpectedly     | Manual             |
| **3.2.6** Consistent Help        | Help mechanisms in consistent locations       | Manual             |
| **3.3.1** Error Identification   | Errors identified in text                     | Manual             |
| **3.3.2** Labels or Instructions | Labels/instructions provided                  | Automated + Manual |
| **3.3.7** Redundant Entry        | Previously entered information auto-populated | Manual             |

#### 4. Robust - Level A

| Criterion                   | Description                                   | Test Approach |
| --------------------------- | --------------------------------------------- | ------------- |
| **4.1.1** Parsing           | (Obsolete in 2.2 - removed)                   | N/A           |
| **4.1.2** Name, Role, Value | UI components have name/role/value            | Automated     |
| **4.1.3** Status Messages   | Status messages programmatically determinable | Manual        |

---

### Level AA Criteria (20 additional)

#### 1. Perceivable - Level AA

| Criterion                                 | Description                                          | Test Approach |
| ----------------------------------------- | ---------------------------------------------------- | ------------- |
| **1.2.4** Captions (Live)                 | Captions provided for live audio                     | Manual        |
| **1.2.5** Audio Description (Prerecorded) | Audio description for video content                  | Manual        |
| **1.3.4** Orientation                     | Content not restricted to single display orientation | Manual        |
| **1.3.5** Identify Input Purpose          | Input purposes programmatically determined           | Automated     |
| **1.4.3** Contrast (Minimum)              | 4.5:1 contrast ratio for normal text (3:1 for large) | Automated     |
| **1.4.4** Resize Text                     | Text resizable to 200% without assistive technology  | Manual        |
| **1.4.5** Images of Text                  | Text used instead of images of text                  | Manual        |
| **1.4.10** Reflow                         | Content readable without horizontal scroll at 320px  | Manual        |
| **1.4.11** Non-text Contrast              | 3:1 contrast for UI components and graphics          | Automated     |
| **1.4.12** Text Spacing                   | No loss of content/function with text spacing        | Manual        |
| **1.4.13** Content on Hover or Focus      | Hover/focus content dismissible/hoverable/persistent | Manual        |

#### 2. Operable - Level AA

| Criterion                               | Description                                | Test Approach |
| --------------------------------------- | ------------------------------------------ | ------------- |
| **2.4.5** Multiple Ways                 | Multiple ways to find pages                | Manual        |
| **2.4.6** Headings and Labels           | Headings and labels describe topic/purpose | Manual        |
| **2.4.7** Focus Visible                 | Keyboard focus indicator visible           | Manual        |
| **2.4.11** Focus Not Obscured (Minimum) | Focused element not completely hidden      | Manual        |
| **2.5.7** Dragging Movements            | Dragging has single-pointer alternative    | Manual        |
| **2.5.8** Target Size (Minimum)         | Targets at least 24x24 CSS pixels          | Automated     |

#### 3. Understandable - Level AA

| Criterion                                           | Description                                         | Test Approach |
| --------------------------------------------------- | --------------------------------------------------- | ------------- |
| **3.1.2** Language of Parts                         | Language of passages programmatically determined    | Automated     |
| **3.2.3** Consistent Navigation                     | Navigation in consistent locations                  | Manual        |
| **3.2.4** Consistent Identification                 | Components identified consistently                  | Manual        |
| **3.3.3** Error Suggestion                          | Suggestions for error correction provided           | Manual        |
| **3.3.4** Error Prevention (Legal, Financial, Data) | Reversible/submittable/checkable for sensitive data | Manual        |
| **3.3.8** Accessible Authentication (Minimum)       | No cognitive test or alternative available          | Manual        |

---

### Level AAA Criteria (28 additional)

#### 1. Perceivable - Level AAA

| Criterion                                 | Description                                           | Test Approach |
| ----------------------------------------- | ----------------------------------------------------- | ------------- |
| **1.2.6** Sign Language (Prerecorded)     | Sign language interpretation provided                 | Manual        |
| **1.2.7** Extended Audio Description      | Extended audio description when needed                | Manual        |
| **1.2.8** Media Alternative (Prerecorded) | Text alternative for all prerecorded media            | Manual        |
| **1.2.9** Audio-only (Live)               | Text alternative for live audio-only                  | Manual        |
| **1.3.6** Identify Purpose                | Purpose of UI components/icons/regions determinable   | Manual        |
| **1.4.6** Contrast (Enhanced)             | 7:1 contrast ratio for normal text (4.5:1 for large)  | Automated     |
| **1.4.7** Low or No Background Audio      | Audio primarily foreground or background 20dB quieter | Manual        |
| **1.4.8** Visual Presentation             | Wide range of visual customizations available         | Manual        |
| **1.4.9** Images of Text (No Exception)   | No images of text (with exceptions)                   | Manual        |

#### 2. Operable - Level AAA

| Criterion                                | Description                                      | Test Approach |
| ---------------------------------------- | ------------------------------------------------ | ------------- |
| **2.1.3** Keyboard (No Exception)        | All functionality via keyboard (no exceptions)   | Manual        |
| **2.2.3** No Timing                      | No time limits                                   | Manual        |
| **2.2.4** Interruptions                  | Interruptions can be postponed/suppressed        | Manual        |
| **2.2.5** Re-authenticating              | Data preserved when re-authenticating            | Manual        |
| **2.2.6** Timeouts                       | Users warned of timeouts                         | Manual        |
| **2.3.2** Three Flashes                  | No content flashes more than 3 times/second      | Automated     |
| **2.3.3** Animation from Interactions    | Motion animation can be disabled                 | Manual        |
| **2.4.8** Location                       | Location within set of pages available           | Manual        |
| **2.4.9** Link Purpose (Link Only)       | Link purpose determinable from link alone        | Manual        |
| **2.4.10** Section Headings              | Sections have headings                           | Manual        |
| **2.4.12** Focus Not Obscured (Enhanced) | No part of focused element hidden                | Manual        |
| **2.4.13** Focus Appearance              | Focus indicator meets size/contrast requirements | Automated     |
| **2.5.5** Target Size (Enhanced)         | Targets at least 44x44 CSS pixels                | Automated     |
| **2.5.6** Concurrent Input Mechanisms    | Not restricted to specific input types           | Manual        |

#### 3. Understandable - Level AAA

| Criterion                                      | Description                                   | Test Approach |
| ---------------------------------------------- | --------------------------------------------- | ------------- |
| **3.1.3** Unusual Words                        | Mechanism for identifying definitions         | Manual        |
| **3.1.4** Abbreviations                        | Mechanism for identifying expanded forms      | Manual        |
| **3.1.5** Reading Level                        | Reading level supplementary content available | Manual        |
| **3.1.6** Pronunciation                        | Mechanism for pronunciation                   | Manual        |
| **3.2.5** Change on Request                    | Context changes only on user request          | Manual        |
| **3.3.5** Help                                 | Context-sensitive help available              | Manual        |
| **3.3.6** Error Prevention (All)               | Reversible/submittable/checkable for all data | Manual        |
| **3.3.9** Accessible Authentication (Enhanced) | No cognitive test (stricter than 3.3.8)       | Manual        |

---

## Implementation Roadmap

### Phase 1: Foundation (Level A) - Weeks 1-4

**Goal**: Achieve Level A conformance across all new development

**Week 1-2: Content & Structure**

- [ ] Implement semantic HTML5 elements
- [ ] Add alt text to all images
- [ ] Ensure proper heading hierarchy (h1-h6)
- [ ] Add page titles
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

**Testing**: Run automated tests (axe, WAVE) + manual keyboard testing

### Phase 2: Enhanced (Level AA) - Weeks 5-10

**Goal**: Achieve Level AA conformance

**Week 5-6: Visual Design**

- [ ] Verify 4.5:1 contrast ratio for all text
- [ ] Ensure 3:1 contrast for UI components
- [ ] Test text resizing to 200%
- [ ] Verify reflow at 320px viewport

**Week 7: Navigation & Input**

- [ ] Implement multiple ways to find pages
- [ ] Ensure consistent navigation
- [ ] Make focus indicators visible
- [ ] Verify target sizes minimum 24x24px

**Week 8: Media & Content**

- [ ] Add audio descriptions to video
- [ ] Test content on hover/focus
- [ ] Verify text spacing doesn't break layout

**Week 9-10: Forms & Authentication**

- [ ] Implement error prevention for sensitive data
- [ ] Add error suggestions
- [ ] Provide accessible authentication methods
- [ ] Implement redundant entry prevention

**Testing**: Automated contrast checks + screen reader testing + manual testing

### Phase 3: Excellence (Level AAA) - Weeks 11-16

**Goal**: Achieve Level AAA where feasible

**Week 11-12: Enhanced Visuals**

- [ ] Achieve 7:1 contrast ratio for text
- [ ] Implement visual presentation controls
- [ ] Provide sign language interpretation (where feasible)
- [ ] Add extended audio descriptions

**Week 13-14: Enhanced Operability**

- [ ] Ensure all functionality via keyboard (no exceptions)
- [ ] Implement target size 44x44px
- [ ] Provide location information
- [ ] Implement focus appearance enhancements

**Week 15: Enhanced Content**

- [ ] Add unusual word definitions
- [ ] Provide abbreviation expansions
- [ ] Implement reading level analysis
- [ ] Add pronunciation guides

**Week 16: Polish**

- [ ] Implement change on request
- [ ] Add comprehensive help systems
- [ ] Error prevention for all data
- [ ] Final comprehensive testing

**Testing**: Full assistive technology testing + user testing with people with disabilities

---

## Test Cases by Category

### Automated Tests (Can be automated)

```javascript
// Example test suite structure
// Using axe-core, jest-axe, or similar

describe("WCAG 2.2 Automated Tests", () => {
  test("1.1.1 Non-text Content - All images have alt text", async () => {
    const results = await axe(container);
    expect(results).toHaveNoViolations("image-alt");
  });

  test("1.4.3 Contrast - Text meets minimum contrast", async () => {
    const results = await axe(container);
    expect(results).toHaveNoViolations("color-contrast");
  });

  test("1.4.11 Non-text Contrast - UI components meet contrast", async () => {
    // Requires custom implementation or visual regression
  });

  test("4.1.2 Name, Role, Value - Elements have accessible names", async () => {
    const results = await axe(container);
    expect(results).toHaveNoViolations("button-name");
    expect(results).toHaveNoViolations("aria-*");
  });

  test("2.5.8 Target Size - Interactive elements minimum 24x24px", () => {
    const targets = document.querySelectorAll(
      "button, a, input, select, textarea",
    );
    targets.forEach((target) => {
      const rect = target.getBoundingClientRect();
      expect(rect.width).toBeGreaterThanOrEqual(24);
      expect(rect.height).toBeGreaterThanOrEqual(24);
    });
  });
});
```

### Manual Tests (Must be tested manually)

```markdown
## Keyboard Accessibility Test Protocol

### 2.1.1 Keyboard

1. Unplug mouse/disable trackpad
2. Navigate entire page using only Tab key
3. Verify all interactive elements can be reached
4. Verify all functionality works with keyboard only
5. Test arrow keys, Enter, Space, Escape

**Expected Result**: All functionality available via keyboard

### 2.1.2 No Keyboard Trap

1. Tab into all interactive elements
2. Tab out of each element
3. Verify focus can leave all components

**Expected Result**: Focus never trapped

### 2.4.3 Focus Order

1. Tab through entire page
2. Verify logical order matches visual order
3. Check that focus doesn't jump unexpectedly

**Expected Result**: Focus order is logical and predictable

### 2.4.7 Focus Visible

1. Tab through all interactive elements
2. Verify visible focus indicator on each
3. Check contrast of focus indicator

**Expected Result**: Focus always clearly visible
```

### Screen Reader Tests

```markdown
## Screen Reader Test Protocol

### NVDA/JAWS (Windows) + VoiceOver (macOS)

#### 1.3.1 Info and Relationships

1. Navigate page with screen reader
2. Verify headings announced correctly
3. Verify list items announced
4. Verify table headers associated
5. Verify form labels associated

**Expected Result**: All structure and relationships conveyed

#### 4.1.3 Status Messages

1. Trigger form errors
2. Verify error messages announced
3. Trigger success messages
4. Verify announcements made
5. Verify loading states announced

**Expected Result**: Status messages conveyed programmatically

#### 2.4.4 Link Purpose

1. Navigate to all links
2. Verify link purpose clear from context
3. Verify no "click here" or "read more" alone

**Expected Result**: Link purpose determinable from link text + context
```

---

## Common Implementation Patterns

### Focus Management

```html
<!-- Skip link pattern -->
<a href="#main-content" class="skip-link">Skip to main content</a>
<main id="main-content" tabindex="-1">
  <!-- Main content -->
</main>
```

```css
/* Focus visible styles */
:focus-visible {
  outline: 3px solid #0056b3;
  outline-offset: 2px;
}

/* Skip link styling */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
  text-decoration: none;
}

.skip-link:focus {
  top: 0;
}
```

### Form Accessibility

```html
<!-- Proper label association -->
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

<!-- Fieldset for grouped controls -->
<fieldset>
  <legend>Preferred Contact Method</legend>
  <input type="radio" id="contact-email" name="contact" value="email" />
  <label for="contact-email">Email</label>
  <input type="radio" id="contact-phone" name="contact" value="phone" />
  <label for="contact-phone">Phone</label>
</fieldset>
```

### Accessible Authentication

```html
<!-- 3.3.8 Accessible Authentication (Minimum) - Allow password managers -->
<form>
  <label for="username">Username</label>
  <input type="text" id="username" name="username" autocomplete="username" />

  <label for="password">Password</label>
  <input
    type="password"
    id="password"
    name="password"
    autocomplete="current-password"
  />

  <!-- Alternative authentication method -->
  <button type="button" onclick="useMagicLink()">
    Email me a sign-in link
  </button>
</form>
```

### Target Size

```css
/* 2.5.8 Target Size (Minimum) - 24x24px */
.btn {
  min-width: 24px;
  min-height: 24px;
  padding: 8px 16px;
}

/* 2.5.5 Target Size (Enhanced) - 44x44px (AAA) */
.btn-aaa {
  min-width: 44px;
  min-height: 44px;
  padding: 12px 24px;
}
```

### Dragging Alternative

```html
<!-- 2.5.7 Dragging Movements - Provide single-pointer alternative -->
<div class="drag-container">
  <!-- Draggable item -->
  <div draggable="true" class="draggable">Item</div>

  <!-- Alternative: buttons for movement -->
  <div class="movement-controls">
    <button aria-label="Move up">↑</button>
    <button aria-label="Move down">↓</button>
    <button aria-label="Move left">←</button>
    <button aria-label="Move right">→</button>
  </div>
</div>
```

### Consistent Help

```html
<!-- 3.2.6 Consistent Help - Help in same location across pages -->
<header>
  <nav><!-- Main navigation --></nav>
  <a
    href="/help"
    class="help-link"
    style="position: absolute; top: 10px; right: 10px;"
  >
    Help
  </a>
</header>
```

### Redundant Entry Prevention

```javascript
// 3.3.7 Redundant Entry - Auto-populate known information
function populateShippingFromBilling() {
  const billingAddress = document.getElementById("billing-address").value;
  const shippingAddress = document.getElementById("shipping-address");

  shippingAddress.value = billingAddress;
  shippingAddress.setAttribute("aria-describedby", "auto-populated");
}
```

---

## Testing Tools

### Automated Tools

| Tool                 | Type              | Best For                   |
| -------------------- | ----------------- | -------------------------- |
| **axe DevTools**     | Browser extension | Developer testing          |
| **WAVE**             | Browser extension | Quick visual assessment    |
| **Lighthouse**       | Chrome DevTools   | CI/CD integration          |
| **Pa11y**            | CLI tool          | Automated testing pipeline |
| **jest-axe**         | Testing framework | Unit/integration tests     |
| **Playwright + Axe** | E2E testing       | Comprehensive automation   |

### Manual Testing

| Tool                         | Purpose                              |
| ---------------------------- | ------------------------------------ |
| **NVDA**                     | Windows screen reader                |
| **JAWS**                     | Windows screen reader (professional) |
| **VoiceOver**                | macOS/iOS screen reader              |
| **TalkBack**                 | Android screen reader                |
| **Color Contrast Analyzer**  | Contrast ratio testing               |
| **Keyboard-only navigation** | Testing 2.1.x criteria               |

---

## Compliance Checklist

### Pre-Launch AA Checklist

- [ ] All automated tests pass (axe, Lighthouse)
- [ ] Keyboard navigation tested and working
- [ ] Screen reader tested (NVDA/VoiceOver)
- [ ] Color contrast verified (4.5:1 for text)
- [ ] Text resizing tested to 200%
- [ ] Focus indicators visible and logical
- [ ] Form labels associated correctly
- [ ] Error messages accessible
- [ ] Skip link implemented
- [ ] Page titles descriptive
- [ ] Images have alt text
- [ ] Videos captioned
- [ ] Target size minimum 24x24px
- [ ] Focus not obscured

### AAA Enhancement Checklist

- [ ] Contrast ratio 7:1 achieved
- [ ] Target size 44x44px
- [ ] Focus appearance enhanced
- [ ] No cognitive tests for authentication
- [ ] Extended audio descriptions
- [ ] Sign language interpretation (if feasible)
- [ ] Reading level analysis complete
- [ ] Pronunciation guides available
- [ ] Location information provided

---

## Resources

### Official Documentation

- [WCAG 2.2 Specification](https://www.w3.org/TR/WCAG22/)
- [How to Meet WCAG 2.2](https://www.w3.org/WAI/WCAG22/quickref/)
- [Understanding WCAG 2.2](https://www.w3.org/WAI/WCAG22/Understanding/)
- [Techniques for WCAG 2.2](https://www.w3.org/WAI/WCAG22/Techniques/)

### Training & Guidance

- [WAI Tutorials](https://www.w3.org/WAI/tutorials/)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [Web Accessibility Perspectives](https://www.w3.org/WAI/perspective-videos/)

### Legal & Standards

- [Section 508](https://www.section508.gov/) (US)
- [EN 301 549](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/) (Europe)
- [European Accessibility Act](https://ec.europa.eu/social/main.jsp?catId=1202) (EU)

---

## Quick Reference: New in WCAG 2.2

| Criterion  | Level | Description                          |
| ---------- | ----- | ------------------------------------ |
| **2.4.11** | AA    | Focus Not Obscured (Minimum)         |
| **2.4.12** | AAA   | Focus Not Obscured (Enhanced)        |
| **2.4.13** | AAA   | Focus Appearance                     |
| **2.5.7**  | AA    | Dragging Movements                   |
| **2.5.8**  | AA    | Target Size (Minimum)                |
| **3.2.6**  | A     | Consistent Help                      |
| **3.3.7**  | A     | Redundant Entry                      |
| **3.3.8**  | AA    | Accessible Authentication (Minimum)  |
| **3.3.9**  | AAA   | Accessible Authentication (Enhanced) |

---

**Version**: WCAG 2.2 (October 2023)
**Last Updated**: 2024
**Target**: AAA Compliance (AA Minimum)
