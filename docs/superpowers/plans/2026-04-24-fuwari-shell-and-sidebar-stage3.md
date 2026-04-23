# Fuwari Shell And Sidebar Stage 3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a stable Fuwari-inspired two-column site shell with a persistent left sidebar containing `Profile`, `Categories`, and `Tags` across the site's primary pages.

**Architecture:** Extend the existing `MainLayout` into a real site shell rather than teaching individual pages to assemble sidebar UI. Keep `Profile` as site-level configuration data, keep taxonomy sidebar blocks driven by `PostQueries`, and preserve Stage 1/2 page ownership of the main content region only.

**Tech Stack:** Swift 6.2, Raptor 0.1.2, Swift Testing (`Testing`), existing `PostQueries` taxonomy helpers, Markdown-backed posts/pages

---

## File Structure

### Existing files to modify

- `Sources/Layouts/MainLayout.swift`
  Upgrade the shell from top-nav + main + footer into a real responsive two-column layout with sidebar and content regions.
- `Sources/Site.swift`
  Add lightweight site-level profile configuration exposed to layout/sidebar components.
- `Sources/Content/PostQueries.swift`
  Add sidebar-oriented taxonomy query helpers if the existing Stage 2 group tuples are not ergonomic enough for component rendering.
- `Tests/RaptorTsubameTests/SitePublishingTests.swift`
  Add integration assertions for the shared shell and sidebar presence across page types.
- `Tests/RaptorTsubameTests/TaxonomyPublishingTests.swift`
  Tighten taxonomy-page assertions to confirm sidebar shell presence and no Stage 2 regressions.

### New source files

- `Sources/Components/SidebarContainer.swift`
  Structural wrapper for the sidebar column.
- `Sources/Components/SidebarProfile.swift`
  Renders site identity block from explicit site-level profile data.
- `Sources/Components/SidebarCategories.swift`
  Renders linked category list with counts using Stage 2 taxonomy query results.
- `Sources/Components/SidebarTags.swift`
  Renders linked tag list with counts using Stage 2 taxonomy query results.
- `Sources/Content/SiteProfile.swift`
  Small value type for site-level sidebar profile content.

### New tests

- `Tests/RaptorTsubameTests/SidebarRenderingTests.swift`
  Focused shell/sidebar integration tests covering homepage, article, archive, taxonomy, and about output.
- `Tests/RaptorTsubameTests/SidebarSupportTests.swift`
  Focused tests for sidebar-oriented data helpers and site profile defaults if needed.

---

### Task 1: Add Failing Shell And Sidebar Rendering Tests

**Files:**
- Create: `Tests/RaptorTsubameTests/SidebarRenderingTests.swift`
- Modify: `Tests/RaptorTsubameTests/SitePublishingTests.swift`

- [ ] **Step 1: Write the failing shell/sidebar integration tests**

```swift
import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Sidebar rendering", .serialized)
struct SidebarRenderingTests {
    @Test("homepage renders persistent sidebar blocks")
    func homepageRendersSidebarBlocks() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let homepage = try harness.contents(of: "index.html")
        try expectSidebarShell(in: homepage)
        #expect(homepage.contains("Raptor Tsubame"))
        #expect(homepage.contains("Categories"))
        #expect(homepage.contains("Tags"))
    }

    @Test("article page renders shared shell and sidebar taxonomy blocks")
    func articlePageRendersSharedShellAndSidebar() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        try expectSidebarShell(in: article)
        #expect(article.contains("Categories"))
        #expect(article.contains("Updates"))
        #expect(article.contains("Tags"))
        #expect(article.contains("Intro"))
    }

    @Test("about page also renders inside the shared shell")
    func aboutPageRendersSharedShell() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let about = try harness.contents(of: "about/index.html")
        try expectSidebarShell(in: about)
        #expect(about.contains("About This Site"))
    }
}

private func expectSidebarShell(in html: String) throws {
    #expect(html.contains("data-sidebar-shell"))
    #expect(html.contains("data-sidebar-profile"))
    #expect(html.contains("data-sidebar-categories"))
    #expect(html.contains("data-sidebar-tags"))
}
```

