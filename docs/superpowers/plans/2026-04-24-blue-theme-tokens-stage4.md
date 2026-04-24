# Blue Theme Tokens Stage 4 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Stage 3.6 hard-coded warm palette with semantic blue theme tokens that emit light and dark visual CSS through Raptor's public color-scheme environment.

**Architecture:** Add a focused `SiteThemePalette` token type, update publishing tests to lock light/dark generated output, then migrate existing visual styles to resolve token values from `EnvironmentConditions.colorScheme`. Keep layout, routes, sidebar marker ownership, and content model unchanged.

**Tech Stack:** Swift 6.2, Raptor 0.1.2 `Style`, `EnvironmentConditions.colorScheme`, Swift Testing, published HTML/CSS verification

---

## File Structure

### New files

- `Sources/Theme/SiteThemePalette.swift`
  Owns semantic light/dark blue theme tokens and palette resolution from Raptor style environment.

### Existing files to modify

- `Sources/Layouts/MainLayout.swift`
  Replace hard-coded warm page background with the light page background token.
- `Sources/Styles/Visual/PageCanvasStyle.swift`
  Replace warm page canvas color with tokenized light/dark canvas color.
- `Sources/Styles/Visual/ContentSurfaceStyle.swift`
  Replace warm surface, border, and shadow values with theme tokens.
- `Sources/Styles/Visual/PostCardStyle.swift`
  Replace warm text color with theme token.
- `Sources/Styles/Visual/MetadataTextStyle.swift`
  Replace warm muted text color with theme token.
- `Sources/Styles/Shell/SidebarPanelStyle.swift`
  Replace warm sidebar surface, text, border, and shadow values with theme tokens.
- `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`
  Rename warm visual checks to blue theme checks and assert both light and dark token CSS output.

---

### Task 1: Lock Blue Theme Publishing Contract With Failing Tests

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Rename the Stage 3.6 warm visual test**

In `SitePublishingTests`, replace:

```swift
@Test("published pages include warm visual style classes")
func publishedPagesIncludeWarmVisualStyleClasses() async throws {
```

with:

```swift
@Test("published pages include blue theme visual styles")
func publishedPagesIncludeBlueThemeVisualStyles() async throws {
```

- [ ] **Step 2: Rename warm helper calls in the test**

Inside `publishedPagesIncludeBlueThemeVisualStyles()`, replace:

```swift
try expectWarmVisualHTML(in: homepage)
try expectWarmVisualHTML(in: archive)
try expectWarmShellHTML(in: about)
try expectWarmShellHTML(in: article)
```

with:

```swift
try expectBlueThemeVisualHTML(in: homepage)
try expectBlueThemeVisualHTML(in: archive)
try expectBlueThemeShellHTML(in: about)
try expectBlueThemeShellHTML(in: article)
```

- [ ] **Step 3: Rename CSS helper call**

In `generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint()`, replace:

```swift
try expectWarmVisualCSS(in: css)
```

with:

```swift
try expectBlueThemeVisualCSS(in: css)
```

- [ ] **Step 4: Replace helper names and page background expectation**

Rename:

```swift
private func expectWarmVisualHTML(in html: String) throws {
    try expectWarmShellHTML(in: html)
```

to:

```swift
private func expectBlueThemeVisualHTML(in html: String) throws {
    try expectBlueThemeShellHTML(in: html)
```

Rename:

```swift
private func expectWarmShellHTML(in html: String) throws {
    try expectWarmPageBackground(in: html)
```

to:

```swift
private func expectBlueThemeShellHTML(in html: String) throws {
    try expectBlueThemePageBackground(in: html)
```

Rename and update the page background helper:

```swift
private func expectBlueThemePageBackground(in html: String) throws {
    let htmlTag = try openingTag(startingWith: "<html", in: html)
    #expect(htmlTag.contains("--bg-page: rgb(247 251 255 / 100%)"))
}
```

- [ ] **Step 5: Replace CSS color assertions**

Replace `expectWarmVisualCSS(in:)` with:

