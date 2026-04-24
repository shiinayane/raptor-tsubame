# Fuwari Shell Visual Stabilization Stage 3.5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stabilize the existing Fuwari-inspired shell visually with semantic Raptor styles, clearer sidebar markers, and explicit desktop/mobile layout rules.

**Architecture:** Add a small `Sources/Styles/Shell/` style group and apply it from `MainLayout` and sidebar components. Preserve content-first DOM order, move visual ordering out of inline layout code, and keep pages/components structurally focused.

**Tech Stack:** Swift 6.2, Raptor 0.1.2 `Style`, Swift Testing, existing publishing harness

---

## File Structure

### New files

- `Sources/Styles/Shell/SiteShellStyle.swift`
  Owns the macro shell layout: desktop two-column flex, mobile single-column fallback, gap, width, and centering.
- `Sources/Styles/Shell/ShellMainStyle.swift`
  Owns main content flex behavior and readable width constraints.
- `Sources/Styles/Shell/ShellSidebarStyle.swift`
  Owns sidebar track width, shrink behavior, and visual ordering.
- `Sources/Styles/Shell/SidebarPanelStyle.swift`
  Owns the soft panel treatment for sidebar sections.

### Existing files to modify

- `Sources/Layouts/MainLayout.swift`
  Apply shell/main/sidebar styles and remove raw inline visual order.
- `Sources/Components/Sidebar/SidebarContainer.swift`
  Change the `<aside>` marker from `data-sidebar-shell` to `data-sidebar-container`.
- `Sources/Components/Sidebar/SidebarProfile.swift`
  Apply `SidebarPanelStyle`.
- `Sources/Components/Sidebar/SidebarCategories.swift`
  Apply `SidebarPanelStyle`.
- `Sources/Components/Sidebar/SidebarTags.swift`
  Apply `SidebarPanelStyle`.
- `Tests/RaptorTsubameTests/Publishing/SidebarRenderingTests.swift`
  Tighten marker ownership tests.
- `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`
  Update shared shell assertions to include `data-sidebar-container` and single shell marker ownership.
- `Tests/RaptorTsubameTests/Publishing/TaxonomyPublishingTests.swift`
  Update taxonomy publishing assertions for marker ownership.

---

### Task 1: Lock Sidebar Marker Ownership With Failing Tests

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SidebarRenderingTests.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/TaxonomyPublishingTests.swift`

- [ ] **Step 1: Add marker ownership helpers to `SidebarRenderingTests`**

Add these helpers near the bottom of `Tests/RaptorTsubameTests/Publishing/SidebarRenderingTests.swift`:

```swift
private func expectSidebarShell(in html: String) throws {
    let main = try mainSlice(of: html)

    #expect(occurrenceCount(of: "data-sidebar-shell=\"true\"", in: main) == 1)
    #expect(main.contains("data-sidebar-container=\"true\""))
    #expect(main.contains("data-sidebar-profile"))
    #expect(main.contains("data-sidebar-categories"))
    #expect(main.contains("data-sidebar-tags"))
    #expect(main.contains("data-sidebar-position=\"leading\""))
}

private func mainSlice(of html: String) throws -> String {
    let mainOpen = try #require(html.range(of: "<main"))
    let mainClose = try #require(html.range(of: "</main>"))
    return String(html[mainOpen.lowerBound..<mainClose.upperBound])
}

