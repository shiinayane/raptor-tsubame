# Article TOC Foundation Stage 7.2E Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an inline article TOC foundation with stable H2/H3 anchors while preserving a future migration path to sidebar TOC.

**Architecture:** Build a small outline pipeline that transforms already-rendered Markdown HTML, adds heading IDs, extracts reusable `ArticleOutline` data, and renders `ArticleTOC` as a standalone component. Keep `ArticleContent` responsible only for composition so `ArticleTOC` can later move to a sidebar slot without rewriting extraction.

**Tech Stack:** Swift 6.2, Raptor, Swift Testing, project-local Markdown publishing tests.

---

## Scope Notes

- Do not touch `Posts/posts/build-website-in-swift.md`; it may remain untracked and unrelated.
- Do not add JavaScript.
- Do not modify the global sidebar shell.
- Do not add a `toc` front matter field.
- Do not replace Raptor's Markdown renderer.
- Do not work around the known upstream multi-paragraph list-item bug from Stage 7.2D.
- Use English commit messages.

## File Structure

Create:

- `Sources/Content/ArticleOutline.swift`
  - Owns `ArticleOutline`, `ArticleOutlineItem`, `ArticleHeadingLevel`, and slug generation.

- `Sources/Content/ArticleRenderedMarkdown.swift`
  - Owns the HTML fragment transformation: heading IDs are injected into H2/H3 tags, and outline items are extracted from the same transformed result.

- `Sources/Components/Posts/ArticleTOC.swift`
  - Renders TOC markup from `ArticleOutline`. Does not know where it is placed.

- `Sources/Styles/Visual/ArticleTOCStyle.swift`
  - Styles the inline TOC card with existing theme palette values.

- `Tests/RaptorTsubameTests/Content/ArticleOutlineTests.swift`
  - Unit tests for slugging and heading transformation.

Modify:

- `Sources/Components/Posts/ArticleContent.swift`
  - Compute one `ArticleRenderedMarkdown` and pass it to `ArticleTOC` and `ArticleBody`.

- `Sources/Components/Posts/ArticleBody.swift`
  - Accept rendered Markdown instead of `Post`.

- `Sources/Components/Posts/MarkdownContent.swift`
  - Render a safe pre-rendered HTML fragment with the existing `data-markdown-content` marker.

- `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`
  - Add published-output assertions for TOC, heading IDs, and no-TOC short article behavior.

- `Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`
  - Add a small guard that Stage 7.2D compatibility markers still publish after TOC transformation.

## Task 1: Outline Model And Slugger

**Files:**
- Create: `Sources/Content/ArticleOutline.swift`
- Create: `Tests/RaptorTsubameTests/Content/ArticleOutlineTests.swift`

- [ ] **Step 1: Write failing slug tests**

Create `Tests/RaptorTsubameTests/Content/ArticleOutlineTests.swift`:

```swift
import Testing
@testable import RaptorTsubame

@Suite("Article outline")
struct ArticleOutlineTests {
    @Test("slugger normalizes headings and deduplicates IDs")
    func sluggerNormalizesAndDeduplicates() {
        var slugger = ArticleHeadingSlugger()

        #expect(slugger.slug(for: "Basic Inline Markup") == "basic-inline-markup")
        #expect(slugger.slug(for: "Basic Inline Markup") == "basic-inline-markup-2")
        #expect(slugger.slug(for: "  Swift & Raptor: Notes!  ") == "swift-raptor-notes")
        #expect(slugger.slug(for: "中文 标题") == "section-1")
        #expect(slugger.slug(for: "???") == "section-2")
    }

    @Test("outline stores stable heading data")
    func outlineStoresHeadingData() {
        let outline = ArticleOutline(
            items: [
                ArticleOutlineItem(id: "intro", title: "Intro", level: .h2),
                ArticleOutlineItem(id: "details", title: "Details", level: .h3)
            ]
        )

        #expect(!outline.isEmpty)
        #expect(outline.shouldRender)
        #expect(outline.items.map(\.id) == ["intro", "details"])
        #expect(outline.items.map(\.level) == [.h2, .h3])
    }

    @Test("single heading outline does not render TOC chrome")
    func singleHeadingOutlineDoesNotRender() {
        let outline = ArticleOutline(
            items: [
                ArticleOutlineItem(id: "intro", title: "Intro", level: .h2)
            ]
        )

        #expect(!outline.isEmpty)
        #expect(!outline.shouldRender)
    }
}
```

