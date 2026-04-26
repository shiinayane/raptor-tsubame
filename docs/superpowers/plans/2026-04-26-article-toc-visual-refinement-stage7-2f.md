# Article TOC Visual Refinement Stage 7.2F Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refine the inline article TOC into the selected Quiet Index direction while preserving the Stage 7.2E outline pipeline and future sidebar migration path.

**Architecture:** Keep `ArticleTOC` as a standalone renderer over `ArticleOutline`. Add missing semantic data markers, then style the TOC through focused public Raptor `Style` types applied to root/list/item/link elements instead of nested private CSS selectors. Do not touch markdown preprocessing, heading slugging, article shell, site sidebar, or JavaScript.

**Tech Stack:** Swift 6, Raptor public `HTML`/`Style` APIs, Swift Testing, published HTML/CSS assertions.

---

## Current Worktree Note

The worktree may already contain unrelated or earlier local changes:

- `Sources/Styles/Visual/PageCanvasStyle.swift`
- `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`
- `Posts/posts/build-website-in-swift.md`

Before staging or committing Stage 7.2F implementation work, inspect `git diff` and stage only files intentionally changed for the current task. Do not revert unrelated user or prior-session changes.

## File Map

- Modify: `Sources/Components/Posts/ArticleTOC.swift`
  - Owns TOC markup and data markers.
  - Should remain placement-agnostic.
- Modify: `Sources/Styles/Visual/ArticleTocStyle.swift`
  - Owns TOC visual styling.
  - Add small helper style structs in the same file for title/list/item/link if needed.
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`
  - Owns route-level published HTML/CSS regression coverage.
- Do not modify: `Sources/Content/ArticleRenderedMarkdown.swift`
- Do not modify: `Sources/Content/ArticleMarkdownSourceRenderer.swift`
- Do not modify: `Sources/Layouts/MainLayout.swift`

## Task 1: Complete TOC Markup Markers

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`
- Modify: `Sources/Components/Posts/ArticleTOC.swift`

- [ ] **Step 1: Write the failing marker assertions**

Update `articlePageRendersInlineTOC()` in `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`:

```swift
@Test("markdown reading lab renders inline TOC")
func articlePageRendersInlineTOC() async throws {
    let harness = try await publishedSite()

    let page = try harness.contents(of: "posts/markdown-reading-lab/index.html")
    let main = try mainSlice(of: page)
    let markdown = try markdownSlice(of: main)
    let toc = try articleTOCSlice(of: main)

    #expect(toc.contains("data-article-toc=\"true\""))
    #expect(toc.contains("data-article-toc-title=\"true\""))
    #expect(toc.contains("data-article-toc-list=\"true\""))
    #expect(toc.contains("data-article-toc-item=\"true\""))
    #expect(toc.contains("data-article-toc-level=\"h2\""))
    #expect(toc.contains("data-article-toc-level=\"h3\""))
    #expect(toc.contains("data-article-toc-link=\"true\""))
    #expect(toc.contains(#"aria-label="Contents""#))
    #expect(toc.contains("href=\"#heading-level-two\""))
    #expect(toc.contains("href=\"#heading-level-three\""))
    #expect(markdown.contains(#"<h2 id="heading-level-two" data-article-heading-anchor="true">Heading Level Two</h2>"#))
    #expect(markdown.contains(#"<h3 id="heading-level-three" data-article-heading-anchor="true">Heading Level Three</h3>"#))
}
```

Add this helper near the existing HTML slice helpers in the same test file:

```swift
private func articleTOCSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-article-toc=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let closeRange = try #require(html[marker.upperBound...].range(of: "</nav>"))
    return String(html[openStart.lowerBound..<closeRange.upperBound])
}
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```bash
swift test --filter SitePublishingTests/articlePageRendersInlineTOC
```

Expected: FAIL because current output lacks `data-article-toc-list="true"` and `data-article-toc-link="true"`.

- [ ] **Step 3: Add missing markers in `ArticleTOC`**

Update `Sources/Components/Posts/ArticleTOC.swift`:

```swift
import Foundation
import Raptor

struct ArticleTOC: HTML {
    let outline: ArticleOutline

