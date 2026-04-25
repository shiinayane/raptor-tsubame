# Markdown Compatibility Audit Stage 7.2D Design

## Goal

Stage 7.2D audits Raptor Markdown behavior as used by Tsubame. It creates a reproducible compatibility fixture, published-output tests, and a human-readable compatibility matrix so future article work does not depend on assumptions about Markdown rendering.

This stage is audit-only. It must not introduce a local workaround for upstream Markdown renderer bugs.

## Context

Stage 7.2C added article reading typography, safe HTML-code handling, and article navigation polish. During review, we found an upstream Raptor bug: multi-paragraph list items are flattened because Raptor's `MarkdownToHTML` drops paragraph wrappers inside lists and concatenates list item children directly.

That issue is documented in:

- `docs/upstream-raptor-markdown-list-paragraph-bug.md`

The next step should not be a reactive local renderer rewrite. First, the project needs a broader compatibility audit to identify which Markdown patterns are safe, degraded, or broken.

## Scope

Stage 7.2D includes compatibility coverage for:

- Basic paragraphs, headings, emphasis, links, inline code, and images.
- Ordered and unordered lists.
- Nested lists.
- Multi-paragraph list items.
- List items containing blockquotes.
- List items containing fenced code blocks.
- Blockquotes with multiple paragraphs.
- Tables.
- Horizontal rules.
- Raw HTML blocks.
- Inline HTML.
- Fenced HTML code.
- Existing entity handling in inline and fenced code.

Stage 7.2D excludes:

- Fixing multi-paragraph list rendering locally.
- Replacing Raptor's Markdown renderer.
- Adding TOC, heading anchors, admonitions, or code-copy behavior.
- Adding new visual styling beyond existing Stage 7.2C Markdown CSS.
- Submitting the upstream issue. This stage may prepare evidence for it, but issue submission is a separate action.

## Architecture

Use a dedicated Markdown fixture page, separate from real posts:

- `Posts/pages/markdown-compatibility-lab.md`
- `kind: page`
- `layout: ArticlePage`
- `path: /posts/markdown-compatibility-lab/`
- `published: true`

This keeps the fixture publishable through the real article pipeline while avoiding homepage/archive post-count changes.

Add a focused test file instead of continuing to grow `SitePublishingTests.swift`:

- `Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`

The tests should use the existing `publishedSite()` harness and shared HTML helpers. They should assert behavior from generated HTML, not internal parser state.

Add a documentation artifact:

- `docs/markdown-compatibility-audit.md`

This document should classify each audited Markdown pattern as:

- `Supported`: rendered with correct enough structure for Tsubame.
- `Degraded`: usable but structure or styling is imperfect.
- `Broken`: output loses semantics or visible content.
- `Upstream`: should be reported/fixed in Raptor.
- `Local candidate`: may deserve a future Tsubame workaround if upstream is slow or content impact is high.

## Expected Findings Policy

Some tests should intentionally document current broken behavior instead of forcing a fix in this stage.

For example, multi-paragraph list items should be asserted as currently broken and linked to the upstream bug doc. This makes the compatibility baseline explicit without pretending the project has solved it.

If a test documents a broken behavior, its name should make that clear, for example:

```swift
@Test("documents current Raptor flattening of multi-paragraph list items")
```

Avoid tests that simply encode bad output without explaining why it is allowed to pass for this audit stage.

## Fixture Requirements

The fixture should be easy to inspect in generated HTML. Each section should have a unique text marker, such as:

- `compat-basic-paragraph-marker`
- `compat-nested-list-marker`
- `compat-multiparagraph-list-marker`
- `compat-list-blockquote-marker`
- `compat-list-code-marker`
- `compat-raw-html-marker`
- `compat-fenced-html-code-marker`

Use visible prose, not hidden comments, so local browser inspection remains straightforward.

The fixture should include the known list bug pattern:

```markdown
1. **"Elegant" abstractions can be misleading**

   A unified system looks great on paper, but may not fit the existing architecture.
```

It should also include hostile-but-safe HTML code examples already covered by `SafeMarkdownToHTMLTests`, so the published article path remains covered:

````markdown
Inline hostile code: `</code><script>alert("inline")</script>`.

```html
</code><script>alert("block")</script>
```
````

## Testing Strategy

Tests should cover three kinds of assertions.

Route and fixture assertions:

- The compatibility lab page publishes at `/posts/markdown-compatibility-lab/`.
- It renders inside `ArticlePage`.
- It includes `data-markdown-content="true"`.
- It does not affect homepage pagination, archive post counts, tag counts, or category counts.

Supported behavior assertions:

- Headings render as headings.
- Tables render as table markup.
- Raw HTML blocks remain raw.
- Fenced HTML code remains escaped text.
- Inline hostile code remains escaped text.
- Markdown CSS is linked from `<head>`.

Known broken behavior assertions:

- Multi-paragraph list item output is currently flattened.
- The test should assert the current failure shape only in a clearly named "documents current bug" test.
- The docs should classify this as `Broken` and `Upstream`.

## Documentation Strategy

`docs/markdown-compatibility-audit.md` should be concise and useful while writing real posts. Recommended structure:

- Overview
- Compatibility matrix
- Authoring guidance
- Known upstream issues
- Local workaround candidates

The authoring guidance should be practical. For example:

- Avoid multi-paragraph list items until upstream is fixed.
- Prefer separate paragraphs after a list when paragraph separation matters.
- Use fenced code blocks for HTML examples; raw HTML is intentionally rendered as HTML.

## Visual Acceptance

This stage does not introduce new visual design. Visual acceptance is limited to confirming that the fixture remains readable under the existing Stage 7.2C Markdown CSS.

No browser-driven visual polish is required unless the audit reveals a severe CSS regression unrelated to upstream renderer structure.

## Risks

The main risk is turning the audit into a renderer rewrite. This is explicitly out of scope.

Another risk is writing tests that normalize broken behavior without explanation. Avoid this by naming tests clearly and documenting whether the behavior is supported, degraded, broken, or upstream-owned.

## Completion Criteria

Stage 7.2D is complete when:

- The design and implementation plan exist.
- The compatibility fixture is published.
- Published-output tests cover supported and known-broken cases.
- `docs/markdown-compatibility-audit.md` documents the findings.
- Existing Stage 7.2C reading behavior still passes.
- `swift test` passes.
- `swift run RaptorTsubame` succeeds with no new warnings beyond the existing Prism `prism-html` warning.