- [ ] **Step 2: Add one Stage 1 regression assertion that the sidebar shell reaches archive pages**

```swift
    @Test("archive renders shared shell and sidebar")
    func archiveRendersSharedShellAndSidebar() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let archive = try harness.contents(of: "archive/index.html")
        try expectSidebarShell(in: archive)
        #expect(archive.contains("Fuwari Study Notes"))
    }
```

- [ ] **Step 3: Run the focused sidebar suite to verify the red state**

Run: `swift test --filter SidebarRenderingTests`

Expected: FAIL because the current layout does not render any sidebar shell markers or sidebar blocks.

- [ ] **Step 4: Commit**

```bash
git add Tests/RaptorTsubameTests/SidebarRenderingTests.swift Tests/RaptorTsubameTests/SitePublishingTests.swift
git commit -m "test: add Stage 3 sidebar rendering assertions"
```

---

### Task 2: Add Site Profile Model And Sidebar Components

**Files:**
- Create: `Sources/Content/SiteProfile.swift`
- Create: `Sources/Components/SidebarContainer.swift`
- Create: `Sources/Components/SidebarProfile.swift`
- Create: `Sources/Components/SidebarCategories.swift`
- Create: `Sources/Components/SidebarTags.swift`
- Create: `Tests/RaptorTsubameTests/SidebarSupportTests.swift`
- Modify: `Sources/Site.swift`
- Modify: `Sources/Content/PostQueries.swift`

- [ ] **Step 1: Write focused support tests for profile and sidebar taxonomy items**

```swift
import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Sidebar support", .serialized)
struct SidebarSupportTests {
    @Test("site profile provides stable default sidebar content")
    func siteProfileDefaults() {
        let profile = SiteProfile.default

        #expect(profile.name == "Raptor Tsubame")
        #expect(!profile.description.isEmpty)
        #expect(profile.avatarText == "TS")
    }

    @Test("sidebar taxonomy items preserve name count and path")
    func sidebarTaxonomyItems() {
        let term = TaxonomyTerm(kind: .category, name: "Notes")
        let item = SidebarTaxonomyItem(term: term, count: 2)

        #expect(item.name == "Notes")
        #expect(item.count == 2)
        #expect(item.path == "/categories/notes/")
    }
}
```

- [ ] **Step 2: Run support tests to verify the red state**

Run: `swift test --filter SidebarSupportTests`

Expected: FAIL because `SiteProfile` and `SidebarTaxonomyItem` do not exist yet.

- [ ] **Step 3: Add the site profile model**

```swift
// Sources/Content/SiteProfile.swift
import Foundation

struct SiteProfile: Sendable, Equatable {
    let name: String
    let description: String
    let avatarText: String

    static let `default` = SiteProfile(
        name: "Raptor Tsubame",
        description: "A Raptor site studying Fuwari through content architecture and gradual shell refinement.",
        avatarText: "TS"
    )
}
```

- [ ] **Step 4: Add a sidebar taxonomy item type and query helper**

```swift
// Append inside Sources/Content/PostQueries.swift
struct SidebarTaxonomyItem: Identifiable, Sendable, Equatable {
    let term: TaxonomyTerm
    let count: Int

    var id: String { term.id }
    var name: String { term.name }
    var path: String { term.path }
}

extension PostQueries {
    static func sidebarCategories<S: Sequence>(_ posts: S) -> [SidebarTaxonomyItem] where S.Element == Post {
        categoryGroups(posts).map { group in
            SidebarTaxonomyItem(term: group.term, count: group.posts.count)
        }
    }

    static func sidebarTags<S: Sequence>(_ posts: S) -> [SidebarTaxonomyItem] where S.Element == Post {
        tagGroups(posts).map { group in
            SidebarTaxonomyItem(term: group.term, count: group.posts.count)
        }
    }
}
```

- [ ] **Step 5: Add the sidebar components**

