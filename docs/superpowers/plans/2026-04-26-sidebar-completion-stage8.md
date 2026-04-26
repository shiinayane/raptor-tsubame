# Sidebar Completion Stage 8 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the existing left site sidebar as a stable profile, category, and tag navigation surface with route-aware active states.

**Architecture:** Keep article TOC inline in the article body and do not introduce a third layout column. Sidebar state is derived from Raptor's public `@Environment(\.page)` metadata and converted into a project-owned `SidebarSelection` model, so components do not depend on private Raptor rendering context. Styling stays in focused shell/sidebar style files and uses existing `SiteThemePalette` tokens.

**Tech Stack:** Swift, Raptor public API, Swift Testing, static HTML output inspection, generated CSS assertions.

---

## Scope Boundaries

This plan implements the accepted Stage 8 direction from `docs/superpowers/specs/2026-04-26-sidebar-completion-stage8-design.md`.

Included:
- Profile, category, and tag sidebar sections.
- Category rows with count badges and active markers.
- Tag chips with count badges and active markers.
- Route awareness for `/categories/<slug>/` and `/tags/<slug>/`.
- Responsive behavior that preserves the existing desktop-left and mobile-after-main shell.

Excluded:
- Right-side TOC.
- Sticky sidebar.
- Three-column layout.
- JavaScript interactions.
- Search.
- Recent Posts.
- Comments, analytics, or widget systems.
- Article heading extraction or article TOC behavior changes.

## File Structure

- Create `Sources/Components/Sidebar/SidebarSelection.swift`: project-owned active-state model derived from current page path.
- Create `Sources/Components/Sidebar/SidebarSectionTitle.swift`: shared section label markup and marker.
- Create `Sources/Components/Sidebar/SidebarNavItem.swift`: category row component with active/current markers and count badge.
- Create `Sources/Components/Sidebar/SidebarTagChip.swift`: compact tag chip component with active/current markers and count badge.
- Modify `Sources/Layouts/MainLayout.swift`: read `@Environment(\.page)` and pass `SidebarSelection` into sidebar components.
- Modify `Sources/Components/Sidebar/SidebarCategories.swift`: render section title and category nav rows.
- Modify `Sources/Components/Sidebar/SidebarTags.swift`: render section title and tag chips.
- Create `Sources/Styles/Shell/SidebarNavigationStyle.swift`: row/chip/title/count styling using `SiteThemePalette`.
- Modify `Tests/RaptorTsubameTests/Components/SidebarSupportTests.swift`: model-level active-state tests.
- Modify `Tests/RaptorTsubameTests/Publishing/SidebarRenderingTests.swift`: generated sidebar markers and current-state tests.
- Modify `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`: generated CSS assertions for sidebar navigation styles.

## Public API Note

Use this public Raptor path in `MainLayout`:

```swift
@Environment(\.page) private var page
```

Then derive selection from:

```swift
SidebarSelection(path: page.url.path)
```

Do not import or reference `RenderingContext`; it is package-level inside Raptor and is not a stable project boundary.

## Task 1: Sidebar Selection Model

**Files:**
- Create: `Sources/Components/Sidebar/SidebarSelection.swift`
- Modify: `Tests/RaptorTsubameTests/Components/SidebarSupportTests.swift`

- [ ] **Step 1: Write failing tests for path-derived selection**

Append these tests to `SidebarSupportTests`:

```swift
@Test("sidebar selection recognizes active category routes")
func sidebarSelectionRecognizesCategoryRoutes() {
    let selection = SidebarSelection(path: "/categories/site-updates/")
    let active = TaxonomyCountItem(term: TaxonomyTerm(kind: .category, name: "Site Updates"), count: 2)
    let inactive = TaxonomyCountItem(term: TaxonomyTerm(kind: .category, name: "Notes"), count: 1)
    let tag = TaxonomyCountItem(term: TaxonomyTerm(kind: .tag, name: "Site Updates"), count: 3)

    #expect(selection.activeCategorySlug == "site-updates")
    #expect(selection.activeTagSlug == nil)
    #expect(selection.isActive(active))
    #expect(!selection.isActive(inactive))
    #expect(!selection.isActive(tag))
}

@Test("sidebar selection recognizes active tag routes")
func sidebarSelectionRecognizesTagRoutes() {
    let selection = SidebarSelection(path: "/tags/raptor-notes/")
    let active = TaxonomyCountItem(term: TaxonomyTerm(kind: .tag, name: "Raptor Notes"), count: 3)
    let inactive = TaxonomyCountItem(term: TaxonomyTerm(kind: .tag, name: "Swift"), count: 1)
    let category = TaxonomyCountItem(term: TaxonomyTerm(kind: .category, name: "Raptor Notes"), count: 2)

    #expect(selection.activeCategorySlug == nil)
    #expect(selection.activeTagSlug == "raptor-notes")
    #expect(selection.isActive(active))
    #expect(!selection.isActive(inactive))
    #expect(!selection.isActive(category))
}

@Test("sidebar selection ignores non-taxonomy routes")
func sidebarSelectionIgnoresNonTaxonomyRoutes() {
    let selection = SidebarSelection(path: "/posts/welcome-to-tsubame/")
    let category = TaxonomyCountItem(term: TaxonomyTerm(kind: .category, name: "Updates"), count: 2)
    let tag = TaxonomyCountItem(term: TaxonomyTerm(kind: .tag, name: "Intro"), count: 1)

    #expect(selection.activeCategorySlug == nil)
    #expect(selection.activeTagSlug == nil)
    #expect(!selection.isActive(category))
    #expect(!selection.isActive(tag))
}
```

