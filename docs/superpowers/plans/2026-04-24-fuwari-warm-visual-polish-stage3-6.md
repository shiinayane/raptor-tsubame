# Fuwari Warm Visual Polish Stage 3.6 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the existing Raptor Tsubame shell a warm paper editorial visual identity without adding new features or changing routes.

**Architecture:** Add focused visual styles under `Sources/Styles/Visual/`, apply them from existing layout and post components, and tune sidebar panel colors to match. Keep shell layout styles separate from visual theme styles, preserve Stage 3.5 DOM/marker behavior, and verify through published HTML/CSS.

**Tech Stack:** Swift 6.2, Raptor 0.1.2 `Style`, Swift Testing, published HTML/CSS verification

---

## File Structure

### New files

- `Sources/Styles/Visual/PageCanvasStyle.swift`
  Owns warm page-level background and shell breathing room.
- `Sources/Styles/Visual/ContentSurfaceStyle.swift`
  Owns reusable warm card surface: cream background, warm border, soft shadow, full width.
- `Sources/Styles/Visual/PostCardStyle.swift`
  Owns post-list card padding and text rhythm.
- `Sources/Styles/Visual/MetadataTextStyle.swift`
  Owns quieter metadata color and line-height.

### Existing files to modify

- `Sources/Layouts/MainLayout.swift`
  Apply `PageCanvasStyle` to the main page region without changing shell marker ownership or DOM order.
- `Sources/Components/Posts/PostListItem.swift`
  Apply content surface and post card styles to each post list item.
- `Sources/Components/Posts/PostMeta.swift`
  Apply quieter metadata style.
- `Sources/Styles/Shell/SidebarPanelStyle.swift`
  Tune sidebar panel palette to the warm paper editorial direction while preserving full-width panel behavior.
- `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`
  Add published HTML/CSS assertions for Stage 3.6 visual styles.

---

### Task 1: Lock Warm Visual Publishing Contract With Failing Tests

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add a Stage 3.6 published HTML test**

Add this test inside `SitePublishingTests`, immediately after `generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint()`:

```swift
@Test("published pages include warm visual style classes")
func publishedPagesIncludeWarmVisualStyleClasses() async throws {
    let harness = try TestPublishHarness()
    defer { harness.cleanup() }

    try await harness.publish()

    let homepage = try harness.contents(of: "index.html")
    let archive = try harness.contents(of: "archive/index.html")
    let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")

    try expectWarmVisualHTML(in: homepage)
    try expectWarmVisualHTML(in: archive)
    #expect(article.contains("page-canvas-style"))
    #expect(article.contains("sidebar-panel-style"))
}
```

- [ ] **Step 2: Add the warm visual HTML helper**

Add this helper near the existing publishing helper functions in the same file:

```swift
private func expectWarmVisualHTML(in html: String) throws {
    let main = try mainSlice(of: html)

    #expect(main.contains("page-canvas-style"))
    #expect(main.contains("post-card-style"))
    #expect(main.contains("content-surface-style"))
    #expect(main.contains("metadata-text-style"))
    #expect(main.contains("sidebar-panel-style"))
    #expect(main.contains("data-post-card=\"true\""))
    #expect(main.contains("data-post-meta=\"true\""))
}
```

- [ ] **Step 3: Extend generated CSS regression coverage**

In the existing `generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint()` test, after:

```swift
try expectResponsiveShellCSS(in: css)
```

add:

```swift
try expectWarmVisualCSS(in: css)
```

Add this helper near `expectResponsiveShellCSS(in:)`:

```swift
private func expectWarmVisualCSS(in css: String) throws {
    #expect(css.contains(".page-canvas-style"))
    #expect(css.contains(".post-card-style"))
    #expect(css.contains(".content-surface-style"))
    #expect(css.contains(".metadata-text-style"))
    #expect(css.contains(".sidebar-panel-style"))

    #expect(css.contains("rgb(252 246 236 / 100%)"))
    #expect(css.contains("rgb(255 251 244 / 100%)"))
    #expect(css.contains("rgb(232 213 190 / 100%)"))
    #expect(css.contains("rgb(126 83 47 / 100%)"))
    #expect(css.contains("box-shadow:"))

    #expect(!css.contains("@media (min-width: 0px) {\n    .page-canvas-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .post-card-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .content-surface-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .metadata-text-style"))

    let sidebarPanelRule = try cssRule(in: css, containing: ".sidebar-panel-style")
    #expect(sidebarPanelRule.contains("rgb(255 251 244 / 100%)"))
    #expect(sidebarPanelRule.contains("rgb(232 213 190 / 100%)"))
    #expect(sidebarPanelRule.contains("rgb(73 48 31 / 100%)"))
}
```

