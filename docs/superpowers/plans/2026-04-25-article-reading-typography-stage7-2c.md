# Article Reading Typography Stage 7.2C Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build scoped Markdown reading typography for article bodies while proving HTML/code examples remain visible and safe.

**Architecture:** Keep `ArticlePage`/`ArticleContent`/`ArticleBody`/`MarkdownContent` as the article structure. Use published-output tests first to lock down Markdown descendants and the HTML-code failure mode, then add a custom Raptor `PostProcessor` wrapper only if the default processor emits unescaped code. Add reading typography through a narrowly scoped CSS resource under `[data-markdown-content="true"]`, borrowing Fuwari's wrapper-scoped architecture without copying its plugins or Tailwind classes.

**Tech Stack:** Swift 6.2, Raptor public `Site.postProcessor`/`PostProcessor`/`HTML` APIs, Swift Testing, target resources under `Sources/Resources`, generated `Build/` HTML/CSS inspection.

---

## Scope

Stage 7.2C includes:

- Scoped article-body typography for headings, paragraphs, lists, blockquotes, tables, links, inline code, fenced code, images, and horizontal rules.
- A fixture article that exercises reading typography and raw/fenced HTML differences.
- A project-level safety guard if Raptor's default Markdown processor leaves fenced/inline HTML code unescaped.
- A small article-navigation visual cleanup that remains article-only.

Stage 7.2C does not include TOC, heading anchors, code-copy buttons, admonitions, related posts, search, discovery pages, JavaScript interactions, or a Markdown parser replacement.

## File Structure

- Create `Posts/pages/markdown-reading-lab.md`: published article-page fixture for Markdown reading semantics without changing homepage/archive post counts.
- Modify `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`: add route/output assertions for Markdown descendants, escaped HTML code, raw HTML, generated CSS scope, and article navigation markers.
- Create `Sources/Markdown/SafeMarkdownToHTML.swift`: custom processor based on Raptor's public `PostProcessor`, delegating to `MarkdownToHTML` and escaping only code-block/inline-code bodies in the rendered output if the default processor does not already escape them.
- Modify `Sources/App/Site.swift`: opt `ExampleSite` into `SafeMarkdownToHTML` through `var postProcessor`.
- Create `Sources/Resources/css/markdown-reading.css`: scoped reading CSS appended by Raptor's optional CSS resource loader to `Build/css/raptor-core.css`.
- Modify `Sources/Components/Posts/ArticleNavigation.swift`: add stable link markers and card-like wrappers for newer/older links.
- Create `Sources/Styles/Visual/ArticleNavigationStyle.swift`: article-only navigation/card styles using existing blue theme palette.
- Modify `Sources/Components/Posts/ArticleStyleSeed.swift`: seed article navigation styles.

Do not stage or commit the existing untracked user draft `Posts/posts/build-website-in-swift.md`.

## Task 1: Fixture And RED Published-Output Tests

**Files:**
- Create: `Posts/pages/markdown-reading-lab.md`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add the Markdown reading fixture**

Create `Posts/pages/markdown-reading-lab.md`:

````markdown
---
title: Markdown Reading Lab
date: 2026-04-10
description: Fixture for Stage 7.2C Markdown reading typography.
kind: page
layout: ArticlePage
path: /posts/markdown-reading-lab/
published: true
category: Notes
tags: Raptor, Markdown
---

# Markdown Reading Lab