private func occurrenceCount(of needle: String, in haystack: String) -> Int {
    guard !needle.isEmpty else { return 0 }
    return haystack.components(separatedBy: needle).count - 1
}
```

Replace the existing `expectSidebarShell(in:)` helper in the same file with this version. If `mainSlice(of:)` or `occurrenceCount(of:in:)` already exists in the file, keep one definition only.

- [ ] **Step 2: Update shared shell helpers in publishing suites**

In both `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift` and `Tests/RaptorTsubameTests/Publishing/TaxonomyPublishingTests.swift`, update `expectSharedSidebarShell(in:contentNeedles:)` to:

```swift
private func expectSharedSidebarShell(
    in html: String,
    contentNeedles: [String]
) throws {
    let main = try mainSlice(of: html)

    #expect(occurrenceCount(of: "data-sidebar-shell=\"true\"", in: main) == 1)
    #expect(main.contains("class=\"site-shell\""))
    #expect(main.contains("data-shell-layout=\"two-column\""))
    #expect(main.contains("data-sidebar-position=\"leading\""))
    #expect(main.contains("data-sidebar-container=\"true\""))
    #expect(main.contains("data-sidebar-profile"))
    #expect(main.contains("data-sidebar-categories"))
    #expect(main.contains("data-sidebar-tags"))

    for needle in contentNeedles {
        #expect(main.contains(needle))
    }
}
```

Add this helper to each file if it does not already exist:

```swift
private func occurrenceCount(of needle: String, in haystack: String) -> Int {
    guard !needle.isEmpty else { return 0 }
    return haystack.components(separatedBy: needle).count - 1
}
```

- [ ] **Step 3: Run marker-focused tests to verify the red state**

Run:

```bash
swift test --filter SidebarRenderingTests
swift test --filter SitePublishingTests
swift test --filter TaxonomyPublishingTests
```

Expected: FAIL because current output still uses `data-sidebar-shell="true"` on both the outer shell and `<aside>`, and does not emit `data-sidebar-container="true"`.

- [ ] **Step 4: Commit**

```bash
git add Tests/RaptorTsubameTests/Publishing/SidebarRenderingTests.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift Tests/RaptorTsubameTests/Publishing/TaxonomyPublishingTests.swift
git commit -m "test: lock sidebar shell marker ownership"
```

---

### Task 2: Add Semantic Shell Style Types

**Files:**
- Create: `Sources/Styles/Shell/SiteShellStyle.swift`
- Create: `Sources/Styles/Shell/ShellMainStyle.swift`
- Create: `Sources/Styles/Shell/ShellSidebarStyle.swift`
- Create: `Sources/Styles/Shell/SidebarPanelStyle.swift`

- [ ] **Step 1: Create `SiteShellStyle`**

Create `Sources/Styles/Shell/SiteShellStyle.swift`:

```swift
import Foundation
import Raptor

struct SiteShellStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass == .compact {
            content
                .style(.display(.flex))
                .style(.flexDirection(.column))
                .style(.gap(.px(24)))
                .style(.width(.percent(100)))
        } else {
            content
                .style(.display(.flex))
                .style(.flexDirection(.row))
                .style(.alignItems(.flexStart))
                .style(.gap(.px(32)))
                .style(.width(.percent(100)))
                .style(.maxWidth(.px(1120)))
                .style(.marginInline(nil))
        }
    }
}
```

- [ ] **Step 2: Create `ShellMainStyle`**

Create `Sources/Styles/Shell/ShellMainStyle.swift`:

```swift
import Foundation
import Raptor

struct ShellMainStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass == .compact {
            content
                .style(.width(.percent(100)))
                .style(.minWidth(.px(0)))
        } else {
            content
                .style(.flexGrow(1))
                .style(.flexShrink(1))
                .style(.flexBasis(.length(.px(0))))
                .style(.minWidth(.px(0)))
                .style(.maxWidth(.px(760)))
        }
    }
}
```

- [ ] **Step 3: Create `ShellSidebarStyle`**

Create `Sources/Styles/Shell/ShellSidebarStyle.swift`:

```swift
import Foundation
import Raptor

struct ShellSidebarStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass == .compact {
            content
                .style(.width(.percent(100)))
                .style(.order(0))
        } else {
            content
                .style(.order(-1))
                .style(.flexGrow(0))
                .style(.flexShrink(0))
                .style(.flexBasis(.length(.px(280))))
                .style(.width(.px(280)))
                .style(.maxWidth(.px(300)))
        }
    }
}
```

- [ ] **Step 4: Create `SidebarPanelStyle`**

Create `Sources/Styles/Shell/SidebarPanelStyle.swift`:

```swift
import Foundation
import Raptor

