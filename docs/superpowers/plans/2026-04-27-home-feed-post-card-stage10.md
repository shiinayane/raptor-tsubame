# Stage 10 Home Feed And Post Card Framework Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade homepage and paginated post lists into a richer post-card feed while preserving Raptor's declarative component and `Style` boundaries.

**Architecture:** Start with a semantic markup discipline gate so Stage 10 does not blindly add wrapper `Div`s, hand-authored classes, or excessive `data-*` markers. Then add focused post-card/feed helpers, component styles, published output tests, and pagination visual alignment. Keep all visual rules in Raptor `Style` types and use `SiteThemePalette` rather than page-local colors.

**Tech Stack:** Swift, Raptor public API, Swift Testing, generated HTML/CSS assertions, static output inspection.

---

## Scope Boundaries

Included:

- Document Raptor markup discipline for `Div`, generated `class`, and `data-*` markers.
- Add home feed and post card boundary markers.
- Add richer post card metadata: date, description/excerpt, taxonomy links, reading stats, optional cover.
- Add cover/no-cover post card layout.
- Upgrade pagination presentation using existing chrome/button language.
- Add published HTML/CSS tests for homepage and page-two output.

Excluded:

- Archive timeline redesign.
- Category/tag index and detail redesign.
- Sidebar tag-count and category-width fixes.
- Search.
- JavaScript interactions.
- Global rewrite of existing shell/article/sidebar markup.
- Final visual polish.

## File Structure

- Modify `Docs/code-quality-handbook.md`: add Raptor markup discipline rules.
- Create `Sources/Components/Posts/PostCardMetadata.swift`: small helpers for card taxonomy, reading stats, and cover presence if existing types are not enough.
- Modify `Sources/Components/Posts/PostList.swift`: render feed boundary and pass post metadata into richer cards.
- Modify `Sources/Components/Posts/PostListItem.swift`: upgrade card structure while keeping semantic boundary markers sparse.
- Modify `Sources/Components/Chrome/PaginationControls.swift`: apply button/card treatment and stable markers.
- Modify `Sources/Styles/Visual/PostCardStyle.swift`: cover/no-cover layout and metadata/taxonomy styling.
- Create or modify `Sources/Styles/Visual/HomeFeedStyle.swift`: feed-level rhythm if current styles cannot express it cleanly.
- Modify `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`: published home/page-two/card/pagination output tests.
- Modify or create component tests under `Tests/RaptorTsubameTests/Components/`: helper behavior tests.

## Task 1: Raptor Markup Discipline Documentation

**Files:**
- Modify: `Docs/code-quality-handbook.md`

- [ ] **Step 1: Add the discipline section**

Append this section to `Docs/code-quality-handbook.md`:

```markdown
## Raptor Markup Discipline

Raptor Tsubame should preserve Raptor's declarative component intent. Swift components should describe site structure, `Style` types should own visual rules, and raw HTML/class escape hatches should stay limited to renderer boundaries.

Use `Style` types and `.style(...)` for visual classes. A generated class from a Raptor `Style` is expected and is not the same as hand-authoring arbitrary CSS classes in page code.

Use `data-*` markers only at component boundaries, route-level structures, or important state boundaries that tests or scoped CSS need to address. Do not add markers to every internal leaf node.

Use semantic HTML where Raptor exposes an appropriate primitive. Use `Div` or stack layout components only when the wrapper represents a real layout grouping such as a card, feed, metadata row, or responsive media/text split.

Rendered Markdown is an HTML string boundary. A single wrapper such as `data-markdown-content="true"` is acceptable there because the content is no longer a normal Raptor component tree.

Before adding a wrapper, answer: what structure does this represent, can an existing semantic element express it, and will a future maintainer understand why this node exists?
```

- [ ] **Step 2: Review existing related docs**

Run:

```bash
rg -n "Raptor Markup Discipline|data-markdown-content|Style types" Docs/code-quality-handbook.md Docs/raptor-api-boundaries.md
```

Expected: the new section appears exactly once in `Docs/code-quality-handbook.md`.

- [ ] **Step 3: Commit**

```bash
git add Docs/code-quality-handbook.md
git commit -m "docs: record raptor markup discipline"
```

## Task 2: Post Card Helper Tests

**Files:**
- Create: `Sources/Components/Posts/PostCardMetadata.swift`
- Create: `Tests/RaptorTsubameTests/Components/PostCardMetadataTests.swift`

- [ ] **Step 1: Write failing helper tests**

Create `Tests/RaptorTsubameTests/Components/PostCardMetadataTests.swift`:

```swift
import Testing
@testable import RaptorTsubame

@Suite("Post card metadata")
struct PostCardMetadataTests {
    @Test("detects cover availability from metadata image")
    func detectsCoverAvailabilityFromMetadataImage() {
        let metadata = SiteContentMetadata(["image": "./cover.jpg"])
        #expect(PostCardMetadata(metadata: metadata, body: "Body.").coverPath == "./cover.jpg")
    }

    @Test("omits cover when image metadata is absent")
    func omitsCoverWhenImageMetadataIsAbsent() {
        let metadata = SiteContentMetadata([:])
        #expect(PostCardMetadata(metadata: metadata, body: "Body.").coverPath == nil)
    }

    @Test("computes stable reading stats")
    func computesStableReadingStats() {
        let metadata = SiteContentMetadata([:])
        let card = PostCardMetadata(metadata: metadata, body: "one two three four five")
        #expect(card.wordCount == 5)
        #expect(card.readingMinutes == 1)
    }

    @Test("exposes taxonomy only when present")
    func exposesTaxonomyOnlyWhenPresent() {
        let metadata = SiteContentMetadata([
            "category": "Swift",
            "tags": "Raptor, Static Site"
        ])
        let card = PostCardMetadata(metadata: metadata, body: "Body.")

        #expect(card.category?.name == "Swift")
        #expect(card.tags.map(\.name) == ["Raptor", "Static Site"])
    }
}
```

- [ ] **Step 2: Run the failing tests**

Run:

```bash
swift test --filter PostCardMetadataTests
```

Expected: FAIL because `PostCardMetadata` does not exist.

- [ ] **Step 3: Implement helper**

Create `Sources/Components/Posts/PostCardMetadata.swift`:

```swift
import Foundation

struct PostCardMetadata: Sendable {
    let coverPath: String?
    let wordCount: Int
    let readingMinutes: Int
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]

    init(metadata: SiteContentMetadata, body: String) {
        self.coverPath = metadata.image
        self.wordCount = Self.countWords(in: body)
        self.readingMinutes = max(1, Int(ceil(Double(wordCount) / 200.0)))
        self.category = metadata.category.map { TaxonomyTerm(kind: .category, name: $0) }
        self.tags = metadata.tags.map { TaxonomyTerm(kind: .tag, name: $0) }
    }

    private static func countWords(in body: String) -> Int {
        body
            .split { $0.isWhitespace || $0.isNewline }
            .count
    }
}
```

- [ ] **Step 4: Run the helper tests**

Run:

```bash
swift test --filter PostCardMetadataTests
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Components/Posts/PostCardMetadata.swift Tests/RaptorTsubameTests/Components/PostCardMetadataTests.swift
git commit -m "feat: add post card metadata helper"
```

## Task 3: Published Feed/Card Output Tests

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add failing homepage card assertions**

Add a focused publishing test:

```swift
@Test("homepage renders rich post card feed")
func homepageRendersRichPostCardFeed() async throws {
    let harness = try await publishedSite()
    let homepage = try harness.contents(of: "index.html")
    let main = try mainSlice(of: homepage)

    #expect(main.contains("data-home-feed=\"true\""))
    #expect(occurrenceCount(of: "data-post-card=\"true\"", in: main) == 2)
    #expect(main.contains("data-post-card-taxonomy=\"true\""))
    #expect(main.contains("data-post-card-stats=\"true\""))
    #expect(main.contains("Building a Personal Website in Swift"))
    #expect(main.contains("Fuwari Study Notes"))
    #expect(main.contains("The first published post in the fixture set."))
    #expect(main.contains("Structural notes from studying the Fuwari theme."))
    #expect(main.contains("datetime=\"2026-04-21T00:00:00Z\""))
    #expect(main.contains("datetime=\"2026-03-01T00:00:00Z\""))
}
```

Add a focused pagination/card consistency test:

```swift
@Test("paginated homepage keeps rich feed and pagination markers")
func paginatedHomepageKeepsRichFeedAndPaginationMarkers() async throws {
    let harness = try await publishedSite()
    let pageTwo = try harness.contents(of: "2/index.html")
    let main = try mainSlice(of: pageTwo)

    #expect(main.contains("data-home-feed=\"true\""))
    #expect(main.contains("data-post-card=\"true\""))
    #expect(main.contains("data-pagination=\"true\""))
    #expect(main.contains("data-pagination-link=\"newer\""))
    #expect(!main.contains("data-pagination-link=\"older\""))
}
```

- [ ] **Step 2: Run failing publishing tests**

Run:

```bash
swift test --filter SitePublishingTests/homepageRendersRichPostCardFeed
swift test --filter SitePublishingTests/paginatedHomepageKeepsRichFeedAndPaginationMarkers
```

Expected: FAIL because the new feed/card boundary markers and richer card metadata do not exist yet.

- [ ] **Step 3: Do not implement in this task**

Keep this task test-only. Implementation happens in Tasks 4 and 5.

- [ ] **Step 4: Commit**

```bash
git add Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "test: cover rich home feed output"
```

## Task 4: Home Feed And Rich Post Card Components

**Files:**
- Modify: `Sources/Components/Posts/PostList.swift`
- Modify: `Sources/Components/Posts/PostListItem.swift`
- Modify: `Sources/Styles/Visual/PostCardStyle.swift`
- Create if needed: `Sources/Styles/Visual/HomeFeedStyle.swift`

- [ ] **Step 1: Implement feed boundary in `PostList`**

