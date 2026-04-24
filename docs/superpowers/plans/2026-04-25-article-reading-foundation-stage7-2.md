# Article Reading Foundation Stage 7.2A Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Stage 7.2A article reading foundation with focused article components, stable published markers, and token-driven container-level reading styles.

**Architecture:** Keep `ArticlePage` as a thin composition layer and move article structure into `ArticleContent`, `ArticleHeader`, and `ArticleBody`. Keep Markdown rendering delegated to Raptor's `post.text` through `MarkdownContent`, and use only public Raptor style APIs for container-level typography and surfaces. Do not add cover rendering, `updated`/`lang` UI, TOC, heading anchors, related posts, series navigation, route changes, sidebar changes, or JavaScript.

**Tech Stack:** Swift, Raptor HTML DSL, Raptor `Style`, Swift Testing, published-output tests through `publishedSite()`.

---

## File Structure

- Create `Sources/Components/Posts/ArticleContent.swift`
  - Owns full article layout structure and article-level marker.
- Create `Sources/Components/Posts/ArticleHeader.swift`
  - Owns title, post metadata, reading stats, taxonomy badges, and header marker.
- Create `Sources/Components/Posts/ArticleBody.swift`
  - Owns Markdown wrapper and body marker.
- Modify `Sources/Components/Posts/MarkdownContent.swift`
  - Keep `post.text`.
  - Add stable `data-markdown-content` marker.
- Modify `Sources/Pages/Posts/ArticlePage.swift`
  - Replace inline `VStack` article structure with `ArticleContent`.
- Create `Sources/Styles/Visual/ArticleSurfaceStyle.swift`
  - Owns article card/surface spacing and token colors.
- Create `Sources/Styles/Visual/ArticleHeaderStyle.swift`
  - Owns header spacing and bottom separator.
- Create `Sources/Styles/Visual/ArticleBodyStyle.swift`
  - Owns body line rhythm and text color.
- Modify `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`
  - Add published article marker assertions.
  - Add generated CSS assertions for article style classes and light/dark token output.

## Task 1: Add Failing Published Article Structure Tests

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Extend `rendersArticlePage()` with article structure markers**

Inside `rendersArticlePage()`, after `let main = try mainSlice(of: article)`, add these assertions:

```swift
#expect(main.contains("data-article-page=\"true\""))
#expect(main.contains("data-article-header=\"true\""))
#expect(main.contains("data-article-body=\"true\""))
#expect(main.contains("data-markdown-content=\"true\""))
```

After the existing metadata assertions, add:

```swift
#expect(main.contains("data-reading-stats=\"true\""))
#expect(main.contains("data-post-meta=\"true\""))
#expect(main.contains("href=\"/categories/updates/\""))
#expect(main.contains("href=\"/tags/intro/\""))
```

- [ ] **Step 2: Extend visual HTML assertions for articles**

In `publishedPagesIncludeBlueThemeVisualStyles()`, after:

```swift
#expect(article.contains("metadata-text-style"))
```

add:

```swift
#expect(article.contains("article-surface-style"))
#expect(article.contains("article-header-style"))
#expect(article.contains("article-body-style"))
#expect(article.contains("data-article-page=\"true\""))
#expect(article.contains("data-article-header=\"true\""))
#expect(article.contains("data-article-body=\"true\""))
#expect(article.contains("data-markdown-content=\"true\""))
```

- [ ] **Step 3: Extend generated CSS assertions**

In `expectBlueThemeVisualCSS(in:)`, after:

```swift
#expect(css.contains(".sidebar-panel-style"))
```

add:

```swift
#expect(css.contains(".article-surface-style"))
#expect(css.contains(".article-header-style"))
#expect(css.contains(".article-body-style"))
```

After the existing `@media (min-width: 0px)` negative assertions, add:

```swift
#expect(!css.contains("@media (min-width: 0px) {\n    .article-surface-style"))
#expect(!css.contains("@media (min-width: 0px) {\n    .article-header-style"))
#expect(!css.contains("@media (min-width: 0px) {\n    .article-body-style"))
```

After the `sidebarPanelRule` assertions, add:

```swift
let articleSurfaceRule = try cssRule(in: css, containing: ".article-surface-style")
#expect(articleSurfaceRule.contains("rgb(251 253 255 / 100%)"))
#expect(articleSurfaceRule.contains("rgb(200 221 242 / 100%)"))
#expect(articleSurfaceRule.contains("rgb(19 40 62 / 100%)"))
```

After the existing dark sidebar rule check, add:

```swift
try expectDarkBlueThemeRule(in: css, containing: ".article-surface-style") { rule in
    #expect(rule.contains("rgb(11 23 38 / 100%)"))
    #expect(rule.contains("rgb(36 71 98 / 100%)"))
    #expect(rule.contains("rgb(220 236 255 / 100%)"))
}
try expectDarkBlueThemeRule(in: css, containing: ".article-header-style") { rule in
    #expect(rule.contains("rgb(36 71 98 / 100%)"))
}
try expectDarkBlueThemeRule(in: css, containing: ".article-body-style") { rule in
    #expect(rule.contains("rgb(220 236 255 / 100%)"))
}
```

- [ ] **Step 4: Run the focused publishing tests and verify failure**

Run:

```bash
swift test --filter SitePublishingTests/rendersArticlePage
```

Expected: FAIL because the article markers and article style classes do not exist yet.

Run:

```bash
swift test --filter SitePublishingTests/publishedPagesIncludeBlueThemeVisualStyles
```

Expected: FAIL because article style classes and article markers do not exist yet.

Run:

```bash
swift test --filter SitePublishingTests/generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint
```

Expected: FAIL because generated CSS does not include article style class prefixes yet.

## Task 2: Add Article Components And Thin ArticlePage Composition

**Files:**
- Create: `Sources/Components/Posts/ArticleContent.swift`
- Create: `Sources/Components/Posts/ArticleHeader.swift`
- Create: `Sources/Components/Posts/ArticleBody.swift`
- Modify: `Sources/Components/Posts/MarkdownContent.swift`
- Modify: `Sources/Pages/Posts/ArticlePage.swift`

- [ ] **Step 1: Create `ArticleContent`**

Create `Sources/Components/Posts/ArticleContent.swift`:

```swift
import Foundation
import Raptor

struct ArticleContent: HTML {
    let post: Post
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]
    let newer: Post?
    let older: Post?

    var body: some HTML {
        Tag("article") {
            VStack(alignment: .leading, spacing: 22) {
                ArticleHeader(post: post, category: category, tags: tags)
                ArticleBody(post: post)
                ArticleNavigation(newer: newer, older: older)
            }
        }
        .style(ArticleSurfaceStyle())
        .data("article-page", "true")
    }
}
```

- [ ] **Step 2: Create `ArticleHeader`**

Create `Sources/Components/Posts/ArticleHeader.swift`:

```swift
import Foundation
import Raptor

struct ArticleHeader: HTML {
    let post: Post
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.title)
                .font(.title1)

            PostMeta(post: post)
            ArticleReadingStats(post: post)
            TaxonomyBadgeList(category: category, tags: tags)
        }
        .style(ArticleHeaderStyle())
        .data("article-header", "true")
    }
}
```

- [ ] **Step 3: Create `ArticleBody`**

Create `Sources/Components/Posts/ArticleBody.swift`:

```swift
import Foundation
import Raptor

struct ArticleBody: HTML {
    let post: Post

    var body: some HTML {
        Tag("div") {
            MarkdownContent(post: post)
        }
        .style(ArticleBodyStyle())
        .data("article-body", "true")
    }
}
```

- [ ] **Step 4: Add Markdown marker without replacing Raptor `post.text`**

Modify `Sources/Components/Posts/MarkdownContent.swift` so it becomes:

```swift
import Foundation
import Raptor

struct MarkdownContent: HTML {
    let post: Post

    var body: some HTML {
        post.text
            .data("markdown-content", "true")
    }
}
```

- [ ] **Step 5: Thin `ArticlePage`**

Modify `Sources/Pages/Posts/ArticlePage.swift` body to:

```swift
var body: some HTML {
    ArticleContent(
        post: post,
        category: category,
        tags: tags,
        newer: adjacentPosts.newer,
        older: adjacentPosts.older
    )
}
```

Keep the existing `@Environment(\.posts)`, `category`, `tags`, and `adjacentPosts` helpers.

- [ ] **Step 6: Inspect component diff before adding styles**

Run:

```bash
git diff -- Sources/Components/Posts/ArticleContent.swift Sources/Components/Posts/ArticleHeader.swift Sources/Components/Posts/ArticleBody.swift Sources/Components/Posts/MarkdownContent.swift Sources/Pages/Posts/ArticlePage.swift
```

Expected: diff only contains the three new article components, the `data-markdown-content` marker, and the thin `ArticlePage` composition change. Do not run Swift tests until Task 3 creates the referenced article styles.

## Task 3: Add Article Visual Styles

**Files:**
- Create: `Sources/Styles/Visual/ArticleSurfaceStyle.swift`
- Create: `Sources/Styles/Visual/ArticleHeaderStyle.swift`
- Create: `Sources/Styles/Visual/ArticleBodyStyle.swift`

- [ ] **Step 1: Create `ArticleSurfaceStyle`**

Create `Sources/Styles/Visual/ArticleSurfaceStyle.swift`:

```swift
import Foundation
import Raptor

struct ArticleSurfaceStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.padding(.px(20)))
                .style(.borderRadius(.px(18)))
                .style(.lineHeight(1.68))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.padding(.px(28)))
                .style(.borderRadius(.px(22)))
                .style(.lineHeight(1.72))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
                .shadow(palette.shadow, radius: 24, x: 0, y: 14)
        }
    }
}
```

- [ ] **Step 2: Create `ArticleHeaderStyle`**

Create `Sources/Styles/Visual/ArticleHeaderStyle.swift`:

```swift
import Foundation
import Raptor

struct ArticleHeaderStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.paddingBottom(.px(0)))
                .style(.lineHeight(1.35))
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid, edges: .bottom)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.paddingBottom(.px(0)))
                .style(.lineHeight(1.32))
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid, edges: .bottom)
        }
    }
}
```

- [ ] **Step 3: Create `ArticleBodyStyle`**

Create `Sources/Styles/Visual/ArticleBodyStyle.swift`:

```swift
import Foundation
import Raptor

struct ArticleBodyStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.lineHeight(1.78))
                .foregroundStyle(palette.text)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.lineHeight(1.82))
                .foregroundStyle(palette.text)
        }
    }
}
```

- [ ] **Step 4: Run visual CSS tests**

Run:

```bash
swift test --filter SitePublishingTests/publishedPagesIncludeBlueThemeVisualStyles
```

Expected: PASS for article style class and marker assertions.

Run:

```bash
swift test --filter SitePublishingTests/generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint
```

Expected: PASS for generated CSS article style assertions.

## Task 4: Full Verification And Scope Check

**Files:**
- Verify all modified files.

- [ ] **Step 1: Run full test suite**

Run:

```bash
swift test
```

Expected: all tests pass.

- [ ] **Step 2: Publish generated site**

Run:

```bash
swift run RaptorTsubame
```

Expected: publish completes successfully.

- [ ] **Step 3: Inspect generated article output**

Run:

```bash
rg -n "data-article-page|data-article-header|data-article-body|data-markdown-content|article-surface-style|article-header-style|article-body-style" Build/posts/welcome-to-tsubame/index.html Build/css/raptor-core.css
```

Expected: output contains all four data markers in article HTML and all three style class prefixes in CSS.

- [ ] **Step 4: Confirm no out-of-scope features were added**

Run:

```bash
git diff -- Sources Tests
```

Expected: diff only includes article components, article visual styles, `MarkdownContent`, `ArticlePage`, and publishing tests. It must not include cover rendering, `updated`/`lang` UI, TOC, heading anchors, related posts, series navigation, search, route changes, sidebar layout changes, or JavaScript.

- [ ] **Step 5: Inspect git status**

Run:

```bash
git status --short
```

Expected: modified/created files are limited to:

```text
 M Sources/Components/Posts/MarkdownContent.swift
 M Sources/Pages/Posts/ArticlePage.swift
 M Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
?? Sources/Components/Posts/ArticleBody.swift
?? Sources/Components/Posts/ArticleContent.swift
?? Sources/Components/Posts/ArticleHeader.swift
?? Sources/Styles/Visual/ArticleBodyStyle.swift
?? Sources/Styles/Visual/ArticleHeaderStyle.swift
?? Sources/Styles/Visual/ArticleSurfaceStyle.swift
```

## Task 5: Commit Stage 7.2A Implementation

**Files:**
- Commit all files listed in Task 4 Step 5.

- [ ] **Step 1: Stage implementation files**

Run:

```bash
git add Sources/Components/Posts/ArticleBody.swift Sources/Components/Posts/ArticleContent.swift Sources/Components/Posts/ArticleHeader.swift Sources/Components/Posts/MarkdownContent.swift Sources/Pages/Posts/ArticlePage.swift Sources/Styles/Visual/ArticleBodyStyle.swift Sources/Styles/Visual/ArticleHeaderStyle.swift Sources/Styles/Visual/ArticleSurfaceStyle.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
```

- [ ] **Step 2: Commit**

Run:

```bash
git commit -m "feat: add article reading foundation"
```

Expected: commit succeeds with only Stage 7.2A implementation files.

## Self-Review Notes

- Spec coverage: Tasks implement focused article structure, markers, token-driven styles, published-output tests, and verification. B/C expansion points remain structural only.
- Scope control: The plan explicitly forbids cover rendering, `updated`/`lang` UI, TOC, anchors, related posts, series, search, route changes, sidebar changes, and JavaScript.
- API boundary: The plan uses public Raptor patterns already present in this repo and does not depend on package-private descendant selector APIs.
- Type consistency: New public project types are `ArticleContent`, `ArticleHeader`, `ArticleBody`, `ArticleSurfaceStyle`, `ArticleHeaderStyle`, and `ArticleBodyStyle`.