- [ ] **Step 2: Run the failing tests**

Run:

```bash
swift test --filter ArticleOutlineTests
```

Expected: FAIL because `ArticleHeadingSlugger`, `ArticleOutline`, `ArticleOutlineItem`, and `ArticleHeadingLevel` do not exist.

- [ ] **Step 3: Implement the model and slugger**

Create `Sources/Content/ArticleOutline.swift`:

```swift
import Foundation

struct ArticleOutline: Sendable, Equatable {
    let items: [ArticleOutlineItem]

    var isEmpty: Bool {
        items.isEmpty
    }

    var shouldRender: Bool {
        items.count >= 2
    }
}

struct ArticleOutlineItem: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let level: ArticleHeadingLevel
}

enum ArticleHeadingLevel: Int, Sendable, Equatable {
    case h2 = 2
    case h3 = 3
}

struct ArticleHeadingSlugger {
    private var countsByBase = [String: Int]()
    private var fallbackCount = 0

    mutating func slug(for title: String) -> String {
        let base = normalizedBase(for: title)
        let resolvedBase: String

        if base.isEmpty {
            fallbackCount += 1
            resolvedBase = "section-\(fallbackCount)"
        } else {
            resolvedBase = base
        }

        let count = (countsByBase[resolvedBase] ?? 0) + 1
        countsByBase[resolvedBase] = count

        return count == 1 ? resolvedBase : "\(resolvedBase)-\(count)"
    }

    private func normalizedBase(for title: String) -> String {
        var result = ""
        var lastWasHyphen = false

        for scalar in title.lowercased().unicodeScalars {
            if CharacterSet.alphanumerics.contains(scalar), scalar.isASCII {
                result.unicodeScalars.append(scalar)
                lastWasHyphen = false
            } else if !lastWasHyphen {
                result.append("-")
                lastWasHyphen = true
            }
        }

        return result.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
```

- [ ] **Step 4: Run the tests**

Run:

```bash
swift test --filter ArticleOutlineTests
```

Expected: PASS.

- [ ] **Step 5: Commit Task 1**

```bash
git add Sources/Content/ArticleOutline.swift Tests/RaptorTsubameTests/Content/ArticleOutlineTests.swift
git commit -m "feat: add article outline model"
```

## Task 2: Rendered Markdown Heading Transformation

**Files:**
- Create: `Sources/Content/ArticleRenderedMarkdown.swift`
- Modify: `Tests/RaptorTsubameTests/Content/ArticleOutlineTests.swift`

- [ ] **Step 1: Add failing transformation tests**

Append these tests inside `ArticleOutlineTests`:

```swift
    @Test("rendered markdown adds heading IDs and extracts outline")
    func renderedMarkdownAddsHeadingIDsAndExtractsOutline() {
        let rendered = ArticleRenderedMarkdown(
            html: """
            <div class="markdown" data-markdown-content="true">
              <h2>Basic Inline Markup</h2>
              <p>Body.</p>
              <h3>Details &amp; Examples</h3>
              <h2>Basic Inline Markup</h2>
            </div>
            """
        )

        #expect(rendered.html.contains(#"<h2 id="basic-inline-markup" data-article-heading-anchor="true">Basic Inline Markup</h2>"#))
        #expect(rendered.html.contains(#"<h3 id="details-examples" data-article-heading-anchor="true">Details &amp; Examples</h3>"#))
        #expect(rendered.html.contains(#"<h2 id="basic-inline-markup-2" data-article-heading-anchor="true">Basic Inline Markup</h2>"#))
        #expect(rendered.outline.items == [
            ArticleOutlineItem(id: "basic-inline-markup", title: "Basic Inline Markup", level: .h2),
            ArticleOutlineItem(id: "details-examples", title: "Details & Examples", level: .h3),
            ArticleOutlineItem(id: "basic-inline-markup-2", title: "Basic Inline Markup", level: .h2)
        ])
    }

    @Test("rendered markdown does not overwrite existing heading IDs")
    func renderedMarkdownPreservesExistingHeadingIDs() {
        let rendered = ArticleRenderedMarkdown(
            html: """
            <h2 id="custom-id">Custom Heading</h2>
            <h3>Child Heading</h3>
            """
        )

        #expect(rendered.html.contains(#"<h2 id="custom-id" data-article-heading-anchor="true">Custom Heading</h2>"#))
        #expect(rendered.outline.items.first?.id == "custom-id")
        #expect(rendered.outline.items.first?.title == "Custom Heading")
        #expect(rendered.outline.items.first?.level == .h2)
        #expect(rendered.outline.items.last?.id == "child-heading")
    }

    @Test("rendered markdown ignores h1 and deeper headings")
    func renderedMarkdownIgnoresUnsupportedHeadingLevels() {
        let rendered = ArticleRenderedMarkdown(
            html: """
            <h1>Page Title</h1>
            <h2>Included</h2>
            <h4>Not Included</h4>
            """
        )

        #expect(!rendered.html.contains(#"id="page-title""#))
        #expect(rendered.html.contains(#"id="included""#))
        #expect(!rendered.html.contains(#"id="not-included""#))
        #expect(rendered.outline.items.map(\.title) == ["Included"])
    }
```