- [ ] **Step 2: Run the focused failing test**

Run:

```bash
swift test --filter SidebarSupportTests/sidebarSelectionRecognizesCategoryRoutes
```

Expected: FAIL because `SidebarSelection` does not exist.

- [ ] **Step 3: Implement `SidebarSelection`**

Create `Sources/Components/Sidebar/SidebarSelection.swift`:

```swift
import Foundation

struct SidebarSelection: Equatable, Sendable {
    let activeCategorySlug: String?
    let activeTagSlug: String?

    init(path: String) {
        let normalizedPath = SidebarSelection.normalized(path)

        if let slug = SidebarSelection.slug(in: normalizedPath, after: "/categories/") {
            self.activeCategorySlug = slug
            self.activeTagSlug = nil
        } else if let slug = SidebarSelection.slug(in: normalizedPath, after: "/tags/") {
            self.activeCategorySlug = nil
            self.activeTagSlug = slug
        } else {
            self.activeCategorySlug = nil
            self.activeTagSlug = nil
        }
    }

    func isActive(_ item: TaxonomyCountItem) -> Bool {
        switch item.term.kind {
        case .category:
            item.term.slug == activeCategorySlug
        case .tag:
            item.term.slug == activeTagSlug
        }
    }

    private static func normalized(_ path: String) -> String {
        guard path.hasSuffix("/") else {
            return path + "/"
        }

        return path
    }

    private static func slug(in path: String, after prefix: String) -> String? {
        guard path.hasPrefix(prefix) else {
            return nil
        }

        let remainder = path.dropFirst(prefix.count)
        let slug = remainder.split(separator: "/", omittingEmptySubsequences: true).first

        return slug.map(String.init)
    }
}
```

- [ ] **Step 4: Run focused model tests**

Run:

```bash
swift test --filter SidebarSupportTests/sidebarSelection
```

Expected: PASS for the three new `sidebarSelection...` tests.

- [ ] **Step 5: Commit**

```bash
git add Sources/Components/Sidebar/SidebarSelection.swift Tests/RaptorTsubameTests/Components/SidebarSupportTests.swift
git commit -m "feat: add sidebar selection model"
```

## Task 2: Route-Aware Sidebar Rendering

**Files:**
- Modify: `Sources/Layouts/MainLayout.swift`
- Modify: `Sources/Components/Sidebar/SidebarCategories.swift`
- Modify: `Sources/Components/Sidebar/SidebarTags.swift`
- Create: `Sources/Components/Sidebar/SidebarSectionTitle.swift`
- Create: `Sources/Components/Sidebar/SidebarNavItem.swift`
- Create: `Sources/Components/Sidebar/SidebarTagChip.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SidebarRenderingTests.swift`

- [ ] **Step 1: Write failing publishing tests for current markers**

Add these tests to `SidebarRenderingTests`:

```swift
@Test("category detail page marks the active sidebar category")
func categoryDetailPageMarksActiveSidebarCategory() async throws {
    let harness = try await publishedSite()
    let category = try harness.contents(of: "categories/updates/index.html")
    let sidebar = try sidebarSlice(of: category)

    #expect(sidebar.contains("data-sidebar-nav-item=\"category\""))
    #expect(sidebar.contains("data-sidebar-term-slug=\"updates\""))
    #expect(sidebar.contains("data-sidebar-current=\"true\""))
    #expect(sidebar.contains("aria-current=\"page\""))
    #expect(!sidebar.contains("data-sidebar-tag-chip=\"true\" aria-current=\"page\""))
}

@Test("tag detail page marks the active sidebar tag")
func tagDetailPageMarksActiveSidebarTag() async throws {
    let harness = try await publishedSite()
    let tag = try harness.contents(of: "tags/intro/index.html")
    let sidebar = try sidebarSlice(of: tag)

    #expect(sidebar.contains("data-sidebar-tag-chip=\"true\""))
    #expect(sidebar.contains("data-sidebar-term-slug=\"intro\""))
    #expect(sidebar.contains("data-sidebar-current=\"true\""))
    #expect(sidebar.contains("aria-current=\"page\""))
    #expect(!sidebar.contains("data-sidebar-nav-item=\"category\" aria-current=\"page\""))
}

@Test("non-taxonomy pages do not mark a sidebar current item")
func nonTaxonomyPagesDoNotMarkSidebarCurrentItem() async throws {
    let harness = try await publishedSite()
    let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
    let sidebar = try sidebarSlice(of: article)

    #expect(!sidebar.contains("data-sidebar-current=\"true\""))
    #expect(!sidebar.contains("aria-current=\"page\""))
}
```

Add this helper near the existing private helpers:

```swift
private func sidebarSlice(of html: String) throws -> Substring {
    let markerRange = try #require(html.range(of: "data-sidebar-container=\"true\""))
    let closeRange = try #require(html[markerRange.lowerBound...].range(of: "</aside>"))

    return html[markerRange.lowerBound..<closeRange.upperBound]
}
```

- [ ] **Step 2: Run the focused failing tests**

Run:

```bash
swift test --filter SidebarRenderingTests/categoryDetailPageMarksActiveSidebarCategory
```

Expected: FAIL because category rows do not emit active markers.

- [ ] **Step 3: Add shared section title component**

Create `Sources/Components/Sidebar/SidebarSectionTitle.swift`:

```swift
import Foundation
import Raptor

struct SidebarSectionTitle: HTML {
    let text: String

    var body: some HTML {
        Text(text)
            .style(SidebarSectionTitleStyle())
            .data("sidebar-section-title", text.convertedToSlug())
    }
}
```

- [ ] **Step 4: Add category nav item component**

Create `Sources/Components/Sidebar/SidebarNavItem.swift`:

```swift
import Foundation
import Raptor

struct SidebarNavItem: HTML {
    let item: TaxonomyCountItem
    let isActive: Bool

    var body: some HTML {
        if isActive {
            Link(destination: item.path) {
                Text(item.name)
                    .style(SidebarNavLabelStyle())
                    .data("sidebar-nav-label", "true")
                Text("\(item.count)")
                    .style(SidebarCountBadgeStyle(isActive: true))
                    .data("sidebar-count", "true")
            }
            .style(SidebarNavItemStyle(isActive: true))
            .data("sidebar-nav-item", item.term.kind.rawValue)
            .data("sidebar-term-slug", item.term.slug)
            .attribute("aria-current", "page")
            .data("sidebar-current", "true")
        } else {
            Link(destination: item.path) {
                Text(item.name)
                    .style(SidebarNavLabelStyle())
                    .data("sidebar-nav-label", "true")
                Text("\(item.count)")
                    .style(SidebarCountBadgeStyle(isActive: false))
                    .data("sidebar-count", "true")
            }
            .style(SidebarNavItemStyle(isActive: false))
            .data("sidebar-nav-item", item.term.kind.rawValue)
            .data("sidebar-term-slug", item.term.slug)
        }
    }
}
```

- [ ] **Step 5: Add tag chip component**

Create `Sources/Components/Sidebar/SidebarTagChip.swift`:

```swift
import Foundation
import Raptor

struct SidebarTagChip: HTML {
    let item: TaxonomyCountItem
    let isActive: Bool

    var body: some HTML {
        if isActive {
            Link(destination: item.path) {
                Text("# \(item.name)")
                    .style(SidebarTagLabelStyle())
                    .data("sidebar-tag-label", "true")
                Text("\(item.count)")
                    .style(SidebarCountBadgeStyle(isActive: true))
                    .data("sidebar-count", "true")
            }
            .style(SidebarTagChipStyle(isActive: true))
            .data("sidebar-tag-chip", "true")
            .data("sidebar-term-slug", item.term.slug)
            .attribute("aria-current", "page")
            .data("sidebar-current", "true")
        } else {
            Link(destination: item.path) {
                Text("# \(item.name)")
                    .style(SidebarTagLabelStyle())
                    .data("sidebar-tag-label", "true")
                Text("\(item.count)")
                    .style(SidebarCountBadgeStyle(isActive: false))
                    .data("sidebar-count", "true")
            }
            .style(SidebarTagChipStyle(isActive: false))
            .data("sidebar-tag-chip", "true")
            .data("sidebar-term-slug", item.term.slug)
        }
    }
}
```