```swift
private func expectBlueThemeVisualCSS(in css: String) throws {
    #expect(css.contains(".page-canvas-style"))
    #expect(css.contains(".post-card-style"))
    #expect(css.contains(".content-surface-style"))
    #expect(css.contains(".metadata-text-style"))
    #expect(css.contains(".sidebar-panel-style"))

    #expect(css.contains("rgb(247 251 255 / 100%)"))
    #expect(css.contains("rgb(242 248 255 / 100%)"))
    #expect(css.contains("rgb(251 253 255 / 100%)"))
    #expect(css.contains("rgb(200 221 242 / 100%)"))
    #expect(css.contains("rgb(19 40 62 / 100%)"))
    #expect(css.contains("rgb(88 113 139 / 100%)"))
    #expect(css.contains("rgb(7 17 29 / 100%)"))
    #expect(css.contains("rgb(11 23 38 / 100%)"))
    #expect(css.contains("rgb(36 71 98 / 100%)"))
    #expect(css.contains("rgb(220 236 255 / 100%)"))
    #expect(css.contains("rgb(142 169 197 / 100%)"))
    #expect(css.contains("[data-color-scheme=\"dark\"]"))
    #expect(css.contains("box-shadow:"))

    #expect(!css.contains("@media (min-width: 0px) {\n    .page-canvas-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .post-card-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .content-surface-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .metadata-text-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .sidebar-panel-style"))

    let sidebarPanelRule = try cssRule(in: css, containing: ".sidebar-panel-style")
    #expect(sidebarPanelRule.contains("rgb(251 253 255 / 100%)"))
    #expect(sidebarPanelRule.contains("rgb(200 221 242 / 100%)"))
    #expect(sidebarPanelRule.contains("rgb(19 40 62 / 100%)"))
}
```

- [ ] **Step 6: Run the targeted publishing test to verify red state**

Run:

```bash
swift test --filter SitePublishingTests/publishedPagesIncludeBlueThemeVisualStyles
```

Expected: FAIL. The current implementation still emits warm colors such as `rgb(252 246 236 / 100%)`, so the new blue page background assertion should fail.

- [ ] **Step 7: Run the CSS publishing test to verify red state**

Run:

```bash
swift test --filter SitePublishingTests/generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint
```

Expected: FAIL. The current implementation still emits warm colors and no dark blue token output, so the new CSS assertions should fail.

- [ ] **Step 8: Commit**

```bash
git add Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "test: lock blue theme publishing contract"
```

---

### Task 2: Add Blue Theme Palette Tokens

**Files:**
- Create: `Sources/Theme/SiteThemePalette.swift`

- [ ] **Step 1: Create `SiteThemePalette`**

Create `Sources/Theme/SiteThemePalette.swift`:

```swift
import Foundation
import Raptor

struct SiteThemePalette: Sendable {
    let pageBackground: Color
    let canvasBackground: Color
    let surface: Color
    let surfaceRaised: Color
    let border: Color
    let text: Color
    let mutedText: Color
    let accent: Color
    let shadow: Color

    static let light = SiteThemePalette(
        pageBackground: Color(red: 247, green: 251, blue: 255),
        canvasBackground: Color(red: 242, green: 248, blue: 255),
        surface: Color(red: 251, green: 253, blue: 255),
        surfaceRaised: Color(red: 255, green: 255, blue: 255),
        border: Color(red: 200, green: 221, blue: 242),
        text: Color(red: 19, green: 40, blue: 62),
        mutedText: Color(red: 88, green: 113, blue: 139),
        accent: Color(red: 74, green: 139, blue: 203),
        shadow: Color(red: 34, green: 86, blue: 137, opacity: 14%)
    )

    static let dark = SiteThemePalette(
        pageBackground: Color(red: 7, green: 17, blue: 29),
        canvasBackground: Color(red: 7, green: 17, blue: 29),
        surface: Color(red: 11, green: 23, blue: 38),
        surfaceRaised: Color(red: 16, green: 34, blue: 54),
        border: Color(red: 36, green: 71, blue: 98),
        text: Color(red: 220, green: 236, blue: 255),
        mutedText: Color(red: 142, green: 169, blue: 197),
        accent: Color(red: 120, green: 184, blue: 245),
        shadow: Color(red: 0, green: 0, blue: 0, opacity: 36%)
    )

    static func resolve(for environment: EnvironmentConditions) -> SiteThemePalette {
        environment.colorScheme == .dark ? .dark : .light
    }
}
```

- [ ] **Step 2: Build to verify API compatibility**

Run:

```bash
swift build
```

Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add Sources/Theme/SiteThemePalette.swift
git commit -m "feat: add blue theme palette tokens"
```

---

### Task 3: Migrate Visual Styles To Theme Tokens

**Files:**
- Modify: `Sources/Styles/Visual/PageCanvasStyle.swift`
- Modify: `Sources/Styles/Visual/ContentSurfaceStyle.swift`
- Modify: `Sources/Styles/Visual/PostCardStyle.swift`
- Modify: `Sources/Styles/Visual/MetadataTextStyle.swift`
- Modify: `Sources/Styles/Shell/SidebarPanelStyle.swift`
- Modify: `Sources/Layouts/MainLayout.swift`

- [ ] **Step 1: Update `PageCanvasStyle`**

Replace `Sources/Styles/Visual/PageCanvasStyle.swift` with:

```swift
import Foundation
import Raptor

struct PageCanvasStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .background(palette.canvasBackground)
                .style(.paddingBlock(.px(24)))
                .style(.paddingInline(.px(16)))
                .style(.minWidth(.px(0)))
        } else {
            content
                .background(palette.canvasBackground)
                .style(.paddingBlock(.px(40)))
                .style(.paddingInline(.px(24)))
                .style(.minWidth(.px(0)))
        }
    }
}
```

- [ ] **Step 2: Update `ContentSurfaceStyle`**

Replace `Sources/Styles/Visual/ContentSurfaceStyle.swift` with:

```swift
import Foundation
import Raptor

struct ContentSurfaceStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .background(palette.surface)
                .style(.borderRadius(.px(16)))
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .background(palette.surface)
                .style(.borderRadius(.px(18)))
                .border(palette.border, width: 1, style: .solid)
                .shadow(palette.shadow, radius: 22, x: 0, y: 12)
        }
    }
}
```

- [ ] **Step 3: Update `PostCardStyle`**

Replace `Sources/Styles/Visual/PostCardStyle.swift` with:

```swift
import Foundation
import Raptor

struct PostCardStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.padding(.px(18)))
                .style(.lineHeight(1.55))
                .foregroundStyle(palette.text)
        } else {
            content
                .style(.padding(.px(22)))
                .style(.lineHeight(1.58))
                .foregroundStyle(palette.text)
        }
    }
}
```

- [ ] **Step 4: Update `MetadataTextStyle`**

Replace `Sources/Styles/Visual/MetadataTextStyle.swift` with:

```swift
import Foundation
import Raptor

struct MetadataTextStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.lineHeight(1.5))
            .foregroundStyle(palette.mutedText)
    }
}
```

- [ ] **Step 5: Update `SidebarPanelStyle`**

Replace `Sources/Styles/Shell/SidebarPanelStyle.swift` with:

```swift
import Foundation
import Raptor

struct SidebarPanelStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.padding(.px(16)))
                .style(.borderRadius(.px(12)))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.padding(.px(18)))
                .style(.borderRadius(.px(14)))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
                .shadow(palette.shadow, radius: 18, x: 0, y: 10)
        }
    }
}
```

- [ ] **Step 6: Update `MainLayout` page background**

In `Sources/Layouts/MainLayout.swift`, replace:

```swift
.background(Color(red: 252, green: 246, blue: 236))
```

with:

```swift
.background(SiteThemePalette.light.pageBackground)
```

- [ ] **Step 7: Run focused publishing tests**

Run:

```bash
swift test --filter SitePublishingTests
```

Expected: PASS. The Stage 4 publishing contract should now find light blue HTML output and light/dark blue generated CSS output.

- [ ] **Step 8: Build**

Run:

```bash
swift build
```

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add Sources/Styles/Visual/PageCanvasStyle.swift Sources/Styles/Visual/ContentSurfaceStyle.swift Sources/Styles/Visual/PostCardStyle.swift Sources/Styles/Visual/MetadataTextStyle.swift Sources/Styles/Shell/SidebarPanelStyle.swift Sources/Layouts/MainLayout.swift
git commit -m "feat: apply blue theme tokens to visual styles"
```

---

### Task 4: Final Publish Verification

**Files:**
- Verify:
  - `Build/index.html`
  - `Build/archive/index.html`
  - `Build/about/index.html`
  - `Build/posts/welcome-to-tsubame/index.html`
  - `Build/css/raptor-core.css`