struct SidebarPanelStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass == .compact {
            content
                .style(.padding(.px(16)))
                .style(.borderRadius(.px(10)))
                .style(.backgroundColor(.rgb(250, 250, 248)))
                .border(.rgb(230, 228, 222), width: 1, style: .solid)
        } else {
            content
                .style(.padding(.px(18)))
                .style(.borderRadius(.px(12)))
                .style(.backgroundColor(.rgb(250, 250, 248)))
                .border(.rgb(230, 228, 222), width: 1, style: .solid)
                .shadow(.rgb(40, 36, 30, 0.06), radius: 18, x: 0, y: 10)
        }
    }
}
```

- [ ] **Step 5: Build to verify style API compatibility**

Run:

```bash
swift build
```

Expected: PASS. If any Raptor style API differs, update only these four style files to use valid `Property` calls while preserving the same CSS intent.

- [ ] **Step 6: Commit**

```bash
git add Sources/Styles/Shell/SiteShellStyle.swift Sources/Styles/Shell/ShellMainStyle.swift Sources/Styles/Shell/ShellSidebarStyle.swift Sources/Styles/Shell/SidebarPanelStyle.swift
git commit -m "feat: add semantic shell styles"
```

---

### Task 3: Apply Shell Styles From Layout

**Files:**
- Modify: `Sources/Layouts/MainLayout.swift`

- [ ] **Step 1: Update layout structure**

Replace the current `body` in `Sources/Layouts/MainLayout.swift` with:

```swift
var body: some Document {
    Navigation { TopNavigation().body }
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
    Footer { PageFooter() }
}
```

This keeps `content` first in DOM order, moves visual ordering into `ShellSidebarStyle`, and gives the main content its own wrapper for sizing.

- [ ] **Step 2: Run shell rendering tests**

Run:

```bash
swift test --filter SidebarRenderingTests
```

Expected: still FAIL because the `<aside>` marker has not yet changed to `data-sidebar-container`.

- [ ] **Step 3: Build to verify layout/style wiring**

Run:

```bash
swift build
```

Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add Sources/Layouts/MainLayout.swift
git commit -m "refactor: apply semantic shell styles from layout"
```

---

### Task 4: Clean Sidebar Container Marker And Apply Panel Style

**Files:**
- Modify: `Sources/Components/Sidebar/SidebarContainer.swift`
- Modify: `Sources/Components/Sidebar/SidebarProfile.swift`
- Modify: `Sources/Components/Sidebar/SidebarCategories.swift`
- Modify: `Sources/Components/Sidebar/SidebarTags.swift`

- [ ] **Step 1: Change the sidebar container marker**

Update `Sources/Components/Sidebar/SidebarContainer.swift`:

```swift
import Foundation
import Raptor

struct SidebarContainer<Content: HTML>: HTML {
    @HTMLBuilder let content: () -> Content

    var body: some HTML {
        Tag("aside") {
            VStack(alignment: .leading, spacing: 16) {
                content()
            }
        }
        .data("sidebar-container", "true")
    }
}
```

- [ ] **Step 2: Apply panel style to profile block**

Update the final modifier chain in `Sources/Components/Sidebar/SidebarProfile.swift`:

```swift
.style(SidebarPanelStyle())
.data("sidebar-profile", "true")
```

The file should remain structurally the same:

```swift
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
        .style(SidebarPanelStyle())
        .data("sidebar-profile", "true")
    }
}
```

- [ ] **Step 3: Apply panel style to categories block**

Update `Sources/Components/Sidebar/SidebarCategories.swift`:

```swift
import Foundation
import Raptor

struct SidebarCategories: HTML {
    let items: [TaxonomyCountItem]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categories").font(.title5)
            ForEach(items) { item in
                Link("\(item.name) (\(item.count))", destination: item.path)
            }
        }
        .style(SidebarPanelStyle())
        .data("sidebar-categories", "true")
    }
}
```

- [ ] **Step 4: Apply panel style to tags block**

Update `Sources/Components/Sidebar/SidebarTags.swift`:

```swift
import Foundation
import Raptor

struct SidebarTags: HTML {
    let items: [TaxonomyCountItem]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags").font(.title5)
            ForEach(items) { item in
                Link("\(item.name) (\(item.count))", destination: item.path)
            }
        }
        .style(SidebarPanelStyle())
        .data("sidebar-tags", "true")
    }
}
```

- [ ] **Step 5: Run focused publishing tests**

Run:

```bash
swift test --filter SidebarRenderingTests
swift test --filter SitePublishingTests
swift test --filter TaxonomyPublishingTests
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add Sources/Components/Sidebar/SidebarContainer.swift Sources/Components/Sidebar/SidebarProfile.swift Sources/Components/Sidebar/SidebarCategories.swift Sources/Components/Sidebar/SidebarTags.swift
git commit -m "refactor: clarify sidebar container styling"
```

---

### Task 5: Final Publish Verification And Worktree Closure

**Files:**
- Verify:
  - `Build/index.html`
  - `Build/archive/index.html`
  - `Build/about/index.html`
  - `Build/posts/welcome-to-tsubame/index.html`
  - `Build/css/raptor-core.css`
- Modify only when one of the explicit verification checks in this task fails:
  - `Sources/Styles/Shell/*.swift`
  - `Sources/Layouts/MainLayout.swift`
  - `Sources/Components/Sidebar/*.swift`
  - `Tests/RaptorTsubameTests/Publishing/*.swift`

- [ ] **Step 1: Run full test suite**

Run:

```bash
swift test
```

Expected: PASS with all existing tests.

- [ ] **Step 2: Publish the site**

Run:

```bash
swift run RaptorTsubame
```

Expected output includes:

```text
📗 Publish completed!
```

- [ ] **Step 3: Inspect shell markers in generated output**

Run:

```bash
rg -n "site-shell|data-sidebar-shell|data-sidebar-container|data-shell-layout|data-sidebar-position" Build/index.html Build/archive/index.html Build/about/index.html Build/posts/welcome-to-tsubame/index.html
```

Expected:

- Each listed file contains `class="site-shell"`.
- Each listed file contains exactly one `data-sidebar-shell="true"` in its `<main>` region.
- Each listed file contains `data-sidebar-container="true"`.
- Each listed file contains `data-shell-layout="two-column"`.
- Each listed file contains `data-sidebar-position="leading"`.

- [ ] **Step 4: Inspect generated CSS for style classes**

Run:

```bash
rg -n "site-shell-style|shell-main-style|shell-sidebar-style|sidebar-panel-style|flex-basis|order|box-shadow" Build/css/raptor-core.css
```

Expected: generated CSS includes classes for the new style types and contains layout-related CSS such as `flex-basis`, `order`, and panel styling such as `box-shadow`.

- [ ] **Step 5: Confirm worktree state**

Run:

```bash
git status --short
```

Expected: only ignored or unrelated local files remain. If the command lists tracked changes in `Sources/` or `Tests/`, inspect them and confirm they are the intentional result of fixing a failed verification check from this task.

- [ ] **Step 6: Commit verification fixes or record no-op closure**

If `git status --short` shows intentional tracked changes from fixing a failed verification check, commit them:

```bash
git add Sources Tests
git commit -m "feat: stabilize shell visual structure"
```

Expected when verification produced no tracked changes:

```text
No commit is created for Task 5 because Tasks 1-4 already contain the implementation.
```

---

## Self-Review Notes

- Spec coverage: The plan covers semantic shell styles, desktop/mobile layout behavior, marker cleanup, sidebar panel treatment, publishing tests, and final generated output checks.
- Scope control: The plan does not add TOC, search, animation, theme switching, banner work, or article card redesign.
- Type consistency: Style names and paths are consistent across tasks: `SiteShellStyle`, `ShellMainStyle`, `ShellSidebarStyle`, and `SidebarPanelStyle`.
- Testing path: Marker ownership tests fail before implementation, then focused publishing suites and full `swift test` verify behavior after implementation.
