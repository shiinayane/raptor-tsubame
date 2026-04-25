# Markdown Compatibility Audit Stage 7.2D Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create an audit-only Markdown compatibility baseline for Tsubame's Raptor article pipeline.

**Architecture:** Add a dedicated published fixture page rendered through `ArticlePage`, then assert generated HTML behavior from a focused publishing test file. Document supported, degraded, broken, and upstream-owned Markdown patterns in a root docs audit file. Do not change `SafeMarkdownToHTML`, Raptor renderer behavior, Markdown CSS, or visual styling in this stage.

**Tech Stack:** Swift 6.2, Raptor `PostPage` publishing, Swift Testing, generated HTML/CSS assertions, Markdown docs.

---

## File Structure

- Create `Posts/pages/markdown-compatibility-lab.md`: Markdown fixture rendered through the real article pipeline but excluded from homepage/archive counts by `kind: page`.
- Create `Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`: route, supported behavior, and known-broken behavior assertions.
- Create `docs/markdown-compatibility-audit.md`: compatibility matrix and authoring guidance.
- Modify `docs/upstream-raptor-markdown-list-paragraph-bug.md`: add a short link to the compatibility audit after audit results exist.

Do not modify:

- `Sources/Markdown/SafeMarkdownToHTML.swift`
- `Assets/css/markdown-reading.css`
- article navigation files
- `Posts/posts/build-website-in-swift.md`

## Task 1: Fixture Route And Isolation Baseline

**Files:**
- Create: `Posts/pages/markdown-compatibility-lab.md`
- Create: `Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`

- [ ] **Step 1: Write the failing route/isolation tests**

Create `Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`:

```swift
import Testing

@Suite("Markdown compatibility publishing", .serialized)
struct MarkdownCompatibilityPublishingTests {
    @Test("publishes markdown compatibility lab through article pipeline")
    func publishesCompatibilityLab() async throws {
        let harness = try await publishedSite()

        #expect(harness.fileExists("posts/markdown-compatibility-lab/index.html"))

        let page = try harness.contents(of: "posts/markdown-compatibility-lab/index.html")
        let main = try mainSlice(of: page)
        let markdown = try compatibilityMarkdownSlice(of: main)

        #expect(main.contains("data-article-page=\"true\""))
        #expect(main.contains("Markdown Compatibility Lab"))
        #expect(markdown.contains("data-markdown-content=\"true\""))
        #expect(markdown.contains("compat-basic-paragraph-marker"))
        #expect(markdown.contains("compat-fenced-html-code-marker"))
    }

    @Test("compatibility lab does not affect post indexes or taxonomy counts")
    func compatibilityLabDoesNotAffectPostIndexes() async throws {
        let harness = try await publishedSite()

        let homepage = try harness.contents(of: "index.html")
        let archive = try harness.contents(of: "archive/index.html")
        let tags = try harness.contents(of: "tags/index.html")
        let categories = try harness.contents(of: "categories/index.html")

        #expect(!homepage.contains("Markdown Compatibility Lab"))
        #expect(!archive.contains("Markdown Compatibility Lab"))
        #expect(tags.contains("Raptor (2)"))
        #expect(categories.contains("Notes (2)"))
    }
}

private func compatibilityMarkdownSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-markdown-content=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let end = html[marker.upperBound...].range(of: "data-article-navigation")?.lowerBound ?? html.endIndex
    return String(html[openStart.lowerBound..<end])
}
```

- [ ] **Step 2: Run the route test and confirm it fails**

Run:

```bash
swift test --filter MarkdownCompatibilityPublishingTests/publishesCompatibilityLab
```

Expected: FAIL because `posts/markdown-compatibility-lab/index.html` does not exist yet.

- [ ] **Step 3: Add the compatibility fixture**

Create `Posts/pages/markdown-compatibility-lab.md`:

````markdown
---
title: Markdown Compatibility Lab
date: 2026-04-26
description: Fixture for auditing Raptor Markdown compatibility in Tsubame.
kind: page
layout: ArticlePage
path: /posts/markdown-compatibility-lab/
published: true
category: Notes
tags: Raptor, Markdown
---

# Markdown Compatibility Lab

compat-basic-paragraph-marker: This page audits Markdown structures rendered through the Tsubame article pipeline.