- [ ] **Step 2: Run the failing tests**

Run:

```bash
swift test --filter ArticleOutlineTests
```

Expected: FAIL because `ArticleRenderedMarkdown` does not exist.

- [ ] **Step 3: Implement the transformer**

Create `Sources/Content/ArticleRenderedMarkdown.swift`:

```swift
import Foundation

struct ArticleRenderedMarkdown: Sendable, Equatable {
    let html: String
    let outline: ArticleOutline

    init(html: String) {
        let result = ArticleRenderedMarkdown.transform(html)
        self.html = result.html
        self.outline = ArticleOutline(items: result.items)
    }

    private static func transform(_ html: String) -> (html: String, items: [ArticleOutlineItem]) {
        let pattern = #"<h([23])([^>]*)>(.*?)</h\1>"#
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.dotMatchesLineSeparators, .caseInsensitive]
        ) else {
            return (html, [])
        }

        let nsRange = NSRange(html.startIndex..<html.endIndex, in: html)
        let matches = regex.matches(in: html, range: nsRange)

        var slugger = ArticleHeadingSlugger()
        var items = [ArticleOutlineItem]()
        var transformed = ""
        var cursor = html.startIndex

        for match in matches {
            guard
                let fullRange = Range(match.range(at: 0), in: html),
                let levelRange = Range(match.range(at: 1), in: html),
                let attributeRange = Range(match.range(at: 2), in: html),
                let contentRange = Range(match.range(at: 3), in: html),
                let level = ArticleHeadingLevel(rawValue: Int(html[levelRange]) ?? 0)
            else {
                continue
            }

            transformed += html[cursor..<fullRange.lowerBound]

            let attributes = String(html[attributeRange])
            let content = String(html[contentRange])
            let title = plainText(from: content)
            let existingID = attributeValue(named: "id", in: attributes)
            let id = existingID ?? slugger.slug(for: title)
            let rewrittenAttributes = headingAttributes(from: attributes, id: id)
            let replacement = "<h\(level.rawValue)\(rewrittenAttributes)>\(content)</h\(level.rawValue)>"

            transformed += replacement
            cursor = fullRange.upperBound
            items.append(ArticleOutlineItem(id: id, title: title, level: level))
        }

        transformed += html[cursor...]
        return (transformed, items)
    }
}

private func headingAttributes(from attributes: String, id: String) -> String {
    var attributes = attributes

    if attributeValue(named: "id", in: attributes) == nil {
        attributes += #" id="\#(id)""#
    }

    if attributeValue(named: "data-article-heading-anchor", in: attributes) == nil {
        attributes += #" data-article-heading-anchor="true""#
    }

    return attributes
}

private func attributeValue(named name: String, in attributes: String) -> String? {
    let pattern = #"\#(name)\s*=\s*"([^"]*)""#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
        return nil
    }

    let nsRange = NSRange(attributes.startIndex..<attributes.endIndex, in: attributes)
    guard
        let match = regex.firstMatch(in: attributes, range: nsRange),
        let valueRange = Range(match.range(at: 1), in: attributes)
    else {
        return nil
    }

    return String(attributes[valueRange])
}

private func plainText(from html: String) -> String {
    let withoutTags = html.replacingOccurrences(
        of: #"<[^>]+>"#,
        with: "",
        options: .regularExpression
    )

    return decodeHTMLEntities(in: withoutTags)
        .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

private func decodeHTMLEntities(in text: String) -> String {
    text
        .replacingOccurrences(of: "&amp;", with: "&")
        .replacingOccurrences(of: "&lt;", with: "<")
        .replacingOccurrences(of: "&gt;", with: ">")
        .replacingOccurrences(of: "&quot;", with: "\"")
        .replacingOccurrences(of: "&#39;", with: "'")
}
```