    var body: some HTML {
        if outline.shouldRender {
            Tag("nav") {
                Text("Contents")
                    .font(.title5)
                    .style(ArticleTocTitleStyle())
                    .data("article-toc-title", "true")

                Tag("ol") {
                    ForEach(outline.items) { item in
                        Tag("li") {
                            Link(destination: "#\(item.id)") {
                                escapedHTML(item.title)
                            }
                            .style(ArticleTocLinkStyle(level: item.level))
                            .data("article-toc-link", "true")
                        }
                        .style(ArticleTocItemStyle(level: item.level))
                        .data("article-toc-item", "true")
                        .data("article-toc-level", "h\(item.level.rawValue)")
                    }
                }
                .style(ArticleTocListStyle())
                .data("article-toc-list", "true")
            }
            .style(ArticleTocStyle())
            .data("article-toc", "true")
            .attribute("aria-label", "Contents")
        } else {
            EmptyHTML()
        }
    }
}

private func escapedHTML(_ text: String) -> String {
    text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}
```

This references style types added in Task 2. If compiling Task 1 independently, add temporary empty implementations at the bottom of `ArticleTocStyle.swift` and replace them in Task 2:

```swift
struct ArticleTocTitleStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content { content }
}

struct ArticleTocListStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content { content }
}

struct ArticleTocItemStyle: Style {
    let level: ArticleHeadingLevel
    func style(content: Content, environment: EnvironmentConditions) -> Content { content }
}

struct ArticleTocLinkStyle: Style {
    let level: ArticleHeadingLevel
    func style(content: Content, environment: EnvironmentConditions) -> Content { content }
}
```

- [ ] **Step 4: Run focused test and verify GREEN**

Run:

```bash
swift test --filter SitePublishingTests/articlePageRendersInlineTOC
```

Expected: PASS.

- [ ] **Step 5: Commit Task 1**

Stage only relevant files:

```bash
git add Sources/Components/Posts/ArticleTOC.swift Sources/Styles/Visual/ArticleTocStyle.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "feat: complete article toc markers"
```

## Task 2: Apply Quiet Index Styling

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`
- Modify: `Sources/Styles/Visual/ArticleTocStyle.swift`

- [ ] **Step 1: Add failing CSS assertions**

In `expectBlueThemeVisualCSS(in:)`, add TOC style presence near the other article style checks:

```swift
#expect(css.contains(".article-toc-style"))
#expect(css.contains(".article-toc-title-style"))
#expect(css.contains(".article-toc-list-style"))
#expect(css.contains(".article-toc-item-style"))
#expect(css.contains(".article-toc-link-style"))
```

Then add rule-level assertions near the existing article visual rule checks:

```swift
let tocRule = try cssRule(in: css, containing: ".article-toc-style")
#expect(tocRule.contains("rgb(251 253 255 / 100%)"))
#expect(tocRule.contains("rgb(200 221 242 / 100%)"))
#expect(tocRule.contains("border-radius:"))

let tocTitleRule = try cssRule(in: css, containing: ".article-toc-title-style")
#expect(tocTitleRule.contains("text-transform: uppercase;"))
#expect(tocTitleRule.contains("letter-spacing: 0.12em;"))
#expect(tocTitleRule.contains("rgb(74 139 203 / 100%)"))

let tocListRule = try cssRule(in: css, containing: ".article-toc-list-style")
#expect(tocListRule.contains("list-style: none;"))
#expect(tocListRule.contains("padding: 0px;"))

#expect(css.contains("border-left: 3px solid rgb(74 139 203 / 100%);"))
#expect(css.contains("padding-left: 12px;"))
#expect(css.contains("padding-left: 28px;"))
#expect(css.contains("rgb(88 113 139 / 100%)"))
#expect(css.contains("rgb(142 169 197 / 100%)"))

let tocLinkRule = try cssRule(in: css, containing: ".article-toc-link-style")
#expect(tocLinkRule.contains("display: block;"))
```

These assertions intentionally use `css.contains(...)` for H2/H3 item differences because `ArticleTocItemStyle(level:)` creates multiple generated classes with the same base name. Published HTML level markers from Task 1 remain the structural hierarchy source of truth.

- [ ] **Step 2: Run focused CSS test and verify RED**

Run:

```bash
swift test --filter SitePublishingTests/generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint
```

Expected: FAIL because the detailed TOC title/list/item/link styles are not implemented yet.

- [ ] **Step 3: Replace placeholder styles with Quiet Index implementation**

Update `Sources/Styles/Visual/ArticleTocStyle.swift`:

```swift
import Foundation
import Raptor

struct ArticleTocStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .style(.borderRadius(.px(18)))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .padding(.vertical, 20)
                .padding(.horizontal, 22)
                .style(.borderRadius(.px(22)))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
                .shadow(palette.shadow, radius: 18, x: 0, y: 10)
        }
    }
}

struct ArticleTocTitleStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.margin(.px(0)))
            .style(.marginBottom(.px(14)))
            .style(.fontSize(.px(13)))
            .fontWeight(.heavy)
            .style(.custom("letter-spacing", value: "0.12em"))
            .style(.textTransform(.uppercase))
            .foregroundStyle(palette.accent)
    }
}

struct ArticleTocListStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.display(.grid))
            .style(.gap(.px(9)))
            .style(.listStyleType(.none))
            .style(.margin(.px(0)))
            .style(.padding(.px(0)))
    }
}

struct ArticleTocItemStyle: Style {
    let level: ArticleHeadingLevel

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        switch level {
        case .h2:
            content
                .border(palette.accent, width: 3, style: .solid, edges: .leading)
                .style(.paddingLeft(.px(12)))
                .fontWeight(.bold)
                .foregroundStyle(palette.text)
        case .h3:
            content
                .border(.clear, width: 3, style: .solid, edges: .leading)
                .style(.paddingLeft(.px(28)))
                .fontWeight(.medium)
                .foregroundStyle(palette.mutedText)
        }
    }
}

struct ArticleTocLinkStyle: Style {
    let level: ArticleHeadingLevel

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.display(.block))
            .style(.lineHeight(1.45))
            .foregroundStyle(level == .h2 ? palette.text : palette.mutedText)
            .textDecoration(.none)
    }
}
```

Do not add global CSS unless the public style API cannot express the property.

- [ ] **Step 4: Run focused CSS test and verify GREEN**

Run:

```bash
swift test --filter SitePublishingTests/generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint
```

Expected: PASS.

- [ ] **Step 5: Run TOC HTML test again**

Run:

```bash
swift test --filter SitePublishingTests/articlePageRendersInlineTOC
```

Expected: PASS.

- [ ] **Step 6: Commit Task 2**

```bash
git add Sources/Styles/Visual/ArticleTocStyle.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "style: refine article toc quiet index"
```

## Task 3: Verification And Scope Guard

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift` only if a missing guard is found.

- [ ] **Step 1: Verify short article behavior remains unchanged**

Run:

```bash
swift test --filter SitePublishingTests/shortArticleDoesNotRenderTOC
```

Expected: PASS.

- [ ] **Step 2: Run full test suite**

Run:

```bash
swift test
```

Expected: PASS with 64 or more tests. The exact count may increase if this plan adds tests.

- [ ] **Step 3: Refresh generated site**

Run:

```bash
swift run RaptorTsubame
```

Expected: exit 0. Existing Prism highlighter warnings may remain:

```text
Failed to locate syntax highlighter JavaScript: Resources/js/prism/prism-html.
Language-tagged code blocks are present, but no syntax-highlighter theme is defined.
```

- [ ] **Step 4: Inspect generated TOC output**

Run:

```bash
rg -n "data-article-toc|data-article-toc-list|data-article-toc-link|data-article-toc-level|href=\"#heading-level-two\"|href=\"#heading-level-three\"" Build/posts/markdown-reading-lab/index.html
```

Expected: matches for root, list, link, level, and both anchor links.

- [ ] **Step 5: Guard non-goals**

Run:

```bash
rg -n "sticky|scroll-spy|addEventListener|localStorage|toc:" Sources Tests Posts docs/superpowers/plans/2026-04-26-article-toc-visual-refinement-stage7-2f.md
```

Expected: no implementation matches in `Sources`, `Tests`, or `Posts`. Mentions in this plan as non-goals are acceptable.

- [ ] **Step 6: Inspect diff before final commit**

Run:

```bash
git diff -- Sources/Components/Posts/ArticleTOC.swift Sources/Styles/Visual/ArticleTocStyle.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git status --short
```

Expected: Stage 7.2F source/test changes are limited to TOC component, TOC style, and publishing tests. Existing unrelated files remain unstaged unless intentionally included by the user.

- [ ] **Step 7: Commit verification guard if needed**

If Task 3 required test changes, commit them:

```bash
git add Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "test: guard article toc visual output"
```

If no files changed in Task 3, do not create an empty commit.

## Final Acceptance

- Published TOC includes root/title/list/item/link/level markers.
- H2 and H3 entries are visually distinct in generated CSS.
- TOC uses existing blue theme palette and does not introduce a new page-level background owner.
- Short articles still render no TOC chrome.
- No sidebar migration, sticky behavior, JavaScript, or front matter switch is introduced.