Update the outer post-list container to emit:

```swift
.data("home-feed", "true")
```

Apply `HomeFeedStyle()` if a dedicated feed style is introduced.

- [ ] **Step 2: Implement richer `PostListItem` structure**

Each card should emit these markers only at meaningful boundaries:

```swift
.data("post-card", "true")
.data("post-card-taxonomy", "true")
.data("post-card-stats", "true")
```

Do not add leaf markers for title, date, or description. Tests should assert that those values are visible inside the feed/card output instead of requiring marker attributes on every internal node. Only emit taxonomy and cover boundaries when data exists.

- [ ] **Step 3: Render taxonomy links**

Use `TaxonomyTerm` route helpers already used by taxonomy/sidebar components. Category and tag labels should link to their detail routes.

- [ ] **Step 4: Render reading stats**

Use `PostCardMetadata` to render word count and reading minutes. Keep text compact and avoid adding icon boxes unless the card design clearly needs them.

- [ ] **Step 5: Render optional cover**

When `PostCardMetadata.coverPath` exists, emit a cover boundary:

```swift
.data("post-card-cover", "true")
```

Do not render an empty cover shell when the image is missing.

- [ ] **Step 6: Update card/feed styles**

Keep styles in `Style` types. Use `SiteThemePalette` for:

- surface background
- raised surface
- border
- text
- muted text
- accent
- shadow

Do not add page-local raw colors in component bodies.

- [ ] **Step 7: Run publishing tests**

Run:

```bash
swift test --filter SitePublishingTests/homepageRendersRichPostCardFeed
swift test --filter SitePublishingTests/paginatedHomepageKeepsRichFeedAndPaginationMarkers
```

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add Sources/Components/Posts/PostList.swift Sources/Components/Posts/PostListItem.swift Sources/Styles/Visual/PostCardStyle.swift Sources/Styles/Visual/HomeFeedStyle.swift
git commit -m "feat: upgrade home post cards"
```

If `HomeFeedStyle.swift` was not created, omit it from `git add`.

## Task 5: Pagination Visual Alignment

**Files:**
- Modify: `Sources/Components/Chrome/PaginationControls.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add pagination CSS/output assertions**

Extend the pagination publishing test to assert:

```swift
#expect(main.contains("data-pagination=\"true\""))
#expect(main.contains("data-pagination-page=\"true\""))
```

Add CSS assertions for the style class used by pagination controls.

- [ ] **Step 2: Update pagination component**

Render pagination as a stable component boundary:

```swift
.data("pagination", "true")
```

Render page status with:

```swift
.data("pagination-page", "true")
```

Render links with:

```swift
.data("pagination-link", "newer")
.data("pagination-link", "older")
```

Use existing `ChromeButtonLink` where it fits. If the existing primitive cannot express disabled/missing states cleanly, keep the logic local and reuse the same visual `Style` language.

- [ ] **Step 3: Run focused tests**

Run:

```bash
swift test --filter SitePublishingTests/paginatedHomepageKeepsRichFeedAndPaginationMarkers
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add Sources/Components/Chrome/PaginationControls.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "feat: align pagination with chrome primitives"
```

## Task 6: CSS And Semantic Regression Checks

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add CSS generation test**

Add a generated CSS test that checks:

```swift
#expect(css.contains(".post-card-style"))
#expect(css.contains(".home-feed-style"))
#expect(css.contains("[data-color-scheme=\"dark\"]"))
```

If no `HomeFeedStyle` is introduced, assert the actual feed/card style class used by implementation instead.

- [ ] **Step 2: Add marker-sprawl guard**

Add a small assertion that post cards expose boundary markers without requiring every leaf node to have a marker:

```swift
let firstCard = try htmlSlice(containing: "data-post-card=\"true\"", in: main)
#expect(occurrenceCount(of: "data-post-card-", in: firstCard) <= 8)
```

Use the existing helper style in `SitePublishingTests` for slicing. If no helper exists for this exact case, add a narrow helper near existing HTML helpers.

- [ ] **Step 3: Run focused tests**

Run:

```bash
swift test --filter SitePublishingTests/generatedCSSIncludesPostCardFeedStyles
swift test --filter SitePublishingTests/homepageRendersRichPostCardFeed
```

Expected: PASS.

- [ ] **Step 4: Run full verification**

Run:

```bash
swift test
swift run RaptorTsubame
rg -n "data-home-feed|data-post-card|data-pagination" Build/index.html Build/2/index.html
```

Expected:

- `swift test` passes.
- `swift run RaptorTsubame` exits 0.
- `rg` finds feed, card, and pagination markers in generated output.

- [ ] **Step 5: Commit**

```bash
git add Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "test: guard home feed semantics"
```

## Implementation Notes

- Do not touch archive/category/tag page information architecture in Stage 10.
- Do not solve sidebar tag counts or category width in Stage 10.
- Do not introduce JavaScript.
- Prefer semantic Raptor components and existing chrome primitives over new wrapper layers.
- If implementation pressure suggests adding many new markers, stop and revise the component boundary instead.