- [ ] **Step 4: Run the tests**

Run:

```bash
swift test --filter ArticleOutlineTests
```

Expected: PASS.

- [ ] **Step 5: Commit Task 2**

```bash
git add Sources/Content/ArticleRenderedMarkdown.swift Tests/RaptorTsubameTests/Content/ArticleOutlineTests.swift
git commit -m "feat: transform article heading anchors"
```

## Task 3: TOC Component And Article Composition

**Files:**
- Create: `Sources/Components/Posts/ArticleTOC.swift`
- Create: `Sources/Styles/Visual/ArticleTOCStyle.swift`
- Modify: `Sources/Components/Posts/ArticleContent.swift`
- Modify: `Sources/Components/Posts/ArticleBody.swift`
- Modify: `Sources/Components/Posts/MarkdownContent.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add failing published-output tests**

Append this test inside `SitePublishingTests`:

```swift
    @Test("article page renders inline TOC with matching heading anchors")
    func articlePageRendersInlineTOC() async throws {
        let harness = try await publishedSite()

        let page = try harness.contents(of: "posts/markdown-reading-lab/index.html")
        let main = try mainSlice(of: page)

        #expect(main.contains("data-article-toc=\"true\""))
        #expect(main.contains("data-article-toc-list=\"true\""))
        #expect(main.contains("data-article-toc-link=\"true\""))
        #expect(main.contains("href=\"#heading-level-two\""))
        #expect(main.contains("id=\"heading-level-two\""))
        #expect(main.contains("href=\"#heading-level-three\""))
        #expect(main.contains("id=\"heading-level-three\""))
        #expect(main.contains("data-article-heading-anchor=\"true\""))

        let toc = try articleTOCSlice(of: main)
        let body = try markdownSlice(of: main)
        #expect(toc.range(of: "href=\"#heading-level-two\"") != nil)
        #expect(body.range(of: "id=\"heading-level-two\"") != nil)
    }

    @Test("short article page does not render empty TOC chrome")
    func shortArticleDoesNotRenderTOC() async throws {
        let harness = try await publishedSite()

        let page = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        let main = try mainSlice(of: page)

        #expect(!main.contains("data-article-toc=\"true\""))
        #expect(main.contains("data-markdown-content=\"true\""))
    }
```

Add this helper near the other private helpers in `SitePublishingTests.swift`:

```swift
private func articleTOCSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-article-toc=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<nav", options: .backwards))
    let close = try #require(html[marker.upperBound...].range(of: "</nav>"))
    return String(html[openStart.lowerBound..<close.upperBound])
}
```

- [ ] **Step 2: Run the failing tests**

Run:

```bash
swift test --filter SitePublishingTests/articlePageRendersInlineTOC
```

Expected: FAIL because no TOC exists yet.

- [ ] **Step 3: Add raw HTML wrapper support**

Replace `Sources/Components/Posts/MarkdownContent.swift` with:

```swift
import Foundation
import Raptor

struct MarkdownContent: HTML {
    let renderedMarkdown: ArticleRenderedMarkdown

    init(renderedMarkdown: ArticleRenderedMarkdown) {
        self.renderedMarkdown = renderedMarkdown
    }

    var body: some HTML {
        RawHTML(renderedMarkdown.html)
            .data("markdown-content", "true")
    }
}

private struct RawHTML: HTML {
    let html: String

    init(_ html: String) {
        self.html = html
    }

    var body: Never { fatalError() }

    func render() -> Markup {
        Markup(html)
    }
}
```

- [ ] **Step 4: Update article body to accept rendered Markdown**

Replace `Sources/Components/Posts/ArticleBody.swift` with:

```swift
import Foundation
import Raptor

struct ArticleBody: HTML {
    let renderedMarkdown: ArticleRenderedMarkdown

