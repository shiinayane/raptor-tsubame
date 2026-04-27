Below is a Raptor Project Code Quality Handbook distilled from everything we discussed.
It is written to guide architecture, consistency, and maintainability when building Swift-native sites with Raptor.

⸻

🧭 Raptor Project Code Quality Handbook

0. Core Philosophy

Do not “translate CSS.” Rebuild intent.

Raptor is not a templating engine. It is a design system + component architecture in Swift.

Your goal is:

Reference → Intent → Design System → Implementation

Not:

HTML → Swift
CSS → Property.xxx

⸻

1. Architectural Layers (Strict Separation)

Every project should follow this hierarchy:

Tokens → Styles → Components → Layouts → Pages

1.1 Tokens (Design Foundations)

Define only global primitives:

* Colors (Palette)
* Spacing / sizes (Metrics)
* Typography (Typography)
* Fonts

❗ Do NOT put semantic meaning here.

// ✅ Good
palette.textPrimary
metrics.sectionGap
typography.smallSize
// ❌ Bad
postMetaColor
readMorePadding
sidebarTitleFont

⸻

1.2 Styles (Semantic Visual Rules)

Styles are your real “theme”.

Each Style represents a visual concept, not a CSS fragment.

PostCardStyle
MetaRowStyle
ReadMoreStyle
CategoryLabelStyle

Rules

* Styles may use Property.xxx
* Styles may contain magic numbers (if local)
* Styles must represent intent, not implementation

// ✅ Good
ReadMoreStyle
// ❌ Bad
PaddingTop12Style
MarginLeft8Style

⸻

1.3 Components (Structure Only)

Components define structure and composition, not appearance.

PostListItem
PostMeta
PostExcerpt
PostReadMore

Rules

* No raw Property.xxx here (except layout glue)
* Use .style(...), not inline visual decisions
* No hardcoded colors / font sizes

⸻

1.4 Layouts (Page Skeleton)

Layouts define macro structure:

Navigation | Main | Aside

Example:

SiteLayout {
    NavigationPanel()
    MainContent()
    AsidePanel()
}

⸻

1.5 Pages (Composition Only)

Pages should only describe:

* What content exists
* How it is arranged

❗ Pages must NOT contain styling logic.

// ✅ Good
PostsList(posts)
// ❌ Bad
.style(Property.marginTop(.px(12)))

⸻

2. Styling Rules

2.1 Avoid Inline Property Usage in Pages

// ❌ Bad
VStack { ... }
    .style(Property.marginTop(.px(12)))
// ✅ Good
VStack { ... }
    .style(PostSectionStyle())

⸻

2.2 Property API Usage (Allowed Scope)

Use Property.xxx ONLY inside:

* Style
* Low-level layout glue (rare)

⸻

2.3 Replace CSS Concepts with Intent

CSS Pattern    Raptor Approach
float: right    Layout (Spacer / justify)
::after    Real component
margin hacks    Structure or Style
nested selectors    Component boundaries

⸻

2.4 Pseudo-elements → Real Components

.recent-info::after { ... }

→

RecentInfoAccentBar()

⸻

3. Layout Principles

3.1 Prefer Structure Over Margin

Instead of:

.style(Property.marginTop(.px(12)))

Use:

VStack(spacing: 12)

⸻

3.2 Spacing Strategy

* Use container spacing (VStack/HStack)
* Use padding only for element-specific shape
* Use margin only for layout exceptions

⸻

3.3 Avoid Mixing Spacing Systems

❌ Do NOT combine:

HStack(spacing: 8)
+ paddingRight(.px(5))

Choose one.

⸻

4. Typography System

4.1 Define Semantic Sizes

smallSize
mediumSize
largeSize

Not raw values everywhere.

⸻

4.2 Fonts Strategy

Global default

site.font(.system(.body))

Overrides

.font(theme.typography.metaFont)

⸻

4.3 Never Use Raw CSS font-family

// ❌ Avoid
.style(Property.fontFamily(...))
// ✅ Prefer
.font(...)

⸻

5. Link & Interaction Rules

5.1 Understand Link Constraints

* Link → inline content
* LinkGroup → grouped content (no nested links)

⸻

5.2 Avoid Nested Link Conflicts

If component contains:

* category links
* tag links

Then:

Do NOT wrap entire card in LinkGroup

⸻

5.3 Card Click Strategy

Choose one:

Option A (Recommended)

* Title clickable
* ReadMore clickable
* Tags clickable

Option B (Advanced)

* Overlay link (with z-index layering)

⸻

6. Handling CSS “Hacks”

6.1 Negative Margin

Allowed ONLY inside Style:

.style(Property.marginTop(.px(-21)))

⸻

6.2 Inline-block / Float

Replace with:

* Flex / layout structure
* Spacer
* width: 100%

⸻

7. Token Usage Rules

7.1 When to Create Tokens

Create token ONLY if:

* reused globally
* part of design language
* stable across components

⸻

7.2 When NOT to Create Tokens

Do NOT tokenize:

* readMoreOffset
* accentBarWidth
* one-off values

These belong in Style.

⸻

8. Development Workflow (Low Cognitive Load)

Step 1 — Structure First

Define component tree without styles.

Step 2 — Name Styles

Create semantic styles before filling them.

Step 3 — Implement Styles

Add visual rules gradually.

Step 4 — Refine Tokens

Only after patterns emerge.

Step 5 — Add Interaction (Hover / Responsive)

Never earlier.

⸻

9. Anti-Patterns

❌ CSS Translation Mindset

.style(Property.marginTop(.px(12)))
.style(Property.paddingLeft(.px(8)))

❌ Styling in Pages

Home.swift → visual logic

❌ Over-tokenization

metaRowGap
readMoreSpacing
tagOffset

❌ Component doing styling logic

⸻

10. Quality Checklist

Before committing:

* No visual logic in Pages
* Styles are semantic, not atomic
* Tokens are minimal and meaningful
* Layout uses structure, not hacks
* No unnecessary Property.xxx in components
* Fonts handled via Typography
* No nested link issues
* Pseudo-elements replaced by components

⸻

🧾 Final Principle

Swift-native ≠ No CSS

It means:

CSS is structured, named, and controlled — not scattered.

## Raptor Markup Discipline

Raptor Tsubame should preserve Raptor's declarative component intent. Swift components should describe site structure, `Style` types should own visual rules, and raw HTML/class escape hatches should stay limited to renderer boundaries.

Use `Style` types and `.style(...)` for visual classes. A generated class from a Raptor `Style` is expected and is not the same as hand-authoring arbitrary CSS classes in page code.

Use `data-*` markers only at component boundaries, route-level structures, or important state boundaries that tests or scoped CSS need to address. Do not add markers to every internal leaf node.

Use semantic HTML where Raptor exposes an appropriate primitive. Use `Div` or stack layout components only when the wrapper represents a real layout grouping such as a card, feed, metadata row, or responsive media/text split.

Rendered Markdown is an HTML string boundary. A single wrapper such as `data-markdown-content="true"` is acceptable there because the content is no longer a normal Raptor component tree.

Before adding a wrapper, answer: what structure does this represent, can an existing semantic element express it, and will a future maintainer understand why this node exists?
