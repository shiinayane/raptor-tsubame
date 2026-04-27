# Stage 11 Discovery And Taxonomy Framework Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade archive, taxonomy, and sidebar discovery surfaces into coherent framework-level browsing pages.

**Architecture:** Build discovery-specific components instead of forcing homepage post cards everywhere. Archive gets compact chronological entries; taxonomy pages get index/detail headers and term cards; sidebar taxonomy behavior is finalized separately. All styling stays in Raptor `Style` types and all tests assert stable route/component boundaries rather than incidental generated class hashes.

**Tech Stack:** Swift, Raptor public API, Swift Testing, generated HTML/CSS assertions, static output inspection.

---

## Scope Boundaries

Included:

- Archive route discovery markers and compact archive entries.
- Category/tag index page hierarchy and term item cards.
- Category/tag detail headers and post-list context.
- Sidebar tag visible count removal while preserving count in `aria-label`.
- Sidebar category row width/alignment pass.
- Published HTML/CSS regression tests.

Excluded:

- Search.
- Client-side filters.
- JavaScript interactions.
- Article completion work.
- Identity/about/profile work.
- Final visual polish.

## File Structure

- Create `Sources/Components/Discovery/ArchiveEntry.swift`: compact archive row/card for one post.
- Create `Sources/Components/Discovery/ArchiveYearGroup.swift`: year heading plus archive entries.
- Modify `Sources/Components/Posts/ArchiveList.swift`: compose archive year groups and emit archive page marker.
- Create `Sources/Styles/Discovery/ArchiveDiscoveryStyles.swift`: archive page, year group, and entry styles.
- Modify `Sources/Components/Taxonomy/TaxonomyIndexItem.swift`: term-card structure and boundary markers.
- Modify `Sources/Components/Taxonomy/TaxonomyIndexList.swift`: taxonomy index container marker and style hook.
- Modify `Sources/Components/Taxonomy/TaxonomyPostListHeader.swift`: detail header marker/context.
- Modify taxonomy pages under `Sources/Pages/Taxonomy/`: pass taxonomy kind/context into shared components.
- Create `Sources/Styles/Discovery/TaxonomyDiscoveryStyles.swift`: taxonomy index/detail styles.
- Modify `Sources/Components/Sidebar/SidebarTagChip.swift`: remove visible count.
- Modify `Sources/Styles/Shell/SidebarNavigationStyle.swift`: category row sizing/alignment and tag-chip countless layout.
- Modify publishing tests under `Tests/RaptorTsubameTests/Publishing/`.

## Task 1: Archive Discovery Tests

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add failing archive discovery test**

Add or extend an archive publishing test:

```swift
@Test("archive renders grouped discovery entries")
func archiveRendersGroupedDiscoveryEntries() async throws {
    let harness = try await publishedSite()
    let archive = try mainSlice(of: harness.contents(of: "archive/index.html"))

    #expect(archive.contains("data-archive-page=\"true\""))
    #expect(archive.contains("data-archive-year-group=\"true\""))
    #expect(archive.contains("data-archive-entry=\"true\""))
    #expect(archive.contains("2026"))
    #expect(archive.contains("Building a Personal Website in Swift"))
    #expect(archive.contains("The first published post in the fixture set."))
    #expect(archive.contains("datetime=\"2026-04-21T00:00:00Z\""))
    #expect(archive.contains("href=\"/categories/tech/\""))
    #expect(archive.contains("href=\"/tags/swift/\""))
}
```

- [ ] **Step 2: Verify RED**

Run:

```bash
swift test --filter SitePublishingTests/archiveRendersGroupedDiscoveryEntries
```

Expected: FAIL because `data-archive-*` markers do not exist.

- [ ] **Step 3: Commit**

```bash
git add Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "test: cover archive discovery output"
```

## Task 2: Archive Discovery Components

**Files:**
- Create: `Sources/Components/Discovery/ArchiveEntry.swift`
- Create: `Sources/Components/Discovery/ArchiveYearGroup.swift`
- Modify: `Sources/Components/Posts/ArchiveList.swift`
- Create: `Sources/Styles/Discovery/ArchiveDiscoveryStyles.swift`

- [ ] **Step 1: Implement archive entry**

Create `Sources/Components/Discovery/ArchiveEntry.swift`:

```swift
import Foundation
import Raptor

struct ArchiveEntry: HTML {
    let post: Post

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            Time(post.date.formatted(date: .abbreviated, time: .omitted), dateTime: post.date)
                .style(MetadataTextStyle())
            Link(post)
            if !post.description.isEmpty {
                Text { post.description }
                    .style(MetadataTextStyle())
            }
            if hasTaxonomy {
                TaxonomyBadgeList(category: PostQueries.category(for: post), tags: PostQueries.tags(for: post))
                    .style(ArchiveEntryTaxonomyStyle())
                    .data("archive-entry-taxonomy", "true")
            }
        }
        .style(ArchiveEntryStyle())
        .data("archive-entry", "true")
    }

    private var hasTaxonomy: Bool {
        PostQueries.category(for: post) != nil || !PostQueries.tags(for: post).isEmpty
    }
}
```