    var body: some HTML {
        Tag("div") {
            MarkdownContent(renderedMarkdown: renderedMarkdown)
        }
        .style(ArticleBodyStyle())
        .data("article-body", "true")
    }
}
```

- [ ] **Step 5: Add TOC style**

Create `Sources/Styles/Visual/ArticleTOCStyle.swift`:

```swift
import Foundation
import Raptor

struct ArticleTOCStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.padding(.px(16)))
                .style(.borderRadius(.px(16)))
                .background(palette.surfaceRaised)
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.padding(.px(18)))
                .style(.borderRadius(.px(18)))
                .background(palette.surfaceRaised)
                .border(palette.border, width: 1, style: .solid)
        }
    }
}
```

This plan uses `surfaceRaised` because it already exists in `SiteThemePalette` and gives the TOC a subtle inset card without adding new palette tokens.

- [ ] **Step 6: Add TOC component**

Create `Sources/Components/Posts/ArticleTOC.swift`:

```swift
import Foundation
import Raptor

struct ArticleTOC: HTML {
    let outline: ArticleOutline

    var body: some HTML {
        if outline.shouldRender {
            Tag("nav") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Contents")
                        .font(.title5)
                    Tag("ol") {
                        ForEach(outline.items) { item in
                            Tag("li") {
                                Link(item.title, destination: "#\(item.id)")
                                    .data("article-toc-link", "true")
                            }
                            .data("article-toc-level", "\(item.level.rawValue)")
                        }
                    }
                    .data("article-toc-list", "true")
                }
            }
            .style(ArticleTOCStyle())
            .data("article-toc", "true")
            .attribute("aria-label", "Table of contents")
        }
    }
}
```

`ArticleOutlineItem` already conforms to `Identifiable` from Task 1, so `ForEach(outline.items)` has stable identity.

- [ ] **Step 7: Update article composition**

Replace `Sources/Components/Posts/ArticleContent.swift` with:

```swift
import Foundation
import Raptor

struct ArticleContent: HTML {
    let post: Post
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]
    let newer: Post?
    let older: Post?

    private var articleMarkdown: ArticleRenderedMarkdown {
        ArticleRenderedMarkdown(html: post.text.markupString())
    }

    var body: some HTML {
        let renderedMarkdown = articleMarkdown

        Tag("article") {
            VStack(alignment: .leading, spacing: 22) {
                ArticleHeader(post: post, category: category, tags: tags)
                ArticleTOC(outline: renderedMarkdown.outline)
                ArticleBody(renderedMarkdown: renderedMarkdown)
                ArticleNavigation(newer: newer, older: older)
            }
        }
        .style(ArticleSurfaceStyle())
        .data("article-page", "true")
    }
}
```

- [ ] **Step 8: Run focused publishing tests**

Run:

```bash
swift test --filter SitePublishingTests/articlePageRendersInlineTOC
swift test --filter SitePublishingTests/shortArticleDoesNotRenderTOC
```

Expected: PASS.

- [ ] **Step 9: Run broader publishing tests**

Run:

```bash
swift test --filter SitePublishingTests
```

Expected: PASS.

- [ ] **Step 10: Commit Task 3**

```bash
git add Sources/Components/Posts/ArticleTOC.swift Sources/Styles/Visual/ArticleTOCStyle.swift Sources/Components/Posts/ArticleContent.swift Sources/Components/Posts/ArticleBody.swift Sources/Components/Posts/MarkdownContent.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "feat: render inline article toc"
```

## Task 4: Compatibility Guards And Visual CSS Verification

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add compatibility guard assertions**

In `MarkdownCompatibilityPublishingTests.documentsSupportedMarkdownStructures`, add:

```swift
        #expect(markdown.contains("id=\"basic-inline-markup\""))
        #expect(markdown.contains("data-article-heading-anchor=\"true\""))
```

In `MarkdownCompatibilityPublishingTests.documentsHTMLCompatibilityBehavior`, keep all existing raw HTML and script assertions. Add this assertion:

```swift
        #expect(!markdown.contains(#"<script"#))
```

- [ ] **Step 2: Add TOC CSS marker assertions**

In `SitePublishingTests.publishedPagesIncludeBlueThemeVisualStyles`, add:

```swift
        let readingLab = try harness.contents(of: "posts/markdown-reading-lab/index.html")
        #expect(readingLab.contains("article-toc-style"))
        #expect(readingLab.contains("data-article-toc=\"true\""))