```swift
// Sources/Components/SidebarContainer.swift
import Foundation
import Raptor

struct SidebarContainer<Content: HTML>: HTML {
    @HTMLBuilder let content: () -> Content

    var body: some HTML {
        Aside {
            VStack(alignment: .leading, spacing: 20) {
                content()
            }
        }
        .attributes(["data-sidebar-shell": "true"])
    }
}
```

```swift
// Sources/Components/SidebarProfile.swift
import Foundation
import Raptor

struct SidebarProfile: HTML {
    let profile: SiteProfile

    var body: some HTML {
        VStack(alignment: .leading, spacing: 10) {
            Text(profile.avatarText)
                .font(.title2)
            Text(profile.name)
                .font(.title3)
            Text(profile.description)
        }
        .attributes(["data-sidebar-profile": "true"])
    }
}
```

```swift
// Sources/Components/SidebarCategories.swift
import Foundation
import Raptor

struct SidebarCategories: HTML {
    let items: [SidebarTaxonomyItem]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categories").font(.title5)
            ForEach(items) { item in
                Link("\(item.name) (\(item.count))", destination: item.path)
            }
        }
        .attributes(["data-sidebar-categories": "true"])
    }
}
```

```swift
// Sources/Components/SidebarTags.swift
import Foundation
import Raptor

struct SidebarTags: HTML {
    let items: [SidebarTaxonomyItem]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags").font(.title5)
            ForEach(items) { item in
                Link("\(item.name) (\(item.count))", destination: item.path)
            }
        }
        .attributes(["data-sidebar-tags": "true"])
    }
}
```

- [ ] **Step 6: Expose profile configuration from the site**

```swift
// Add inside Sources/Site.swift ExampleSite
    var profile = SiteProfile.default
```

- [ ] **Step 7: Run support tests to verify they pass**

Run: `swift test --filter SidebarSupportTests`

Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add Sources/Content/SiteProfile.swift Sources/Components/SidebarContainer.swift Sources/Components/SidebarProfile.swift Sources/Components/SidebarCategories.swift Sources/Components/SidebarTags.swift Sources/Content/PostQueries.swift Sources/Site.swift Tests/RaptorTsubameTests/SidebarSupportTests.swift
git commit -m "feat: add sidebar profile and taxonomy components"
```

---

### Task 3: Upgrade MainLayout Into A Shared Two-Column Shell

**Files:**
- Modify: `Sources/Layouts/MainLayout.swift`
- Modify: `Tests/RaptorTsubameTests/SidebarRenderingTests.swift`

- [ ] **Step 1: Run the focused sidebar suite to verify the current red state**

Run: `swift test --filter SidebarRenderingTests`

Expected: FAIL because the layout still lacks sidebar shell markup and sidebar blocks.

- [ ] **Step 2: Replace the existing layout body with the shared shell**

```swift
import Foundation
import Raptor

struct MainLayout: Layout {
    @Environment(\.posts) private var posts
    @Environment(\.site) private var site

    private var exampleSite: ExampleSite? {
        site as? ExampleSite
    }

    private var profile: SiteProfile {
        exampleSite?.profile ?? .default
    }

    private var categoryItems: [SidebarTaxonomyItem] {
        PostQueries.sidebarCategories(posts)
    }

    private var tagItems: [SidebarTaxonomyItem] {
        PostQueries.sidebarTags(posts)
    }

    var body: some Document {
        Navigation { TopNavigation().body }
        Div {
            SidebarContainer {
                SidebarProfile(profile: profile)
                SidebarCategories(items: categoryItems)
                SidebarTags(items: tagItems)
            }
            Main {
                content
            }
        }
        .attributes(["data-sidebar-shell": "true"])
        Footer { PageFooter() }
    }
}
```

- [ ] **Step 3: Add one stronger assertion that taxonomy pages also inherit the shell**

```swift
    @Test("taxonomy detail pages render the shared shell")
    func taxonomyDetailPagesRenderSharedShell() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let tagPage = try harness.contents(of: "tags/raptor/index.html")
        let categoryPage = try harness.contents(of: "categories/notes/index.html")

        try expectSidebarShell(in: tagPage)
        try expectSidebarShell(in: categoryPage)
    }