- [ ] **Step 6: Pass page-derived selection from layout**

Modify the top of `MainLayout`:

```swift
struct MainLayout: Layout {
    @Environment(\.posts) private var posts
    @Environment(\.site) private var site
    @Environment(\.page) private var page
```

Add this computed property:

```swift
private var sidebarSelection: SidebarSelection {
    SidebarSelection(path: page.url.path)
}
```

Modify the sidebar component calls:

```swift
SidebarContainer {
    SidebarProfile(profile: sidebarProfile)
    SidebarCategories(items: sidebarCategories, selection: sidebarSelection)
    SidebarTags(items: sidebarTags, selection: sidebarSelection)
}
```

- [ ] **Step 7: Update category and tag sections**

Replace `SidebarCategories` with:

```swift
import Foundation
import Raptor

struct SidebarCategories: HTML {
    let items: [TaxonomyCountItem]
    let selection: SidebarSelection

    var body: some HTML {
        VStack(alignment: .leading, spacing: 10) {
            SidebarSectionTitle(text: "Categories")
            VStack(alignment: .leading, spacing: 6) {
                ForEach(items) { item in
                    SidebarNavItem(item: item, isActive: selection.isActive(item))
                }
            }
            .data("sidebar-nav-list", "categories")
        }
        .style(SidebarPanelStyle())
        .data("sidebar-categories", "true")
    }
}
```

Replace `SidebarTags` with:

```swift
import Foundation
import Raptor

struct SidebarTags: HTML {
    let items: [TaxonomyCountItem]
    let selection: SidebarSelection

    var body: some HTML {
        VStack(alignment: .leading, spacing: 10) {
            SidebarSectionTitle(text: "Tags")
            HStack(spacing: 8) {
                ForEach(items) { item in
                    SidebarTagChip(item: item, isActive: selection.isActive(item))
                }
            }
            .style(SidebarTagCloudStyle())
            .data("sidebar-tag-cloud", "true")
        }
        .style(SidebarPanelStyle())
        .data("sidebar-tags", "true")
    }
}
```

- [ ] **Step 8: Run focused publishing tests**

Run:

```bash
swift test --filter SidebarRenderingTests
```

Expected: PASS for sidebar rendering tests.

- [ ] **Step 9: Commit**

```bash
git add Sources/Layouts/MainLayout.swift Sources/Components/Sidebar Tests/RaptorTsubameTests/Publishing/SidebarRenderingTests.swift
git commit -m "feat: render route-aware sidebar navigation"
```

## Task 3: Sidebar Navigation Styling

**Files:**
- Create: `Sources/Styles/Shell/SidebarNavigationStyle.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Write failing CSS assertions**

Add a focused test to `SitePublishingTests`:

```swift
@Test("generated CSS includes sidebar navigation treatments")
func generatedCSSIncludesSidebarNavigationTreatments() async throws {
    let harness = try await publishedSite()
    let css = try harness.contents(of: "css/styles.css")

    #expect(css.contains(".sidebar-section-title-style"))
    #expect(css.contains(".sidebar-nav-item-style"))
    #expect(css.contains(".sidebar-nav-label-style"))
    #expect(css.contains(".sidebar-count-badge-style"))
    #expect(css.contains(".sidebar-tag-chip-style"))
    #expect(css.contains(".sidebar-tag-cloud-style"))
    #expect(css.contains("background-color: rgb(255 255 255 / 100%)"))
    #expect(css.contains("color: rgb(74 139 203 / 100%)"))
}
```

- [ ] **Step 2: Run the focused failing test**

Run:

```bash
swift test --filter SitePublishingTests/generatedCSSIncludesSidebarNavigationTreatments
```

Expected: FAIL because the new style classes do not exist.

- [ ] **Step 3: Implement sidebar navigation styles**

Create `Sources/Styles/Shell/SidebarNavigationStyle.swift`:

```swift
import Foundation
import Raptor

struct SidebarSectionTitleStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .font(.system(.body, weight: .semibold))
            .foregroundStyle(palette.mutedText)
            .style(.letterSpacing(.px(0.4)))
            .style(.textTransform(.uppercase))
    }
}

struct SidebarNavItemStyle: Style {
    let isActive: Bool

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.flex))
            .style(.alignItems(.center))
            .style(.justifyContent(.spaceBetween))
            .style(.gap(.px(10)))
            .style(.width(.percent(100)))
            .style(.padding(.px(10), .px(12)))
            .style(.borderRadius(.px(12)))
            .style(.textDecoration(.none))
            .background(isActive ? palette.surfaceRaised : palette.surface)
            .foregroundStyle(isActive ? palette.accent : palette.text)
            .border(isActive ? palette.accent : palette.border, width: 1, style: .solid)
    }
}