Intro paragraph with [a reference link](https://example.com) and `inline code`.

## Heading Level Two

Body copy after a second-level heading should keep a readable measure and rhythm.

### Heading Level Three

- First unordered item
- Second unordered item with `list inline code`

1. First ordered item
2. Second ordered item

> A quoted note for reading typography.

| Feature | Status |
| --- | --- |
| Tables | Visible |

Inline HTML code sample: `<span class="inline-html-code">inline</span>`.

```swift
let greeting = "Hello"
print(greeting)
```

```html
<div class="html-code-sample">Hello HTML</div>
```

<div data-raw-html-fixture="true">Raw HTML should render as HTML.</div>

---

![Tiny inline SVG](/images/tsubame-cover.svg)
````

- [ ] **Step 2: Add tests that define the required output**

Append these tests inside `SitePublishingTests` before the closing `}` of the suite:

```swift
    @Test("article markdown lab publishes scoped reading markup")
    func publishesMarkdownReadingLab() async throws {
        let harness = try await publishedSite()

        #expect(harness.fileExists("posts/markdown-reading-lab/index.html"))

        let page = try harness.contents(of: "posts/markdown-reading-lab/index.html")
        let main = try mainSlice(of: page)
        let markdown = try markdownSlice(of: main)

        #expect(main.contains("data-article-page=\"true\""))
        #expect(markdown.contains("data-markdown-content=\"true\""))
        #expect(markdown.contains("<h2>Heading Level Two</h2>"))
        #expect(markdown.contains("<h3>Heading Level Three</h3>"))
        #expect(markdown.contains("<ul>"))
        #expect(markdown.contains("<ol>"))
        #expect(markdown.contains("<blockquote>"))
        #expect(markdown.contains("<table>"))
        #expect(markdown.contains("<hr"))
        #expect(markdown.contains("<img src=\"/images/tsubame-cover.svg\""))
        #expect(markdown.contains("href=\"https://example.com\""))
        #expect(markdown.contains("<pre"))
        #expect(markdown.contains("language-swift"))
        #expect(markdown.contains("language-html"))
    }

    @Test("markdown HTML code remains visible while raw HTML stays raw")
    func keepsMarkdownHTMLCodeVisible() async throws {
        let harness = try await publishedSite()

        let page = try harness.contents(of: "posts/markdown-reading-lab/index.html")
        let markdown = try markdownSlice(of: try mainSlice(of: page))

        #expect(markdown.contains("data-raw-html-fixture=\"true\""))
        #expect(markdown.contains(#"&lt;span class=&quot;inline-html-code&quot;&gt;inline&lt;/span&gt;"#))
        #expect(markdown.contains(#"&lt;div class=&quot;html-code-sample&quot;&gt;Hello HTML&lt;/div&gt;"#))

        let htmlCodeWindow = try htmlCodeBlockWindow(in: markdown)
        #expect(htmlCodeWindow.contains("language-html"))
        #expect(htmlCodeWindow.contains("html-code-sample"))
        #expect(!htmlCodeWindow.contains("<div class=\"html-code-sample\">Hello HTML</div>"))
    }

    @Test("generated CSS includes scoped markdown reading rules")
    func generatedCSSIncludesMarkdownReadingRules() async throws {
        let harness = try await publishedSite()

        let css = try harness.contents(of: "css/raptor-core.css")

        #expect(css.contains("[data-markdown-content=\"true\"]"))
        #expect(css.contains("--markdown-text"))
        #expect(css.contains("[data-color-scheme=\"dark\"] [data-markdown-content=\"true\"]"))
        #expect(css.contains("[data-markdown-content=\"true\"] pre"))
        #expect(css.contains("[data-markdown-content=\"true\"] :not(pre) > code"))
        #expect(css.contains("[data-markdown-content=\"true\"] table"))
        #expect(!css.contains("\nh1 {"))
        #expect(!css.contains("\npre {"))
        #expect(!css.contains("\ncode {"))
    }
```

Add helper functions near the existing private helpers:

```swift
private func markdownSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-markdown-content=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let end = html[marker.upperBound...].range(of: "data-article-navigation")?.lowerBound ?? html.endIndex
    return String(html[openStart.lowerBound..<end])
}

private func htmlCodeBlockWindow(in markdown: String) throws -> String {
    let language = try #require(markdown.range(of: "language-html"))
    let preStart = try #require(markdown[..<language.lowerBound].range(of: "<pre", options: .backwards))
    let preEnd = try #require(markdown[language.upperBound...].range(of: "</pre>"))
    return String(markdown[preStart.lowerBound..<preEnd.upperBound])
}
```

- [ ] **Step 3: Run the focused tests and confirm failure**

Run:

```bash
swift test --filter SitePublishingTests/publishesMarkdownReadingLab
swift test --filter SitePublishingTests/keepsMarkdownHTMLCodeVisible
swift test --filter SitePublishingTests/generatedCSSIncludesMarkdownReadingRules
```

Expected:

- `publishesMarkdownReadingLab` may pass route/markup basics if `kind: page` + `layout: ArticlePage` routes as expected.
- `keepsMarkdownHTMLCodeVisible` should fail before the safe processor if default Raptor emits raw `<span>`/`<div>` inside `<code>`.
- `generatedCSSIncludesMarkdownReadingRules` should fail because `markdown-reading.css` does not exist yet.

- [ ] **Step 4: Commit the fixture and failing tests only**

```bash
git add Posts/pages/markdown-reading-lab.md Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "test: cover article markdown reading output"
```

## Task 2: Safe Markdown Code Escaping

**Files:**
- Create: `Sources/Markdown/SafeMarkdownToHTML.swift`
- Modify: `Sources/App/Site.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift` only if helper parsing needs tightening

- [ ] **Step 1: Add a delegating post processor**

Create `Sources/Markdown/SafeMarkdownToHTML.swift`:

```swift
import Foundation
import Raptor

struct SafeMarkdownToHTML: PostProcessor {
    var removeTitleFromBody: Bool { processor.removeTitleFromBody }
    var syntaxHighlighterLanguages: Set<SyntaxHighlighterLanguage> { processor.syntaxHighlighterLanguages }

    private var processor = MarkdownToHTML()

    mutating func process(_ markup: String) throws -> ProcessedPost {
        var processed = try processor.process(markup)
        processed.body = escapeCodeElementBodies(in: processed.body)
        return processed
    }

    func delimitRawMarkup(_ widgetHTML: String) -> String {
        processor.delimitRawMarkup(widgetHTML)
    }
}

private func escapeCodeElementBodies(in html: String) -> String {
    var result = ""
    var remainder = html[...]

    while let openRange = remainder.range(of: "<code") {
        result += remainder[..<openRange.lowerBound]

        guard let openEnd = remainder[openRange.upperBound...].firstIndex(of: ">"),
              let closeRange = remainder[openEnd...].range(of: "</code>")
        else {
            result += remainder[openRange.lowerBound...]
            return result
        }

        let openingTag = remainder[openRange.lowerBound...openEnd]
        let codeBody = remainder[remainder.index(after: openEnd)..<closeRange.lowerBound]
        result += openingTag
        result += escapeHTMLText(String(codeBody))
        result += "</code>"
        remainder = remainder[closeRange.upperBound...]
    }

    result += remainder
    return result
}

private func escapeHTMLText(_ text: String) -> String {
    text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&#39;")
}
```

If `ProcessedPost.body` is immutable in the checked-out Raptor version, replace the mutation with a new initializer after inspecting `ProcessedPost`:

```swift
return ProcessedPost(
    title: processed.title,
    description: processed.description,
    body: escapeCodeElementBodies(in: processed.body)
)
```

- [ ] **Step 2: Configure the site to use the safe processor**

Modify `Sources/App/Site.swift` inside `ExampleSite`:

```swift
    var postProcessor: SafeMarkdownToHTML { .init() }
```

Place it near the theme/layout properties:

```swift
    var profile = SiteProfile.default
    nonisolated var themes: [any Theme] { SiteTheme() }
    var postProcessor: SafeMarkdownToHTML { .init() }
```

- [ ] **Step 3: Run the HTML-code visibility test**

Run:

```bash
swift test --filter SitePublishingTests/keepsMarkdownHTMLCodeVisible
```

Expected: PASS. If it fails because generated output is double-escaped (`&amp;lt;`), update `escapeHTMLText` to skip bodies that already contain `&lt;` and no raw `<`:

```swift
private func escapeHTMLText(_ text: String) -> String {
    guard text.contains("<") || text.contains(">") || text.contains("\"") || text.contains("'") else {
        return text
    }

    return text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&#39;")
}
```

- [ ] **Step 4: Run the article publishing tests**

Run:

```bash
swift test --filter SitePublishingTests
```

Expected: all existing publishing tests pass except `generatedCSSIncludesMarkdownReadingRules`, which remains RED until Task 3.

- [ ] **Step 5: Commit the safe processor**

```bash
git add Sources/Markdown/SafeMarkdownToHTML.swift Sources/App/Site.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "fix: escape markdown code HTML"
```

## Task 3: Scoped Markdown Reading CSS

**Files:**
- Create: `Sources/Resources/css/markdown-reading.css`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift` if the generated CSS path exposes exact selector formatting differences

- [ ] **Step 1: Add scoped reading CSS**

Create `Sources/Resources/css/markdown-reading.css`:

```css
[data-markdown-content="true"] {
  --markdown-text: rgb(19 40 62 / 100%);
  --markdown-muted: rgb(88 113 139 / 100%);
  --markdown-accent: rgb(74 139 203 / 100%);
  --markdown-border: rgb(200 221 242 / 100%);
  --markdown-soft: rgb(242 248 255 / 100%);
  --markdown-code-bg: rgb(11 23 38 / 100%);
  --markdown-code-text: rgb(220 236 255 / 100%);
  --markdown-table-stripe: rgb(247 251 255 / 100%);
  color: var(--markdown-text);
  font-size: 17px;
  line-height: 1.82;
}

[data-color-scheme="dark"] [data-markdown-content="true"] {
  --markdown-text: rgb(220 236 255 / 100%);
  --markdown-muted: rgb(142 169 197 / 100%);
  --markdown-accent: rgb(120 184 245 / 100%);
  --markdown-border: rgb(36 71 98 / 100%);
  --markdown-soft: rgb(11 23 38 / 100%);
  --markdown-code-bg: rgb(3 10 18 / 100%);
  --markdown-code-text: rgb(220 236 255 / 100%);
  --markdown-table-stripe: rgb(16 34 54 / 100%);
}

[data-markdown-content="true"] > *:first-child {
  margin-top: 0;
}

[data-markdown-content="true"] > *:last-child {
  margin-bottom: 0;
}

[data-markdown-content="true"] p {
  margin: 1.05rem 0 0;
}

[data-markdown-content="true"] h2,
[data-markdown-content="true"] h3,
[data-markdown-content="true"] h4 {
  color: var(--markdown-text);
  font-weight: 760;
  letter-spacing: -0.02em;
  line-height: 1.22;
}

[data-markdown-content="true"] h2 {
  margin: 2.35rem 0 0.8rem;
  padding-left: 0.85rem;
  border-left: 4px solid var(--markdown-accent);
  font-size: clamp(1.55rem, 1.2rem + 1vw, 2rem);
}

[data-markdown-content="true"] h3 {
  margin: 2rem 0 0.65rem;
  font-size: clamp(1.25rem, 1.05rem + 0.6vw, 1.55rem);
}

[data-markdown-content="true"] h4 {
  margin: 1.6rem 0 0.5rem;
  font-size: 1.08rem;
}

[data-markdown-content="true"] a {
  color: var(--markdown-accent);
  font-weight: 650;
  text-decoration: underline;
  text-decoration-thickness: 1px;
  text-underline-offset: 0.18em;
}

[data-markdown-content="true"] ul,
[data-markdown-content="true"] ol {
  margin: 1rem 0 0;
  padding-left: 1.45rem;
}

[data-markdown-content="true"] li + li {
  margin-top: 0.35rem;
}

[data-markdown-content="true"] li::marker {
  color: var(--markdown-accent);
  font-weight: 700;
}

[data-markdown-content="true"] blockquote {
  margin: 1.35rem 0 0;
  padding: 0.85rem 1rem 0.85rem 1.15rem;
  border-left: 4px solid var(--markdown-accent);
  border-radius: 0 14px 14px 0;
  background: var(--markdown-soft);
  color: var(--markdown-muted);
}

[data-markdown-content="true"] :not(pre) > code {
  display: inline-block;
  padding: 0.05rem 0.36rem;
  border: 1px solid var(--markdown-border);
  border-radius: 7px;
  background: var(--markdown-soft);
  color: var(--markdown-accent);
  font-size: 0.88em;
  line-height: 1.55;
}

[data-markdown-content="true"] pre {
  margin: 1.35rem 0 0;
  padding: 1rem;
  overflow-x: auto;
  border: 1px solid var(--markdown-border);
  border-radius: 16px;
  background: var(--markdown-code-bg);
  color: var(--markdown-code-text);
  line-height: 1.65;
}

[data-markdown-content="true"] pre code {
  display: block;
  padding: 0;
  border: 0;
  background: transparent;
  color: inherit;
  font-size: 0.9rem;
  white-space: pre;
}

[data-markdown-content="true"] table {
  width: 100%;
  margin: 1.35rem 0 0;
  border-collapse: separate;
  border-spacing: 0;
  overflow: hidden;
  border: 1px solid var(--markdown-border);
  border-radius: 14px;
}

[data-markdown-content="true"] th,
[data-markdown-content="true"] td {
  padding: 0.65rem 0.8rem;
  border-bottom: 1px solid var(--markdown-border);
  text-align: left;
}

[data-markdown-content="true"] th {
  background: var(--markdown-soft);
  color: var(--markdown-text);
  font-weight: 760;
}

[data-markdown-content="true"] tr:nth-child(even) td {
  background: var(--markdown-table-stripe);
}

[data-markdown-content="true"] tr:last-child td {
  border-bottom: 0;
}

[data-markdown-content="true"] img {
  display: block;
  max-width: 100%;
  height: auto;
  margin: 1.35rem auto 0;
  border-radius: 16px;
}

[data-markdown-content="true"] hr {
  margin: 2rem 0;
  border: 0;
  border-top: 1px solid var(--markdown-border);
}

@media (max-width: 574px) {
  [data-markdown-content="true"] {
    font-size: 16px;
    line-height: 1.76;
  }

  [data-markdown-content="true"] pre {
    margin-left: -0.2rem;
    margin-right: -0.2rem;
    padding: 0.85rem;
    border-radius: 14px;
  }
}
```

- [ ] **Step 2: Run the CSS-focused test**

Run:

```bash
swift test --filter SitePublishingTests/generatedCSSIncludesMarkdownReadingRules
```

Expected: PASS. If it fails with `missingSiteResource("css")`, verify the resource path by running `swift build` and move the file to the target resource path that SwiftPM exposes as `Resources/css`. Keep the final path under the executable target, not repo root.

- [ ] **Step 3: Build and inspect generated CSS**

Run:

```bash
swift run RaptorTsubame
rg -n "data-markdown-content|markdown-text|language-html" Build/css/raptor-core.css Build/posts/markdown-reading-lab/index.html
```

Expected:

- `Build/css/raptor-core.css` contains `[data-markdown-content="true"]`.
- `Build/posts/markdown-reading-lab/index.html` contains escaped `&lt;div class=&quot;html-code-sample&quot;&gt;Hello HTML&lt;/div&gt;`.
- Raw HTML fixture remains `data-raw-html-fixture="true"`.

- [ ] **Step 4: Run all publishing tests**

Run:

```bash
swift test --filter SitePublishingTests
```

Expected: PASS.

- [ ] **Step 5: Commit scoped Markdown reading CSS**

```bash
git add Sources/Resources/css/markdown-reading.css Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "feat: style article markdown reading content"
```

## Task 4: Article Navigation Visual Cleanup

**Files:**
- Modify: `Sources/Components/Posts/ArticleNavigation.swift`
- Create: `Sources/Styles/Visual/ArticleNavigationStyle.swift`
- Modify: `Sources/Components/Posts/ArticleStyleSeed.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add navigation output assertions**

Extend `rendersArticleReadingStatsAndAdjacentNavigation()` with marker checks:

```swift
        #expect(middle.contains("data-article-navigation-link=\"newer\""))
        #expect(middle.contains("data-article-navigation-link=\"older\""))
        #expect(middle.contains("article-navigation-style"))
        #expect(middle.contains("article-navigation-link-style"))
```

Extend `expectBlueThemeVisualCSS(in:)`:

```swift
    #expect(css.contains(".article-navigation-style"))
    #expect(css.contains(".article-navigation-link-style"))

    let navigationRule = try cssRule(in: css, containing: ".article-navigation-style")
    #expect(navigationRule.contains("gap: 12px;"))

    let navigationLinkRule = try cssRule(in: css, containing: ".article-navigation-link-style")
    #expect(navigationLinkRule.contains("rgb(242 248 255 / 100%)"))
    #expect(navigationLinkRule.contains("rgb(200 221 242 / 100%)"))

    try expectDarkBlueThemeRule(in: css, containing: ".article-navigation-link-style") { rule in
        #expect(rule.contains("rgb(16 34 54 / 100%)"))
        #expect(rule.contains("rgb(36 71 98 / 100%)"))
    }
```

- [ ] **Step 2: Run the focused navigation test and confirm failure**

Run:

```bash
swift test --filter SitePublishingTests/rendersArticleReadingStatsAndAdjacentNavigation
```

Expected: FAIL because the new markers/styles do not exist yet.

- [ ] **Step 3: Update article navigation markup**

Replace `Sources/Components/Posts/ArticleNavigation.swift` with:

```swift
import Foundation
import Raptor

struct ArticleNavigation: HTML {
    let newer: Post?
    let older: Post?

    var body: some HTML {
        Tag("nav") {
            HStack(spacing: 12) {
                if let newer {
                    Link("Newer: \(newer.title)", destination: newer)
                        .style(ArticleNavigationLinkStyle())
                        .data("article-navigation-link", "newer")
                }

                Spacer()

                if let older {
                    Link("Older: \(older.title)", destination: older)
                        .style(ArticleNavigationLinkStyle())
                        .data("article-navigation-link", "older")
                }
            }
        }
        .style(ArticleNavigationStyle())
        .data("article-navigation", "true")
    }
}
```

- [ ] **Step 4: Add navigation styles**

Create `Sources/Styles/Visual/ArticleNavigationStyle.swift`:

```swift
import Foundation
import Raptor

struct ArticleNavigationStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .margin(.top, 4)
        } else {
            content
                .style(.width(.percent(100)))
                .margin(.top, 8)
        }
    }
}

struct ArticleNavigationLinkStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        let background = environment.colorScheme == .dark
            ? palette.surfaceRaised
            : palette.canvasBackground

        return content
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .style(.borderRadius(.px(14)))
            .background(background)
            .foregroundStyle(palette.accent)
            .border(palette.border, width: 1, style: .solid)
            .textDecoration(.none)
            .fontWeight(.bold)
    }
}
```

This uses existing `SiteThemePalette` tokens: `canvasBackground` for the light navigation card (`rgb(242 248 255 / 100%)`) and `surfaceRaised` for the dark navigation card (`rgb(16 34 54 / 100%)`).

- [ ] **Step 5: Seed the navigation styles**

Modify `Sources/Components/Posts/ArticleStyleSeed.swift`:

```swift
        EmptyHTML().style(ArticleNavigationStyle())
        EmptyHTML().style(ArticleNavigationLinkStyle())
```

Add these immediately after `ArticleBodyStyle()`.

- [ ] **Step 6: Run navigation and CSS tests**

Run:

```bash
swift test --filter SitePublishingTests/rendersArticleReadingStatsAndAdjacentNavigation
swift test --filter SitePublishingTests/generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint
swift test --filter SitePublishingTests/publishedPagesIncludeBlueThemeVisualStyles
```

Expected: PASS.

- [ ] **Step 7: Commit navigation cleanup**

```bash
git add Sources/Components/Posts/ArticleNavigation.swift Sources/Styles/Visual/ArticleNavigationStyle.swift Sources/Components/Posts/ArticleStyleSeed.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "feat: refine article navigation"
```

## Task 5: Full Verification And Final Commit Hygiene

**Files:**
- Verify all changed files from Tasks 1-4.
- Do not stage `Posts/posts/build-website-in-swift.md`.

- [ ] **Step 1: Run full verification**

Run:

```bash
swift test
swift run RaptorTsubame
```

Expected:

- `swift test` exits 0.
- `swift run RaptorTsubame` exits 0.
- `Build/posts/markdown-reading-lab/index.html` exists.
- `Build/css/raptor-core.css` contains scoped Markdown CSS.

- [ ] **Step 2: Inspect generated output for the HTML-code constraint**

Run:

```bash
rg -n "html-code-sample|inline-html-code|data-raw-html-fixture|data-markdown-content" Build/posts/markdown-reading-lab/index.html
```

Expected:

- Fenced HTML code appears as escaped text, not an active `.html-code-sample` element.
- Inline HTML code appears as escaped text.
- Raw HTML fixture remains raw HTML.

- [ ] **Step 3: Check git status**

Run:

```bash
git status --short
```

Expected: only intentional tracked changes are committed; `?? Posts/posts/build-website-in-swift.md` may remain and must not be staged.

- [ ] **Step 4: If any verification-only adjustments were needed, commit them**

Only run this if Step 1 or Step 2 required small fixes:

```bash
git add <exact-intentional-paths>
git commit -m "test: verify article reading typography"
```

## Self-Review Checklist

- Spec coverage: Markdown descendants, Fuwari-like scoped wrapper architecture, HTML-code visibility, raw HTML behavior, article-only styling, and verification are each covered.
- Placeholder scan: no `TBD`, no generic "add tests", no unbounded parser replacement.
- API boundary: the only Raptor override is public `Site.postProcessor`; CSS uses target resources and is scoped to `[data-markdown-content="true"]`.
- Risk control: if SwiftPM resource layout or `ProcessedPost` mutability differs, the task includes exact fallback checks before proceeding.
