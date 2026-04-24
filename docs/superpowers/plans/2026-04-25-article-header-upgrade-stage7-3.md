# Article Header Upgrade Stage 7.3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade article headers with a Fuwari-inspired but Tsubame-native metadata/header system using existing `image`, `updated`, and `lang` metadata.

**Architecture:** Keep `ArticlePage` thin and make `ArticleHeader` the composition root for title, reading stats, metadata, and cover. Add small focused components for title, metadata items, metadata row, and cover; add token-driven styles under `Sources/Styles/Visual`; seed new article-only styles through the existing `ArticleStyleSeed` workaround.

**Tech Stack:** Swift 6, Raptor `HTML`/`Style` public APIs, Swift Testing, published HTML/CSS assertions.

---

## Fuwari Size Reference

Stage 7.3 should use Fuwari's post page dimensions as a reference while preserving Tsubame's Raptor implementation and blue theme tokens:

- Fuwari post card padding: `px-6 md:px-9 pt-6 pb-4`, roughly 24px mobile horizontal, 36px desktop horizontal, 24px top, 16px bottom.
- Fuwari reading stats icons: `h-6 w-6`, 24px square.
- Fuwari metadata icons: `.meta-icon`, `w-8 h-8`, 32px square.
- Fuwari title: `text-3xl md:text-[2.25rem]/[2.75rem]`, roughly 30px mobile and 36px/44px desktop.
- Fuwari title accent: `md:before:w-1 before:h-5`, a narrow 4px by 20px vertical bar on desktop.
- Fuwari cover: `mb-8 rounded-xl banner-container`, full content width, rounded-xl density, and clear 32px bottom spacing.

Implementation should not copy Tailwind classes. It should translate these sizes into Raptor `Style` values that fit the existing Tsubame article surface.

## File Structure

- Modify `Posts/posts/welcome-to-tsubame.md`: add fixture metadata for `image`, `updated`, and `lang`.
- Create `Assets/images/tsubame-cover.svg`: lightweight local cover asset used by the fixture.
- Modify `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`: add RED tests for article title, metadata items, optional cover, and new generated CSS.
- Create `Sources/Components/Posts/ArticleTitleBlock.swift`: owns title accent bar and title text.
- Create `Sources/Components/Posts/ArticleMetadataItem.swift`: reusable icon block + content item; all glyph centering goes through this component.
- Create `Sources/Components/Posts/ArticleMetadataRow.swift`: owns publish date, updated date, language, category, and tag links.
- Create `Sources/Components/Posts/ArticleCover.swift`: owns optional cover rendering.
- Modify `Sources/Components/Posts/ArticleReadingStats.swift`: render reading stats through `ArticleMetadataItem`.
- Modify `Sources/Components/Posts/ArticleHeader.swift`: compose the upgraded header.
- Modify `Sources/Components/Posts/ArticleStyleSeed.swift`: register new article-only styles.
- Create `Sources/Styles/Visual/ArticleTitleBlockStyle.swift`: title row and accent/title styling.
- Create `Sources/Styles/Visual/ArticleMetadataItemStyle.swift`: icon block, glyph centering, gaps, muted text, and wrapping.
- Create `Sources/Styles/Visual/ArticleCoverStyle.swift`: cover wrapper and image treatment.

## Task 1: Published Output Tests And Fixture Metadata

**Files:**
- Modify: `Posts/posts/welcome-to-tsubame.md`
- Create: `Assets/images/tsubame-cover.svg`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add fixture metadata and a local cover asset**

Update `Posts/posts/welcome-to-tsubame.md` front matter:

```markdown
---
title: Welcome To Tsubame
date: 2026-01-01
updated: 2026-02-01
lang: en
image: /images/tsubame-cover.svg
description: The first published post in the fixture set.
published: true
category: Updates
tags: Intro, Site
---
```