Add this helper near the existing CSS helper functions:

```swift
private func cssRule(in css: String, containing selectorNeedle: String) throws -> String {
    let selectorRange = try #require(css.range(of: selectorNeedle))
    let ruleOpen = try #require(css[selectorRange.lowerBound...].firstIndex(of: "{"))
    var depth = 0
    var index = ruleOpen

    while index < css.endIndex {
        if css[index] == "{" {
            depth += 1
        } else if css[index] == "}" {
            depth -= 1
            if depth == 0 {
                return String(css[selectorRange.lowerBound...index])
            }
        }

        index = css.index(after: index)
    }

    let missingRule: String? = nil
    return try #require(missingRule)
}
```

- [ ] **Step 4: Run the targeted publishing suite to verify the red state**

Run:

```bash
swift test --filter SitePublishingTests
```

Expected: FAIL. The new assertions should fail because `page-canvas-style`, `post-card-style`, `content-surface-style`, `metadata-text-style`, and `data-post-card` / `data-post-meta` are not emitted yet.

- [ ] **Step 5: Commit**

```bash
git add Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "test: lock warm visual publishing contract"
```

---

### Task 2: Add Warm Visual Style Types

**Files:**
- Create: `Sources/Styles/Visual/PageCanvasStyle.swift`
- Create: `Sources/Styles/Visual/ContentSurfaceStyle.swift`
- Create: `Sources/Styles/Visual/PostCardStyle.swift`
- Create: `Sources/Styles/Visual/MetadataTextStyle.swift`

- [ ] **Step 1: Create `PageCanvasStyle`**

Create `Sources/Styles/Visual/PageCanvasStyle.swift`:

```swift
import Foundation
import Raptor

struct PageCanvasStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.backgroundColor(.rgb(252, 246, 236)))
                .style(.paddingBlock(.px(24)))
                .style(.paddingInline(.px(16)))
                .style(.minWidth(.px(0)))
        } else {
            content
                .style(.backgroundColor(.rgb(252, 246, 236)))
                .style(.paddingBlock(.px(40)))
                .style(.paddingInline(.px(24)))
                .style(.minWidth(.px(0)))
        }
    }
}
```

- [ ] **Step 2: Create `ContentSurfaceStyle`**

Create `Sources/Styles/Visual/ContentSurfaceStyle.swift`:

```swift
import Foundation
import Raptor

struct ContentSurfaceStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.backgroundColor(.rgb(255, 251, 244)))
                .style(.borderRadius(.px(16)))
                .border(Color(red: 232, green: 213, blue: 190), width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.backgroundColor(.rgb(255, 251, 244)))
                .style(.borderRadius(.px(18)))
                .border(Color(red: 232, green: 213, blue: 190), width: 1, style: .solid)
                .shadow(Color(red: 82, green: 49, blue: 28, opacity: 8%), radius: 22, x: 0, y: 12)
        }
    }
}
```

- [ ] **Step 3: Create `PostCardStyle`**

Create `Sources/Styles/Visual/PostCardStyle.swift`:

```swift
import Foundation
import Raptor

struct PostCardStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.padding(.px(18)))
                .style(.lineHeight(1.55))
                .foregroundStyle(Color(red: 56, green: 38, blue: 25))
        } else {
            content
                .style(.padding(.px(22)))
                .style(.lineHeight(1.58))
                .foregroundStyle(Color(red: 56, green: 38, blue: 25))
        }
    }
}
```

- [ ] **Step 4: Create `MetadataTextStyle`**

Create `Sources/Styles/Visual/MetadataTextStyle.swift`:

```swift
import Foundation
import Raptor

struct MetadataTextStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.lineHeight(1.5))
            .foregroundStyle(Color(red: 126, green: 83, blue: 47))
    }
}
```

- [ ] **Step 5: Build to verify public API compatibility**

Run:

```bash
swift build
```

Expected: PASS. If a style API differs in this checkout, update only these four style files to preserve the same CSS intent using public Raptor APIs.