struct SidebarNavLabelStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.minWidth(.px(0)))
            .style(.overflow(.hidden))
            .style(.textOverflow(.ellipsis))
            .style(.whiteSpace(.nowrap))
    }
}

struct SidebarCountBadgeStyle: Style {
    let isActive: Bool

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.minWidth(.px(24)))
            .style(.padding(.px(2), .px(7)))
            .style(.borderRadius(.px(999)))
            .style(.textAlign(.center))
            .font(.system(.caption, weight: .semibold))
            .background(isActive ? palette.accent : palette.canvasBackground)
            .foregroundStyle(isActive ? palette.surfaceRaised : palette.mutedText)
    }
}

struct SidebarTagCloudStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.display(.flex))
            .style(.flexWrap(.wrap))
            .style(.gap(.px(8)))
    }
}

struct SidebarTagChipStyle: Style {
    let isActive: Bool

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.gap(.px(6)))
            .style(.padding(.px(7), .px(10)))
            .style(.borderRadius(.px(999)))
            .style(.textDecoration(.none))
            .background(isActive ? palette.surfaceRaised : palette.surface)
            .foregroundStyle(isActive ? palette.accent : palette.text)
            .border(isActive ? palette.accent : palette.border, width: 1, style: .solid)
    }
}

struct SidebarTagLabelStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content.font(.system(.caption, weight: .semibold))
    }
}
```

Use only the existing tokens in `Sources/Theme/SiteThemePalette.swift` for this stage. Do not add new theme tokens unless implementation proves the current palette cannot express active, muted, surface, and accent states.

- [ ] **Step 4: Run focused CSS test**

Run:

```bash
swift test --filter SitePublishingTests/generatedCSSIncludesSidebarNavigationTreatments
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Styles/Shell/SidebarNavigationStyle.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "style: refine sidebar navigation"
```

## Task 4: Full Verification And Output Inspection

**Files:**
- Modify only if verification exposes a real defect in files touched by Tasks 1-3.

- [ ] **Step 1: Run full tests**

Run:

```bash
swift test
```

Expected: PASS.

- [ ] **Step 2: Build the static site**

Run:

```bash
swift run RaptorTsubame
```

Expected: PASS. The existing Prism warning about `Resources/js/prism/prism-html` is acceptable if unchanged.

- [ ] **Step 3: Inspect generated sidebar output**

Run:

```bash
rg -n "data-sidebar-current|aria-current|data-sidebar-nav-item|data-sidebar-tag-chip" Build/categories/updates/index.html Build/tags/intro/index.html Build/posts/welcome-to-tsubame/index.html
```

Expected:
- `Build/categories/updates/index.html` contains one active category marker.
- `Build/tags/intro/index.html` contains one active tag marker.
- `Build/posts/welcome-to-tsubame/index.html` contains nav item and tag chip markers but no `data-sidebar-current`.

- [ ] **Step 4: Inspect generated CSS**

Run:

```bash
rg -n "sidebar-(section-title|nav-item|tag-chip|tag-cloud|count-badge)" Build/css/styles.css
```

Expected: CSS contains rules for section title, nav row, count badge, tag cloud, and tag chip styles.

- [ ] **Step 5: Check git status**

Run:

```bash
git status --short
```

Expected:
- Only intentional Stage 8 changes are present.
- Do not stage or modify `Posts/posts/build-website-in-swift.md` unless the user explicitly asks.
- Preserve any pre-existing background-fix changes in `Sources/Styles/Visual/PageCanvasStyle.swift` and `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`; do not revert them.

- [ ] **Step 6: Final commit if verification required fixes**

If Task 4 required fixes, commit them:

```bash
git add <fixed-files>
git commit -m "fix: stabilize sidebar completion"
```

If no fixes were needed, do not create an empty commit.

## Self-Review Checklist

- [ ] Sidebar remains a left site sidebar; no right TOC or three-column shell is introduced.
- [ ] Article TOC markers and rendering are unchanged.
- [ ] Active state is derived from public `@Environment(\.page)`, not private Raptor internals.
- [ ] Category and tag active states use taxonomy slugs, not display names.
- [ ] Generated HTML has stable markers for tests and future visual QA.
- [ ] Generated CSS uses existing theme palette tokens and remains light/dark aware.
- [ ] Mobile behavior still follows existing `ShellSidebarStyle` order and width rules.