Create `Assets/images/tsubame-cover.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630" role="img" aria-label="Abstract blue Tsubame cover">
  <defs>
    <linearGradient id="sky" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#9fddff"/>
      <stop offset="0.48" stop-color="#f7fbff"/>
      <stop offset="1" stop-color="#163454"/>
    </linearGradient>
    <linearGradient id="wing" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#4a8bcb"/>
      <stop offset="1" stop-color="#78b8f5"/>
    </linearGradient>
  </defs>
  <rect width="1200" height="630" fill="url(#sky)"/>
  <circle cx="1000" cy="110" r="140" fill="#ffd874" opacity="0.85"/>
  <path d="M110 455 C310 275 475 245 640 355 C790 455 960 410 1095 250 C960 520 720 570 520 470 C355 390 230 420 110 455Z" fill="#102a44" opacity="0.78"/>
  <path d="M235 300 C395 115 585 95 760 220 C610 205 495 260 395 370 C340 330 285 310 235 300Z" fill="url(#wing)" opacity="0.92"/>
  <path d="M565 310 C705 145 910 135 1065 265 C895 245 780 300 680 410 C640 365 600 335 565 310Z" fill="#244762" opacity="0.86"/>
  <text x="80" y="120" font-family="Arial, sans-serif" font-size="54" font-weight="800" fill="#13283e">Raptor Tsubame</text>
  <text x="84" y="176" font-family="Arial, sans-serif" font-size="28" font-weight="700" fill="#58718b">Swift static site notes</text>
</svg>
```

- [ ] **Step 2: Add failing article header assertions**

In `rendersArticlePage()`, after `let main = try mainSlice(of: article)`, add:

```swift
#expect(main.contains("data-article-title=\"true\""))
#expect(main.contains("data-article-title-accent=\"true\""))
#expect(main.contains("data-article-metadata-row=\"true\""))
#expect(main.contains("data-article-meta-item=\"reading-words\""))
#expect(main.contains("data-article-meta-item=\"reading-minutes\""))
#expect(main.contains("data-article-meta-item=\"published\""))
#expect(main.contains("data-article-meta-item=\"updated\""))
#expect(main.contains("data-article-meta-item=\"lang\""))
#expect(main.contains("data-article-meta-item=\"category\""))
#expect(main.contains("data-article-meta-item=\"tags\""))
#expect(main.contains("2026-02-01"))
#expect(main.contains("en"))
#expect(main.contains("data-article-cover=\"true\""))
#expect(main.contains("tsubame-cover"))
```

Add an absence assertion using a post without `image`:

```swift
let articleWithoutCover = try mainSlice(of: harness.contents(of: "posts/raptor-notes/index.html"))
#expect(!articleWithoutCover.contains("data-article-cover=\"true\""))
```

- [ ] **Step 3: Add failing visual HTML assertions**

In `publishedPagesIncludeBlueThemeVisualStyles()`, add article-specific style expectations:

```swift
#expect(article.contains("article-title-block-style"))
#expect(article.contains("article-title-accent-style"))
#expect(article.contains("article-metadata-item-style"))
#expect(article.contains("article-reading-icon-style"))
#expect(article.contains("article-metadata-icon-style"))
#expect(article.contains("article-cover-style"))
#expect(article.contains("data-article-meta-icon=\"true\""))
```

- [ ] **Step 4: Add failing generated CSS assertions**

In `expectBlueThemeVisualCSS(in:)`, add:

```swift
#expect(css.contains(".article-title-block-style"))
#expect(css.contains(".article-title-accent-style"))
#expect(css.contains(".article-metadata-item-style"))
#expect(css.contains(".article-reading-icon-style"))
#expect(css.contains(".article-metadata-icon-style"))
#expect(css.contains(".article-cover-style"))

let readingIconRule = try cssRule(in: css, containing: ".article-reading-icon-style")
#expect(readingIconRule.contains("align-items: center;"))
#expect(readingIconRule.contains("justify-content: center;"))
#expect(readingIconRule.contains("width: 24px;"))
#expect(readingIconRule.contains("height: 24px;"))

let metadataIconRule = try cssRule(in: css, containing: ".article-metadata-icon-style")
#expect(metadataIconRule.contains("align-items: center;"))
#expect(metadataIconRule.contains("justify-content: center;"))
#expect(metadataIconRule.contains("width: 32px;"))
#expect(metadataIconRule.contains("height: 32px;"))
#expect(metadataIconRule.contains("rgb(74 139 203 / 100%)"))

try expectDarkBlueThemeRule(in: css, containing: ".article-metadata-icon-style") { rule in
    #expect(rule.contains("rgb(120 184 245 / 100%)"))
}
```

If Raptor emits `display: flex;` rather than `inline-flex`, assert the generated value that actually appears after the first RED run.

- [ ] **Step 5: Run tests to verify RED**

Run:

```bash
swift test --filter SitePublishingTests/rendersArticlePage
swift test --filter SitePublishingTests/publishedPagesIncludeBlueThemeVisualStyles
swift test --filter SitePublishingTests/generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint
```