- [ ] **Step 6: Commit**

```bash
git add Sources/Styles/Visual/PageCanvasStyle.swift Sources/Styles/Visual/ContentSurfaceStyle.swift Sources/Styles/Visual/PostCardStyle.swift Sources/Styles/Visual/MetadataTextStyle.swift
git commit -m "feat: add warm visual styles"
```

---

### Task 3: Apply Warm Visual Styles To Layout And Post Components

**Files:**
- Modify: `Sources/Layouts/MainLayout.swift`
- Modify: `Sources/Components/Posts/PostListItem.swift`
- Modify: `Sources/Components/Posts/PostMeta.swift`

- [ ] **Step 1: Apply page canvas style in `MainLayout`**

Update the `Main` modifier chain in `Sources/Layouts/MainLayout.swift` so the existing `Main { ... }` block receives `PageCanvasStyle()`:

```swift
Main {
    Tag("div") {
        Tag("div") {
            content
        }
        .style(ShellMainStyle())

        Tag("div") {
            SidebarContainer {
                SidebarProfile(profile: sidebarProfile)
                SidebarCategories(items: sidebarCategories)
                SidebarTags(items: sidebarTags)
            }
        }
        .style(ShellSidebarStyle())
        .data("sidebar-position", "leading")
    }
    .class("site-shell")
    .style(SiteShellStyle())
    .data("shell-layout", "two-column")
    .data("sidebar-shell", "true")
}
.style(PageCanvasStyle())
```

Do not change the order of `content` and sidebar. Do not change existing `data-*` markers.

- [ ] **Step 2: Apply card styles to `PostListItem`**

Update `Sources/Components/Posts/PostListItem.swift`:

```swift
import Foundation
import Raptor

struct PostListItem: HTML {
    let post: Post

    var body: some HTML {
        VStack(alignment: .leading, spacing: 10) {
            Link(post)
            PostMeta(post: post)
        }
        .style(ContentSurfaceStyle())
        .style(PostCardStyle())
        .data("post-card", "true")
    }
}
```

- [ ] **Step 3: Apply metadata style to `PostMeta`**

Update `Sources/Components/Posts/PostMeta.swift`:

```swift
import Foundation
import Raptor

struct PostMeta: HTML {
    let post: Post

    var body: some HTML {
        VStack(alignment: .leading, spacing: 4) {
            Time(post.date.formatted(date: .abbreviated, time: .omitted), dateTime: post.date)
            if !post.description.isEmpty {
                Text { post.description }
            }
        }
        .style(MetadataTextStyle())
        .data("post-meta", "true")
    }
}
```

- [ ] **Step 4: Run the targeted publishing suite**

Run:

```bash
swift test --filter SitePublishingTests
```

Expected: FAIL. The HTML assertions for `page-canvas-style`, `post-card-style`, `content-surface-style`, `metadata-text-style`, `data-post-card`, and `data-post-meta` should pass, but the `sidebar-panel-style` CSS rule should still fail the warm palette assertions until Task 4 updates `SidebarPanelStyle`.

- [ ] **Step 5: Build**

Run:

```bash
swift build
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add Sources/Layouts/MainLayout.swift Sources/Components/Posts/PostListItem.swift Sources/Components/Posts/PostMeta.swift
git commit -m "feat: apply warm visual styles to content"
```

---

### Task 4: Align Sidebar Panels With Warm Editorial Palette

**Files:**
- Modify: `Sources/Styles/Shell/SidebarPanelStyle.swift`

- [ ] **Step 1: Update sidebar panel colors**

Replace `Sources/Styles/Shell/SidebarPanelStyle.swift` with:

```swift
import Foundation
import Raptor

struct SidebarPanelStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.padding(.px(16)))
                .style(.borderRadius(.px(12)))
                .style(.backgroundColor(.rgb(255, 251, 244)))
                .foregroundStyle(Color(red: 73, green: 48, blue: 31))
                .border(Color(red: 232, green: 213, blue: 190), width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.padding(.px(18)))
                .style(.borderRadius(.px(14)))
                .style(.backgroundColor(.rgb(255, 251, 244)))
                .foregroundStyle(Color(red: 73, green: 48, blue: 31))
                .border(Color(red: 232, green: 213, blue: 190), width: 1, style: .solid)
                .shadow(Color(red: 82, green: 49, blue: 28, opacity: 7%), radius: 18, x: 0, y: 10)
        }
    }
}
```