- [ ] **Step 2: Implement year group**

Create `Sources/Components/Discovery/ArchiveYearGroup.swift`:

```swift
import Foundation
import Raptor

struct ArchiveYearGroup: HTML {
    let year: Int
    let posts: [Post]

    var body: some HTML {
        Section {
            VStack(alignment: .leading, spacing: 14) {
                Tag("h2") { "\(year)" }
                    .style(ArchiveYearTitleStyle())
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(posts) { post in
                        ArchiveEntry(post: post)
                    }
                }
            }
        }
        .style(ArchiveYearGroupStyle())
        .data("archive-year-group", "true")
    }
}
```

- [ ] **Step 3: Update ArchiveList**

Modify `Sources/Components/Posts/ArchiveList.swift`:

```swift
var body: some HTML {
    VStack(alignment: .leading, spacing: 24) {
        ForEach(groups) { group in
            ArchiveYearGroup(year: group.year, posts: group.posts)
        }
    }
    .style(ArchivePageStyle())
    .data("archive-page", "true")
}
```

- [ ] **Step 4: Add archive styles**

Create `Sources/Styles/Discovery/ArchiveDiscoveryStyles.swift` with focused `Style` types:

```swift
import Foundation
import Raptor

struct ArchivePageStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content.style(.gap(.px(24)))
    }
}

struct ArchiveYearGroupStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)
        return content
            .style(.padding(.px(20)))
            .style(.borderRadius(.px(20)))
            .background(palette.surface)
            .border(palette.border, width: 1, style: .solid)
    }
}

struct ArchiveYearTitleStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)
        return content.foregroundStyle(palette.accent)
    }
}

struct ArchiveEntryStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)
        return content
            .style(.padding(.px(14)))
            .style(.borderRadius(.px(16)))
            .background(palette.surfaceRaised)
            .foregroundStyle(palette.text)
    }
}

struct ArchiveEntryTaxonomyStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)
        return content.foregroundStyle(palette.mutedText)
    }
}
```

Adjust exact style calls if Raptor property names differ; keep token usage through `SiteThemePalette`.

- [ ] **Step 5: Verify GREEN**

Run:

```bash
swift test --filter SitePublishingTests/archiveRendersGroupedDiscoveryEntries
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add Sources/Components/Discovery/ArchiveEntry.swift Sources/Components/Discovery/ArchiveYearGroup.swift Sources/Components/Posts/ArchiveList.swift Sources/Styles/Discovery/ArchiveDiscoveryStyles.swift
git commit -m "feat: add archive discovery entries"
```