Expected: at least one focused test fails because the new article header markers/styles do not exist yet.

## Task 2: Article Header Components

**Files:**
- Create: `Sources/Components/Posts/ArticleTitleBlock.swift`
- Create: `Sources/Components/Posts/ArticleMetadataItem.swift`
- Create: `Sources/Components/Posts/ArticleMetadataRow.swift`
- Create: `Sources/Components/Posts/ArticleCover.swift`
- Modify: `Sources/Components/Posts/ArticleReadingStats.swift`
- Modify: `Sources/Components/Posts/ArticleHeader.swift`

- [ ] **Step 1: Create title block**

Create `Sources/Components/Posts/ArticleTitleBlock.swift`:

```swift
import Foundation
import Raptor

struct ArticleTitleBlock: HTML {
    let title: String

    var body: some HTML {
        HStack(spacing: 18) {
            Tag("span")
                .style(ArticleTitleAccentStyle())
                .data("article-title-accent", "true")

            Text(title)
                .font(.title1)
                .style(ArticleTitleTextStyle())
        }
        .style(ArticleTitleBlockStyle())
        .data("article-title", "true")
    }
}
```

- [ ] **Step 2: Create reusable metadata item**

Create `Sources/Components/Posts/ArticleMetadataItem.swift`:

```swift
import Foundation
import Raptor

struct ArticleMetadataItem<Content: HTML>: HTML {
    let kind: String
    let icon: String
    var scale: ArticleMetadataIconScale = .metadata
    private let content: Content

    init(
        kind: String,
        icon: String,
        scale: ArticleMetadataIconScale = .metadata,
        @HTMLBuilder content: () -> Content
    ) {
        self.kind = kind
        self.icon = icon
        self.scale = scale
        self.content = content()
    }

    var body: some HTML {
        HStack(spacing: 10) {
            iconBlock

            Tag("span") {
                content
            }
            .data("article-meta-content", kind)
        }
        .style(ArticleMetadataItemStyle())
        .data("article-meta-item", kind)
    }

    @HTMLBuilder private var iconBlock: some HTML {
        switch scale {
        case .reading:
            Tag("span") {
                Text(icon)
            }
            .style(ArticleReadingIconStyle())
            .data("article-meta-icon", "true")
        case .metadata:
            Tag("span") {
                Text(icon)
            }
            .style(ArticleMetadataIconStyle())
            .data("article-meta-icon", "true")
        }
    }
}
```

- [ ] **Step 3: Create metadata row**

Create `Sources/Components/Posts/ArticleMetadataRow.swift`:

```swift
import Foundation
import Raptor

struct ArticleMetadataRow: HTML {
    let post: Post
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]

    private var metadata: SiteContentMetadata {
        SiteContentMetadata(post.metadata)
    }

    var body: some HTML {
        HStack(spacing: 16) {
            ArticleMetadataItem(kind: "published", icon: "□") {
                Time(post.date.formatted(date: .abbreviated, time: .omitted), dateTime: post.date)
            }

            if let updated = metadata.updated {
                ArticleMetadataItem(kind: "updated", icon: "↻") {
                    Text("Updated \(updated)")
                }
            }

            if let lang = metadata.lang {
                ArticleMetadataItem(kind: "lang", icon: "文") {
                    Text(lang)
                }
            }

            if let category {
                ArticleMetadataItem(kind: "category", icon: "□") {
                    Link(category.name, destination: category.path)
                }
            }

            if !tags.isEmpty {
                ArticleMetadataItem(kind: "tags", icon: "#") {
                    HStack(spacing: 8) {
                        ForEach(tags) { tag in
                            Link(tag.name, destination: tag.path)
                        }
                    }
                }
            }
        }
        .data("article-metadata-row", "true")
    }
}
```

If Swift's type checker rejects the nested `ForEach` closure inside `ArticleMetadataItem`, replace only the tags item content with a small `ArticleTagLinks` component in the same task.

- [ ] **Step 4: Create optional cover**

Create `Sources/Components/Posts/ArticleCover.swift`:

```swift
import Foundation
import Raptor

struct ArticleCover: HTML {
    let post: Post

    private var altText: String {
        post.imageDescription.isEmpty ? "\(post.title) cover image" : post.imageDescription
    }

    var body: some HTML {
        if let image = post.image {
            Tag("figure") {
                Image(image, description: altText)
                    .resizable()
                    .imageFit(.cover)
                    .style(ArticleCoverImageStyle())
                    .data("article-cover-image", "true")
            }
            .style(ArticleCoverStyle())
            .data("article-cover", "true")
        }
    }
}
```