## Basic Inline Markup

compat-inline-marker: This paragraph includes **strong text**, *emphasis*, [an external link](https://example.com), and `inline code`.

![Compatibility image marker](/images/tsubame-cover.svg)

## Ordered And Unordered Lists

compat-basic-list-marker:

1. First ordered item
2. Second ordered item

- First unordered item
- Second unordered item

## Nested Lists

compat-nested-list-marker:

1. Parent ordered item
   - Nested unordered child
   - Nested unordered sibling
2. Second parent ordered item

## Multi-Paragraph List Item

compat-multiparagraph-list-marker:

1. **"Elegant" abstractions can be misleading**

   A unified system looks great on paper, but may not fit the existing architecture.

2. Second item after the known bug sample

## List Item With Blockquote

compat-list-blockquote-marker:

1. List item before quote

   > A quote nested under a list item should remain visibly distinct.

2. List item after quote

## List Item With Fenced Code

compat-list-code-marker:

1. List item before code

   ```swift
   let nested = "code"
   print(nested)
   ```

2. List item after code

## Blockquote With Multiple Paragraphs

compat-blockquote-marker:

> First paragraph in a blockquote.
>
> Second paragraph in the same blockquote.

## Table

compat-table-marker:

| Pattern | Status |
| --- | --- |
| Table rendering | Supported |
| Wide content | Scroll candidate |

---

compat-hr-marker: Text after a horizontal rule.

## Raw HTML And HTML Code

compat-raw-html-marker:

<div data-compat-raw-html="true">Raw HTML should render as HTML.</div>

compat-inline-html-marker: <span data-compat-inline-html="true">Inline HTML should render as HTML.</span>

compat-fenced-html-code-marker:

Inline hostile code: `</code><script>alert("inline")</script>`.

```html
</code><script>alert("block")</script>
```

compat-existing-entity-marker: `&lt;already escaped="true"&gt;`
````

- [ ] **Step 4: Run route/isolation tests**

Run:

```bash
swift test --filter MarkdownCompatibilityPublishingTests
```

Expected: PASS for the two tests.

- [ ] **Step 5: Commit fixture and baseline tests**

```bash
git add Posts/pages/markdown-compatibility-lab.md Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift
git commit -m "test: add markdown compatibility fixture"
```

## Task 2: Supported And Known-Broken Behavior Tests

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`

- [ ] **Step 1: Add supported behavior tests**

Append these tests inside `MarkdownCompatibilityPublishingTests`:

```swift
    @Test("documents supported markdown structures")
    func documentsSupportedMarkdownStructures() async throws {
        let markdown = try await compatibilityMarkdown()
        let page = try await compatibilityPage()
        let head = try headSlice(of: page)

        #expect(head.contains("href=\"/css/markdown-reading.css\""))
        #expect(markdown.contains("<h2>Basic Inline Markup</h2>"))
        #expect(markdown.contains("<strong>strong text</strong>"))
        #expect(markdown.contains("<em>emphasis</em>"))
        #expect(markdown.contains("href=\"https://example.com\""))
        #expect(markdown.contains("<code>inline code</code>"))
        #expect(markdown.contains("<img src=\"/images/tsubame-cover.svg\""))
        #expect(markdown.contains("<ol>"))
        #expect(markdown.contains("<ul>"))
        #expect(markdown.contains("<blockquote>"))
        #expect(markdown.contains("<table>"))
        #expect(markdown.contains("<hr"))
    }

    @Test("documents raw HTML and HTML code behavior")
    func documentsHTMLCompatibilityBehavior() async throws {
        let markdown = try await compatibilityMarkdown()

        #expect(markdown.contains("data-compat-raw-html=\"true\""))
        #expect(markdown.contains("data-compat-inline-html=\"true\""))
        #expect(markdown.contains("&lt;/code&gt;&lt;script&gt;alert(\"inline\")&lt;/script&gt;"))
        #expect(markdown.contains("&lt;/code&gt;&lt;script&gt;alert(\"block\")&lt;/script&gt;"))
        #expect(markdown.contains("&lt;already escaped=\"true\"&gt;"))
        #expect(!markdown.contains(#"<script>alert("inline")</script>"#))
        #expect(!markdown.contains(#"<script>alert("block")</script>"#))
    }
```

Add these private helpers below `compatibilityMarkdownSlice(of:)`:

```swift
private func compatibilityPage() async throws -> String {
    let harness = try await publishedSite()
    return try harness.contents(of: "posts/markdown-compatibility-lab/index.html")
}

private func compatibilityMarkdown() async throws -> String {
    let page = try await compatibilityPage()
    return try compatibilityMarkdownSlice(of: try mainSlice(of: page))
}

private func headSlice(of html: String) throws -> String {
    let headOpen = try #require(html.range(of: "<head"))
    let headClose = try #require(html.range(of: "</head>"))
    return String(html[headOpen.lowerBound..<headClose.upperBound])
}
```

- [ ] **Step 2: Add known-broken behavior test**

Append this test inside `MarkdownCompatibilityPublishingTests`:

```swift
    @Test("documents current Raptor flattening of multi-paragraph list items")
    func documentsCurrentRaptorListParagraphFlattening() async throws {
        let markdown = try await compatibilityMarkdown()

        let marker = try #require(markdown.range(of: "compat-multiparagraph-list-marker"))
        let sampleEnd = try #require(markdown[marker.upperBound...].range(of: "Second item after the known bug sample"))
        let sample = String(markdown[marker.lowerBound..<sampleEnd.upperBound])

        #expect(sample.contains(#"<strong>"Elegant" abstractions can be misleading</strong>A unified system looks great on paper"#))
        #expect(!sample.contains(#"<p><strong>"Elegant" abstractions can be misleading</strong></p>"#))
        #expect(!sample.contains(#"<p>A unified system looks great on paper"#))
    }
```

- [ ] **Step 3: Run compatibility tests**

Run:

```bash
swift test --filter MarkdownCompatibilityPublishingTests
```

Expected: PASS. The multi-paragraph list test passes by documenting the current upstream bug, not by fixing it.

- [ ] **Step 4: Commit compatibility behavior tests**

```bash
git add Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift
git commit -m "test: document markdown compatibility behavior"
```

## Task 3: Compatibility Audit Documentation

**Files:**
- Create: `docs/markdown-compatibility-audit.md`
- Modify: `docs/upstream-raptor-markdown-list-paragraph-bug.md`

- [ ] **Step 1: Create the audit document**

Create `docs/markdown-compatibility-audit.md`:

```markdown
# Markdown Compatibility Audit

## Overview

This document records how Raptor Markdown currently renders inside Tsubame's article pipeline. It is an authoring reference and a regression baseline, not a renderer replacement plan.

The audit fixture is published at:

- `/posts/markdown-compatibility-lab/`

The fixture source is:

- `Posts/pages/markdown-compatibility-lab.md`

The publishing tests are:

- `Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`

## Compatibility Matrix

| Pattern | Status | Notes |
| --- | --- | --- |
| Basic paragraphs | Supported | Regular paragraphs render as `<p>` outside lists. |
| Headings | Supported | Heading levels render as heading elements and inherit Stage 7.2C typography. |
| Strong/emphasis/link | Supported | Basic inline markup renders correctly. |
| Inline code | Supported | Inline code is escaped by `SafeMarkdownToHTML` before Raptor rendering. |
| Images | Supported | Markdown images render as `<img>` and are styled by the scoped Markdown CSS. |
| Ordered/unordered lists | Supported | Simple list structures render as list elements. |
| Nested lists | Degraded | Nested lists render, but complex spacing depends on Raptor's list paragraph behavior. |
| Multi-paragraph list items | Broken, Upstream | Raptor currently flattens paragraphs inside list items. |
| List item with blockquote | Degraded | Usable for simple content, but list paragraph flattening can affect surrounding separation. |
| List item with fenced code | Degraded | Code remains visible, but surrounding list paragraph structure should be checked in generated output. |
| Blockquote with multiple paragraphs | Supported | Current output keeps the blockquote visible and readable. |
| Tables | Supported | Tables render as table markup and use the scoped Markdown CSS. |
| Horizontal rules | Supported | Horizontal rules render and are styled by scoped Markdown CSS. |
| Raw HTML blocks | Supported by design | Raw HTML intentionally renders as HTML. |
| Inline HTML | Supported by design | Inline HTML intentionally renders as HTML. |
| Fenced HTML code | Supported | HTML code remains visible as escaped text. |
| Existing escaped entities in code | Supported | Existing entities remain stable enough for authoring examples. |

## Authoring Guidance

- Avoid multi-paragraph list items until the upstream Raptor list paragraph issue is fixed.
- If paragraph separation matters, write the explanatory paragraph after the list instead of inside the list item.
- Use fenced code blocks for HTML examples.
- Use raw HTML only when the article intentionally needs real HTML output.
- Inspect generated output for complex nested list, blockquote, or code-in-list structures before publishing.

## Known Upstream Issues

### Multi-Paragraph List Items Are Flattened

Documented separately:

- `docs/upstream-raptor-markdown-list-paragraph-bug.md`

Summary:

Raptor's `MarkdownToHTML.visitParagraph(_:)` omits paragraph wrappers for paragraphs inside lists, and `visitListItem(_:)` concatenates child output directly. This causes multi-paragraph list items to lose visible separation.

## Local Workaround Candidates

No local workaround is implemented in Stage 7.2D.

Potential future local workarounds:

- A fuller custom Markdown renderer that preserves list paragraph structure.
- A narrow post-processing pass for known list paragraph patterns.

Both options are intentionally deferred because they increase renderer ownership inside Tsubame.
```

- [ ] **Step 2: Link the audit from the upstream bug note**

Append this section to `docs/upstream-raptor-markdown-list-paragraph-bug.md`:

```markdown

## Compatibility Audit Link

The broader Tsubame Markdown compatibility audit is tracked in:

- `docs/markdown-compatibility-audit.md`

The audit keeps this upstream bug visible alongside other Markdown behaviors without adding a local renderer workaround.
```

- [ ] **Step 3: Run documentation sanity checks**

Run:

```bash
rg -n "Multi-Paragraph List Items|markdown-compatibility-lab|upstream-raptor-markdown-list-paragraph-bug" docs/markdown-compatibility-audit.md docs/upstream-raptor-markdown-list-paragraph-bug.md
```

Expected: matches in both docs.

- [ ] **Step 4: Commit audit docs**

```bash
git add docs/markdown-compatibility-audit.md docs/upstream-raptor-markdown-list-paragraph-bug.md
git commit -m "docs: audit markdown compatibility"
```

## Task 4: Full Verification

**Files:**
- Verify all files from Tasks 1-3.
- Do not stage `Posts/posts/build-website-in-swift.md`.

- [ ] **Step 1: Run compatibility tests**

Run:

```bash
swift test --filter MarkdownCompatibilityPublishingTests
```

Expected: PASS.

- [ ] **Step 2: Run full test suite**

Run:

```bash
swift test
```

Expected: PASS. The existing non-fatal Prism `prism-html` warning may appear during publishing tests.

- [ ] **Step 3: Generate the site**

Run:

```bash
swift run RaptorTsubame
```

Expected: exit 0. Existing non-fatal Prism `prism-html` warning may appear.

- [ ] **Step 4: Inspect generated audit output**

Run:

```bash
rg -n "compat-multiparagraph-list-marker|Elegant|data-compat-raw-html|markdown-reading.css" Build/posts/markdown-compatibility-lab/index.html Build/css/markdown-reading.css
```

Expected:

- `Build/posts/markdown-compatibility-lab/index.html` contains the compatibility markers.
- `Build/posts/markdown-compatibility-lab/index.html` links `/css/markdown-reading.css`.
- `Build/css/markdown-reading.css` exists and contains scoped Markdown rules.

- [ ] **Step 5: Check git status**

Run:

```bash
git status --short
```

Expected: no unstaged implementation changes. `?? Posts/posts/build-website-in-swift.md` may remain and must not be staged.

## Self-Review Checklist

- Spec coverage: fixture, published-output tests, compatibility matrix, known upstream bug, and audit-only scope are all covered.
- Placeholder scan: no placeholder markers or vague test instructions.
- Scope check: no local Markdown renderer workaround is included.
- Risk check: tests that document broken behavior are explicitly named and documented as current upstream behavior.