- [ ] **Step 2: Run focused publishing tests**

Run:

```bash
swift test --filter SitePublishingTests
swift test --filter SidebarRenderingTests
swift test --filter TaxonomyPublishingTests
```

Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add Sources/Styles/Shell/SidebarPanelStyle.swift
git commit -m "refactor: align sidebar panels with warm palette"
```

---

### Task 5: Final Publish Verification And Visual Output Checks

**Files:**
- Verify:
  - `Build/index.html`
  - `Build/archive/index.html`
  - `Build/about/index.html`
  - `Build/posts/welcome-to-tsubame/index.html`
  - `Build/css/raptor-core.css`
- Modify only if verification reveals a mismatch in:
  - `Sources/Styles/Visual/*.swift`
  - `Sources/Styles/Shell/SidebarPanelStyle.swift`
  - `Sources/Layouts/MainLayout.swift`
  - `Sources/Components/Posts/*.swift`
  - `Tests/RaptorTsubameTests/Publishing/*.swift`

- [ ] **Step 1: Run full test suite**

Run:

```bash
swift test
```

Expected: PASS with 30 or more tests in 7 suites. The exact count may increase if future accepted test additions occur during this stage.

- [ ] **Step 2: Publish the site**

Run:

```bash
swift run RaptorTsubame
```

Expected output includes:

```text
📗 Publish completed!
```

- [ ] **Step 3: Inspect generated visual markers**

Run:

```bash
rg -n "page-canvas-style|post-card-style|content-surface-style|metadata-text-style|sidebar-panel-style|data-post-card|data-post-meta" Build/index.html Build/archive/index.html Build/posts/welcome-to-tsubame/index.html
```

Expected:

- `Build/index.html` contains `page-canvas-style`, `post-card-style`, `content-surface-style`, `metadata-text-style`, `sidebar-panel-style`, `data-post-card`, and `data-post-meta`.
- `Build/archive/index.html` contains `page-canvas-style`, `post-card-style`, `content-surface-style`, `metadata-text-style`, `sidebar-panel-style`, `data-post-card`, and `data-post-meta`.
- `Build/posts/welcome-to-tsubame/index.html` contains `page-canvas-style` and `sidebar-panel-style`.

- [ ] **Step 4: Inspect generated CSS**

Run:

```bash
rg -n "page-canvas-style|post-card-style|content-surface-style|metadata-text-style|sidebar-panel-style|rgb\\(252 246 236|rgb\\(255 251 244|rgb\\(232 213 190|rgb\\(126 83 47|box-shadow|@media \\(min-width: 0px\\)" Build/css/raptor-core.css
```

Expected:

- CSS includes the five style class families.
- CSS includes warm paper colors such as `rgb(252 246 236 / 100%)`, `rgb(255 251 244 / 100%)`, `rgb(232 213 190 / 100%)`, and `rgb(126 83 47 / 100%)`.
- CSS includes `box-shadow`.
- CSS does not include `@media (min-width: 0px)` for the new visual style classes.

- [ ] **Step 5: Confirm worktree state**

Run:

```bash
git status --short
```

Expected: only ignored or unrelated local files remain. The existing untracked `.superpowers/` visual companion directory may remain untracked.

- [ ] **Step 6: Commit verification fixes or record no-op closure**

If verification required tracked changes, commit them:

```bash
git add Sources Tests
git commit -m "fix: finalize warm visual polish"
```

Expected when verification produced no tracked changes:

```text
No commit is created for Task 5 because Tasks 1-4 already contain the implementation.
```

---

## Self-Review Notes

- Spec coverage: The plan covers warm visual style types, page canvas, post cards, metadata hierarchy, sidebar panel palette, route publishing checks, generated CSS checks, and final publish verification.
- Scope control: The plan does not add search, TOC, theme switching, banners, animations, article navigation, content metadata, or route changes.
- Type consistency: Style type names match the spec and later component usage: `PageCanvasStyle`, `ContentSurfaceStyle`, `PostCardStyle`, and `MetadataTextStyle`.
- Raptor API consistency: The plan uses public `Style`, `EnvironmentConditions`, `Property`, `foregroundStyle`, `border`, and `shadow` APIs. Responsive branches use `environment.horizontalSizeClass < .regular` to preserve mobile-first base output.