- [ ] **Step 5: Update reading stats to reuse metadata items**

Replace `Sources/Components/Posts/ArticleReadingStats.swift` with:

```swift
import Foundation
import Raptor

struct ArticleReadingStats: HTML {
    let post: Post

    var body: some HTML {
        HStack(spacing: 16) {
            ArticleMetadataItem(kind: "reading-words", icon: "☰", scale: .reading) {
                Text("\(post.estimatedWordCount) words")
            }

            ArticleMetadataItem(kind: "reading-minutes", icon: "◷", scale: .reading) {
                Text("\(post.estimatedReadingMinutes) min read")
            }
        }
        .data("reading-stats", "true")
    }
}
```

- [ ] **Step 6: Update article header composition**

Replace `ArticleHeader.body` with:

```swift
var body: some HTML {
    VStack(alignment: .leading, spacing: 18) {
        ArticleReadingStats(post: post)
        ArticleTitleBlock(title: post.title)
        ArticleMetadataRow(post: post, category: category, tags: tags)

        if !post.description.isEmpty {
            Text { post.description }
                .style(MetadataTextStyle())
                .data("article-description", "true")
        }

        ArticleCover(post: post)
    }
    .style(ArticleHeaderStyle())
    .data("article-header", "true")
}
```

- [ ] **Step 7: Run focused HTML test**

Run:

```bash
swift test --filter SitePublishingTests/rendersArticlePage
```

Expected: article header HTML assertions pass or fail only on missing CSS/style class assertions that Task 3 will add.

## Task 3: Header Styles And Style Seeding

**Files:**
- Create: `Sources/Styles/Visual/ArticleTitleBlockStyle.swift`
- Create: `Sources/Styles/Visual/ArticleMetadataItemStyle.swift`
- Create: `Sources/Styles/Visual/ArticleCoverStyle.swift`
- Modify: `Sources/Components/Posts/ArticleStyleSeed.swift`

- [ ] **Step 1: Create title styles**

Create `Sources/Styles/Visual/ArticleTitleBlockStyle.swift`:

```swift
import Foundation
import Raptor

struct ArticleTitleBlockStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.alignItems(.center))
        } else {
            content
                .style(.width(.percent(100)))
                .style(.alignItems(.center))
        }
    }
}

struct ArticleTitleAccentStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.width(.px(4)))
            .style(.height(.px(20)))
            .style(.borderRadius(.px(999)))
            .background(palette.accent)
    }
}

struct ArticleTitleTextStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .foregroundStyle(palette.text)
                .style(.lineHeight(1.12))
        } else {
            content
                .foregroundStyle(palette.text)
                .style(.lineHeight(1.08))
        }
    }
}
```

If `.style(.alignItems(.center))` is not available in Raptor's public API, remove that line and rely on `HStack`'s default center alignment. Do not use private CSS APIs.

- [ ] **Step 2: Create metadata item styles**

Create `Sources/Styles/Visual/ArticleMetadataItemStyle.swift`:

```swift
import Foundation
import Raptor

struct ArticleMetadataItemStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.alignItems(.center))
            .foregroundStyle(palette.mutedText)
    }
}

enum ArticleMetadataIconScale: Sendable {
    case reading
    case metadata
}

struct ArticleReadingIconStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.flex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.width(.px(24)))
            .style(.height(.px(24)))
            .style(.borderRadius(.px(6)))
            .style(.lineHeight(1))
            .background(palette.surfaceRaised)
            .foregroundStyle(palette.accent)
    }
}

struct ArticleMetadataIconStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.flex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.width(.px(32)))
            .style(.height(.px(32)))
            .style(.borderRadius(.px(8)))
            .style(.lineHeight(1))
            .background(palette.surfaceRaised)
            .foregroundStyle(palette.accent)
    }
}
```

If Raptor uses different public enum names for `display`, `alignItems`, or `justifyContent`, inspect nearby existing Raptor style modifier names and adapt to the public names. Keep the generated CSS assertions aligned with the actual public API output.

- [ ] **Step 3: Create cover styles**

Create `Sources/Styles/Visual/ArticleCoverStyle.swift`:

```swift
import Foundation
import Raptor

struct ArticleCoverStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.height(.px(220)))
                .style(.borderRadius(.px(16)))
                .style(.overflow(.hidden))
                .background(palette.surfaceRaised)
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.height(.px(320)))
                .style(.borderRadius(.px(18)))
                .style(.overflow(.hidden))
                .background(palette.surfaceRaised)
                .border(palette.border, width: 1, style: .solid)
        }
    }
}

struct ArticleCoverImageStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.width(.percent(100)))
            .style(.height(.percent(100)))
    }
}
```

If `.overflow(.hidden)` is not available as a public style modifier, use the public `.clipped()` modifier on the cover wrapper if it works with the surrounding style. Do not introduce global raw CSS.

- [ ] **Step 4: Seed new article-only styles**

Update `ArticleStyleSeed.body`:

```swift
var body: some HTML {
    EmptyHTML().style(ArticleSurfaceStyle())
    EmptyHTML().style(ArticleHeaderStyle())
    EmptyHTML().style(ArticleBodyStyle())
    EmptyHTML().style(ArticleTitleBlockStyle())
    EmptyHTML().style(ArticleTitleAccentStyle())
    EmptyHTML().style(ArticleTitleTextStyle())
    EmptyHTML().style(ArticleMetadataItemStyle())
    EmptyHTML().style(ArticleReadingIconStyle())
    EmptyHTML().style(ArticleMetadataIconStyle())
    EmptyHTML().style(ArticleCoverStyle())
    EmptyHTML().style(ArticleCoverImageStyle())
}
```

- [ ] **Step 5: Run focused CSS tests**

Run:

```bash
swift test --filter SitePublishingTests/publishedPagesIncludeBlueThemeVisualStyles
swift test --filter SitePublishingTests/generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint
```

Expected: both tests pass after adapting assertions to exact public Raptor CSS output.

## Task 4: Full Verification And Output Inspection

**Files:**
- No planned source edits unless verification exposes a bug.

- [ ] **Step 1: Run full test suite**

Run:

```bash
swift test
```

Expected: all suites pass.

- [ ] **Step 2: Generate the site**

Run:

```bash
swift run RaptorTsubame
```

Expected: publish completes successfully.

- [ ] **Step 3: Inspect published article output**

Run:

```bash
rg -n "data-article-title|data-article-meta-item|data-article-meta-icon|data-article-cover|tsubame-cover" Build/posts/welcome-to-tsubame/index.html
rg -n "article-title-block-style|article-title-accent-style|article-metadata-item-style|article-reading-icon-style|article-metadata-icon-style|article-cover-style" Build/css/raptor-core.css
```

Expected: all markers and style classes are present.

- [ ] **Step 4: Inspect no-cover article output**

Run:

```bash
rg -n "data-article-cover" Build/posts/raptor-notes/index.html
```

Expected: no output from `rg`; `raptor-notes` has no cover markup.

- [ ] **Step 5: Browser visual QA**

Open the generated site through the existing local preview flow or run the current preview command used in this repo. Inspect:

- `posts/welcome-to-tsubame/` in light mode.
- `posts/welcome-to-tsubame/` in dark mode.
- Narrow mobile viewport.

Expected:

- Icon blocks are compact and visually centered.
- Title accent and title color are high contrast.
- Muted metadata text remains readable.
- Cover is rounded, contained, and does not push the sidebar.

## Task 5: Commit Stage 7.3 Implementation

**Files:**
- Commit only Stage 7.3 implementation files.
- Do not stage unrelated `Posts/posts/build-website-in-swift.md` unless the user explicitly says to include it.

- [ ] **Step 1: Check status**

Run:

```bash
git status --short
```

Expected: Stage 7.3 source/test/asset files are modified or untracked; unrelated `Posts/posts/build-website-in-swift.md` may remain untracked.

- [ ] **Step 2: Stage implementation files**

Run:

```bash
git add Posts/posts/welcome-to-tsubame.md Assets/images/tsubame-cover.svg Sources Tests
```

Expected: only intended Stage 7.3 files are staged.

- [ ] **Step 3: Review staged diff**

Run:

```bash
git diff --cached --stat
git diff --cached --name-only
```

Expected: staged files match this plan and exclude unrelated content.

- [ ] **Step 4: Commit**

Run:

```bash
git commit -m "feat: upgrade article header"
```

Expected: commit succeeds with Stage 7.3 implementation.