```

Do not leave tautological assertions in the final code.

- [ ] **Step 3: Run focused tests**

Run:

```bash
swift test --filter MarkdownCompatibilityPublishingTests
swift test --filter SitePublishingTests/publishedPagesIncludeBlueThemeVisualStyles
```

Expected: PASS.

- [ ] **Step 4: Commit Task 4**

```bash
git add Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "test: guard toc compatibility output"
```

## Task 5: Full Verification

**Files:**
- No source edits expected.

- [ ] **Step 1: Run focused outline tests**

```bash
swift test --filter ArticleOutlineTests
```

Expected: PASS.

- [ ] **Step 2: Run focused publishing tests**

```bash
swift test --filter SitePublishingTests
```

Expected: PASS.

- [ ] **Step 3: Run Markdown compatibility tests**

```bash
swift test --filter MarkdownCompatibilityPublishingTests
```

Expected: PASS. Existing Prism warning may appear and is not a failure.

- [ ] **Step 4: Run full test suite**

```bash
swift test
```

Expected: PASS. At this checkpoint the suite should report all tests passing. Existing Prism warning may appear and is not a failure.

- [ ] **Step 5: Generate the site**

```bash
swift run RaptorTsubame
```

Expected: exits 0 and publishes `Build/`. Existing Prism warning may appear and is not a failure.

- [ ] **Step 6: Inspect generated TOC output**

```bash
rg -n "data-article-toc|data-article-heading-anchor|href=\"#heading-level-two\"|id=\"heading-level-two\"" Build/posts/markdown-reading-lab/index.html
```

Expected: matches for the TOC root, heading anchor marker, TOC link, and matching heading ID.

- [ ] **Step 7: Inspect compatibility output**

```bash
rg -n "compat-multiparagraph-list-marker|data-compat-raw-html|&lt;/code&gt;&lt;script&gt;alert" Build/posts/markdown-compatibility-lab/index.html
```

Expected: matches remain present, proving TOC work did not hide Stage 7.2D compatibility behavior.

- [ ] **Step 8: Check git status**

```bash
git status --short
```

Expected: only intended Stage 7.2E changes before final commit, plus unrelated `?? Posts/posts/build-website-in-swift.md` if still present.

## Task 6: Final Review And Commit Hygiene

**Files:**
- No source edits expected unless review finds a blocker.

- [ ] **Step 1: Inspect final diff**

```bash
git diff --stat
git diff -- Sources Tests docs
```

Expected: changes are limited to article outline/TOC source, article composition, and tests. No global sidebar shell changes. No JavaScript.

- [ ] **Step 2: Confirm no forbidden scope slipped in**

Run:

```bash
rg -n "scroll|spy|sticky|localStorage|addEventListener|toc:" Sources Tests Posts docs/superpowers/plans/2026-04-26-article-toc-foundation-stage7-2e.md
```

Expected: no implementation of scroll spy, sticky behavior, JavaScript, or front matter `toc:`. Mentions in the plan/spec as non-goals are acceptable.

- [ ] **Step 3: Commit any remaining verified changes**

If Task 5 or review produced additional fixes:

```bash
git add <verified-stage-7-2e-files>
git commit -m "test: stabilize article toc output"
```

If there are no remaining unstaged changes, do not create an empty commit.

- [ ] **Step 4: Final status**

```bash
git status --short
git log --oneline -8
```

Expected: working tree contains no Stage 7.2E tracked changes. Unrelated `Posts/posts/build-website-in-swift.md` may remain untracked.

## Self-Review Checklist

- Spec coverage: Tasks cover outline model, slugging, heading IDs, inline TOC, migration-friendly component separation, no sidebar change, no JavaScript, no front matter switch, and compatibility guards.
- Placeholder scan: This plan intentionally avoids TBD/TODO placeholders and uses public Raptor APIs verified in the local checkout.
- Type consistency: `ArticleRenderedMarkdown`, `ArticleOutline`, `ArticleOutlineItem`, `ArticleHeadingLevel`, `ArticleTOC`, and `ArticleTOCStyle` are introduced before use in later tasks.
- Scope control: `Posts/posts/build-website-in-swift.md` is unrelated local content and must not be used as a required test fixture or staged unless the user explicitly asks.