```

- [ ] **Step 4: Run the sidebar suite to verify it passes**

Run: `swift test --filter SidebarRenderingTests`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/Layouts/MainLayout.swift Tests/RaptorTsubameTests/SidebarRenderingTests.swift
git commit -m "feat: upgrade layout to shared sidebar shell"
```

---

### Task 4: Add Responsive Shell Structure And Regression Coverage

**Files:**
- Modify: `Sources/Layouts/MainLayout.swift`
- Modify: `Tests/RaptorTsubameTests/SitePublishingTests.swift`
- Modify: `Tests/RaptorTsubameTests/TaxonomyPublishingTests.swift`

- [ ] **Step 1: Add layout markers for desktop/mobile-safe shell structure**

```swift
// Update the shell wrapper in Sources/Layouts/MainLayout.swift
        Div {
            SidebarContainer {
                SidebarProfile(profile: profile)
                SidebarCategories(items: categoryItems)
                SidebarTags(items: tagItems)
            }
            Main {
                content
            }
        }
        .class("site-shell")
        .attributes([
            "data-sidebar-shell": "true",
            "data-shell-layout": "two-column"
        ])
```

- [ ] **Step 2: Add regression assertions to shared publishing tests**

```swift
    @Test("primary routes retain Stage 1 and Stage 2 content inside the shared shell")
    func primaryRoutesRetainContentInsideSharedShell() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let homepage = try harness.contents(of: "index.html")
        let about = try harness.contents(of: "about/index.html")
        let tags = try harness.contents(of: "tags/index.html")
        let categories = try harness.contents(of: "categories/index.html")

        #expect(homepage.contains("Fuwari Study Notes"))
        #expect(about.contains("About This Site"))
        #expect(tags.contains("Raptor (2)"))
        #expect(categories.contains("Notes (2)"))

        try expectSidebarShell(in: homepage)
        try expectSidebarShell(in: about)
        try expectSidebarShell(in: tags)
        try expectSidebarShell(in: categories)
    }
```

- [ ] **Step 3: Run the two existing publishing suites**

Run: `swift test --filter SitePublishingTests`

Expected: PASS

Run: `swift test --filter TaxonomyPublishingTests`

Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add Sources/Layouts/MainLayout.swift Tests/RaptorTsubameTests/SitePublishingTests.swift Tests/RaptorTsubameTests/TaxonomyPublishingTests.swift
git commit -m "test: lock shared sidebar shell across site routes"
```

---

### Task 5: Final Verification And Cleanup

**Files:**
- Modify: `Sources/Layouts/MainLayout.swift` as needed from test feedback
- Modify: `Sources/Components/*` as needed from test feedback
- Modify: `Tests/RaptorTsubameTests/*` as needed from test feedback

- [ ] **Step 1: Publish the site manually**

Run: `swift run RaptorTsubame`

Expected output:

```text
📗 Publish completed!
```

- [ ] **Step 2: Inspect key outputs**

Run: `find Build -maxdepth 4 -type f | sort`

Expected paths include:

```text
Build/index.html
Build/about/index.html
Build/archive/index.html
Build/tags/index.html
Build/categories/index.html
Build/posts/welcome-to-tsubame/index.html
```

- [ ] **Step 3: Verify sidebar shell markers exist in published output**

Run:

```bash
rg -n "data-sidebar-shell|data-sidebar-profile|data-sidebar-categories|data-sidebar-tags" Build/index.html Build/about/index.html Build/posts/welcome-to-tsubame/index.html Build/tags/index.html Build/categories/index.html
```

Expected: matches in all listed files.

- [ ] **Step 4: Run the full suite**

Run: `swift test`

Expected: PASS

- [ ] **Step 5: Commit any final cleanup**

```bash
git add Sources Tests
git commit -m "feat: implement Stage 3 shell and sidebar architecture"
```