- Modify only if verification reveals a mismatch:
  - `Sources/Theme/SiteThemePalette.swift`
  - `Sources/Styles/Visual/*.swift`
  - `Sources/Styles/Shell/SidebarPanelStyle.swift`
  - `Sources/Layouts/MainLayout.swift`
  - `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Run full test suite**

Run:

```bash
swift test
```

Expected: PASS with 31 or more tests in 7 suites. The exact count may increase if future accepted test additions occur during this stage.

- [ ] **Step 2: Publish the site**

Run:

```bash
swift run RaptorTsubame
```

Expected output includes:

```text
📗 Publish completed!
```

- [ ] **Step 3: Inspect generated HTML**

Run:

```bash
rg -n -- "<html|--bg-page|page-canvas-style|post-card-style|content-surface-style|metadata-text-style|sidebar-panel-style|data-post-card|data-post-meta" Build/index.html Build/archive/index.html Build/about/index.html Build/posts/welcome-to-tsubame/index.html
```

Expected:

- `Build/index.html`, `Build/archive/index.html`, `Build/about/index.html`, and `Build/posts/welcome-to-tsubame/index.html` contain `--bg-page: rgb(247 251 255 / 100%)`.
- `Build/index.html` and `Build/archive/index.html` contain `post-card-style`, `content-surface-style`, `metadata-text-style`, `data-post-card`, and `data-post-meta`.
- `Build/about/index.html` contains `page-canvas-style` and `sidebar-panel-style`.
- `Build/posts/welcome-to-tsubame/index.html` contains `page-canvas-style`, `metadata-text-style`, `data-post-meta`, and `sidebar-panel-style`.

- [ ] **Step 4: Inspect generated CSS**

Run:

```bash
rg -n -- "page-canvas-style|post-card-style|content-surface-style|metadata-text-style|sidebar-panel-style|data-color-scheme|rgb\\(247 251 255|rgb\\(242 248 255|rgb\\(251 253 255|rgb\\(200 221 242|rgb\\(19 40 62|rgb\\(88 113 139|rgb\\(7 17 29|rgb\\(11 23 38|rgb\\(36 71 98|rgb\\(220 236 255|rgb\\(142 169 197|box-shadow" Build/css/raptor-core.css
```

Expected:

- CSS includes the five visual/shell style class families.
- CSS includes light blue token values such as `rgb(247 251 255 / 100%)`, `rgb(242 248 255 / 100%)`, `rgb(251 253 255 / 100%)`, `rgb(200 221 242 / 100%)`, `rgb(19 40 62 / 100%)`, and `rgb(88 113 139 / 100%)`.
- CSS includes dark blue token values such as `rgb(7 17 29 / 100%)`, `rgb(11 23 38 / 100%)`, `rgb(36 71 98 / 100%)`, `rgb(220 236 255 / 100%)`, and `rgb(142 169 197 / 100%)`.
- CSS includes `[data-color-scheme="dark"]`.
- CSS includes `box-shadow`.

- [ ] **Step 5: Confirm no `min-width: 0px` visual regression**

Run:

```bash
rg -n "@media \\(min-width: 0px\\).*page-canvas-style|@media \\(min-width: 0px\\).*post-card-style|@media \\(min-width: 0px\\).*content-surface-style|@media \\(min-width: 0px\\).*metadata-text-style|@media \\(min-width: 0px\\).*sidebar-panel-style" Build/css/raptor-core.css
```

Expected: no matches and exit code 1.

- [ ] **Step 6: Confirm worktree state**

Run:

```bash
git status --short
```

Expected: only ignored or unrelated local files remain. The existing untracked `.superpowers/` visual companion directory may remain untracked.

- [ ] **Step 7: Commit verification fixes or record no-op closure**

If verification required tracked changes, commit them:

```bash
git add Sources Tests
git commit -m "fix: finalize blue theme tokens"
```

Expected when verification produced no tracked changes:

```text
No commit is created for Task 4 because Tasks 1-3 already contain the implementation.
```

---

## Self-Review Notes

- Spec coverage: The plan covers semantic token creation, light/dark palette output, style migration, page background registration, generated CSS checks, route coverage, and final publish verification.
- Scope control: The plan does not add a theme toggle, custom JavaScript, article redesign, route changes, search, table of contents, animation, or Fuwari-specific implementation details.
- Type consistency: `SiteThemePalette.resolve(for:)`, `SiteThemePalette.light`, and `SiteThemePalette.dark` are defined before use in styles and `MainLayout`.
- Raptor API consistency: The plan uses public `Style`, `EnvironmentConditions.colorScheme`, `Color`, `StyleConfiguration.background(_:)`, `foregroundStyle`, `border`, `shadow`, and `Main.background(_:)` APIs. It does not rely on package-private Raptor APIs.