## Task 3: Taxonomy Index And Detail Tests

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/TaxonomyPublishingTests.swift`

- [ ] **Step 1: Add failing index/detail assertions**

Extend taxonomy publishing tests with markers:

```swift
#expect(categories.contains("data-taxonomy-index=\"category\""))
#expect(categories.contains("data-taxonomy-index-item=\"category\""))
#expect(tags.contains("data-taxonomy-index=\"tag\""))
#expect(tags.contains("data-taxonomy-index-item=\"tag\""))
#expect(notes.contains("data-taxonomy-detail=\"category\""))
#expect(notes.contains("data-taxonomy-detail-header=\"true\""))
#expect(raptor.contains("data-taxonomy-detail=\"tag\""))
#expect(raptor.contains("data-taxonomy-detail-header=\"true\""))
```

Keep existing content assertions for term names, counts, and post titles.

- [ ] **Step 2: Verify RED**

Run:

```bash
swift test --filter TaxonomyPublishingTests/rendersCategoryIndexAndDetailPages
swift test --filter TaxonomyPublishingTests/rendersTagIndexAndDetailPages
```

Expected: FAIL because new taxonomy markers do not exist.

- [ ] **Step 3: Commit**

```bash
git add Tests/RaptorTsubameTests/Publishing/TaxonomyPublishingTests.swift
git commit -m "test: cover taxonomy discovery output"
```

## Task 4: Taxonomy Discovery Components

**Files:**
- Modify: `Sources/Components/Taxonomy/TaxonomyIndexList.swift`
- Modify: `Sources/Components/Taxonomy/TaxonomyIndexItem.swift`
- Modify: `Sources/Components/Taxonomy/TaxonomyPostListHeader.swift`
- Modify: `Sources/Pages/Taxonomy/CategoriesIndexPage.swift`
- Modify: `Sources/Pages/Taxonomy/TagsIndexPage.swift`
- Modify: `Sources/Pages/Taxonomy/CategoryTermPage.swift`
- Modify: `Sources/Pages/Taxonomy/TagPage.swift`
- Create: `Sources/Styles/Discovery/TaxonomyDiscoveryStyles.swift`

- [ ] **Step 1: Extend TaxonomyIndexList**

Add `kind: TaxonomyKind` and emit:

```swift
.data("taxonomy-index", kind.rawValue)
.style(TaxonomyIndexListStyle())
```

- [ ] **Step 2: Extend TaxonomyIndexItem**

Add `kind: TaxonomyKind` and render a card with:

```swift
.data("taxonomy-index-item", kind.rawValue)
.style(TaxonomyIndexItemStyle())
```

Visible content should include name, count, and a link to the term path.

- [ ] **Step 3: Extend detail header**

Update `TaxonomyPostListHeader` to accept `kind: TaxonomyKind` and emit:

```swift
.data("taxonomy-detail-header", "true")
```

The page-level detail container should emit `data-taxonomy-detail`.

- [ ] **Step 4: Update taxonomy pages**

Pass `.category` or `.tag` to index/detail components. Wrap detail body in a container with:

```swift
.data("taxonomy-detail", term.kind.rawValue)
```

- [ ] **Step 5: Add taxonomy styles**

Create style types for index list, index item, and detail header using `SiteThemePalette`.

- [ ] **Step 6: Verify GREEN**

Run:

```bash
swift test --filter TaxonomyPublishingTests/rendersCategoryIndexAndDetailPages
swift test --filter TaxonomyPublishingTests/rendersTagIndexAndDetailPages
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add Sources/Components/Taxonomy Sources/Pages/Taxonomy Sources/Styles/Discovery/TaxonomyDiscoveryStyles.swift
git commit -m "feat: add taxonomy discovery surfaces"
```

## Task 5: Sidebar Taxonomy Finalization

**Files:**
- Modify: `Sources/Components/Sidebar/SidebarTagChip.swift`
- Modify: `Sources/Styles/Shell/SidebarNavigationStyle.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SidebarRenderingTests.swift`

- [ ] **Step 1: Add failing sidebar tests**

Extend `tagDetailPageMarksActiveSidebarTag`:

```swift
#expect(introTag.contains("aria-label=\"Intro (1)\""))
#expect(!introTag.contains("sidebar-count-badge-style"))
#expect(!introTag.contains(">1</span>"))
```

Keep category tests asserting visible category count badges.

- [ ] **Step 2: Verify RED**

Run:

```bash
swift test --filter SidebarRenderingTests/tagDetailPageMarksActiveSidebarTag
```

Expected: FAIL because tag chips still render visible count badges.

- [ ] **Step 3: Remove visible tag counts**

Modify `SidebarTagChip.linkContent`:

```swift
@InlineContentBuilder private var linkContent: some InlineContent {
    InlineText(item.name)
        .style(SidebarTagLabelStyle())
}
```

Keep `aria-label` unchanged with count.

- [ ] **Step 4: Tune category row styles**

In `SidebarNavItemStyle`, ensure rows behave like full-width navigation controls:

```swift
.style(.width(.percent(100)))
.style(.justifyContent(.spaceBetween))
```

Use exact Raptor property names already available in the style system.

- [ ] **Step 5: Verify GREEN**

Run:

```bash
swift test --filter SidebarRenderingTests/tagDetailPageMarksActiveSidebarTag
swift test --filter SidebarRenderingTests/categoryDetailPageMarksActiveSidebarCategory
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add Sources/Components/Sidebar/SidebarTagChip.swift Sources/Styles/Shell/SidebarNavigationStyle.swift Tests/RaptorTsubameTests/Publishing/SidebarRenderingTests.swift
git commit -m "feat: finalize sidebar taxonomy display"
```

## Task 6: CSS And Final Verification

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add CSS assertions**

Add a generated CSS test:

```swift
@Test("generated CSS includes discovery styles")
func generatedCSSIncludesDiscoveryStyles() async throws {
    let harness = try await publishedSite()
    let css = try harness.contents(of: "css/raptor-core.css")

    #expect(css.contains(".archive-year-group-style"))
    #expect(css.contains(".archive-entry-style"))
    #expect(css.contains(".taxonomy-index-item-style"))
    #expect(css.contains(".taxonomy-detail-header-style"))
    try expectDarkBlueThemeRule(in: css, containing: ".archive-entry-style") { rule in
        #expect(rule.contains("rgb(220 236 255 / 100%)"))
    }
}
```

Adjust class names if implementation uses slightly different style type names.

- [ ] **Step 2: Run focused CSS test**

Run:

```bash
swift test --filter SitePublishingTests/generatedCSSIncludesDiscoveryStyles
```

Expected: PASS.

- [ ] **Step 3: Run full verification**

Run:

```bash
swift test
swift run RaptorTsubame
rg -n "data-archive-page|data-taxonomy-index|data-taxonomy-detail|data-sidebar-tag-chip" Build/archive/index.html Build/categories/index.html Build/categories/notes/index.html Build/tags/index.html Build/tags/raptor/index.html
```

Expected:

- `swift test` passes.
- `swift run RaptorTsubame` exits 0 with only the existing Prism warning if still unresolved.
- `rg` finds the Stage 11 markers in generated output.

- [ ] **Step 4: Commit**

```bash
git add Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "test: verify discovery styles"
```

## Implementation Notes

- Keep Stage 10 post cards unchanged unless a Stage 11 test proves a real integration issue.
- Do not add search or filtering.
- Do not add right-side TOC behavior.
- Avoid broad visual refactors outside archive/taxonomy/sidebar discovery.
- If Raptor's style API lacks a property named in this plan, use the nearest existing style pattern from `Sources/Styles/Shell` or `Sources/Styles/Visual`.
