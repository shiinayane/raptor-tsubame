# Stage 9 Site Chrome And UI Primitives Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the bare site navigation/footer with durable site chrome and add reusable UI primitives for later framework stages.

**Architecture:** Keep Stage 9 static and server-rendered: no search, theme switcher, dropdown, or JavaScript menu behavior. Navigation active state is derived from Raptor's public `@Environment(\.page)` through a project-owned selection model. Chrome primitives live under `Sources/Components/Chrome` and styles under `Sources/Styles/Chrome`, using existing `SiteThemePalette` tokens.

**Tech Stack:** Swift, Raptor public API, Swift Testing, generated HTML/CSS assertions, static output inspection.

---

## Scope Boundaries

Included:

- Branded top navigation.
- Home, Archive, and About primary links.
- Current-page state for Home, Archive, and About.
- Static responsive navigation layout.
- Styled footer shell with copyright, RSS, sitemap, and Raptor link markers.
- Shared chrome primitives: surface, button link, badge, section title, icon box, muted text.
- Published HTML/CSS regression tests.

Excluded:

- Search.
- Theme switcher.
- Hue picker.
- JavaScript menu toggle.
- Dropdown menus.
- Page transitions.
- Banner system.
- Post-card content upgrades.
- Archive/category/tag page information-architecture changes.
- Sidebar tag-count removal and category width tuning.

## File Structure

- Create `Sources/Components/Chrome/NavigationSelection.swift`: route-derived primary navigation active state.
- Create `Sources/Components/Chrome/NavigationItem.swift`: small data model for top navigation links.
- Create `Sources/Components/Chrome/ChromeSurface.swift`: reusable surface wrapper.
- Create `Sources/Components/Chrome/ChromeButtonLink.swift`: reusable button-like link with optional active state.
- Create `Sources/Components/Chrome/ChromeBadge.swift`: compact badge primitive.
- Create `Sources/Components/Chrome/ChromeSectionTitle.swift`: accent section title primitive.
- Create `Sources/Components/Chrome/ChromeIconBox.swift`: fixed-size icon/text primitive.
- Modify `Sources/Components/Chrome/TopNavigation.swift`: brand, primary links, active state, markers.
- Modify `Sources/Components/Chrome/PageFooter.swift`: footer shell and link markers.
- Create `Sources/Styles/Chrome/ChromePrimitiveStyles.swift`: primitive styles.
- Create `Sources/Styles/Chrome/TopNavigationStyle.swift`: navigation layout/link styles.
- Create `Sources/Styles/Chrome/PageFooterStyle.swift`: footer layout/link styles.
- Modify `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`: top navigation, footer, and CSS assertions.
- Modify `Tests/RaptorTsubameTests/Components/SidebarSupportTests.swift` or create `Tests/RaptorTsubameTests/Components/ChromeSupportTests.swift`: model-level `NavigationSelection` tests.

## Task 1: Navigation Selection Model

**Files:**
- Create: `Sources/Components/Chrome/NavigationSelection.swift`
- Create: `Sources/Components/Chrome/NavigationItem.swift`
- Create: `Tests/RaptorTsubameTests/Components/ChromeSupportTests.swift`

- [ ] **Step 1: Write failing model tests**

Create `Tests/RaptorTsubameTests/Components/ChromeSupportTests.swift`:

```swift
import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Chrome support")
struct ChromeSupportTests {
    @Test("navigation selection marks home routes")
    func navigationSelectionMarksHomeRoutes() {
        #expect(NavigationSelection(path: "/").activeItem == .home)
        #expect(NavigationSelection(path: "/2/").activeItem == .home)
        #expect(NavigationSelection(path: "/12").activeItem == .home)
    }

    @Test("navigation selection marks archive and about routes")
    func navigationSelectionMarksArchiveAndAboutRoutes() {
        #expect(NavigationSelection(path: "/archive/").activeItem == .archive)
        #expect(NavigationSelection(path: "/archive").activeItem == .archive)
        #expect(NavigationSelection(path: "/about/").activeItem == .about)
        #expect(NavigationSelection(path: "/about").activeItem == .about)
    }

    @Test("navigation selection ignores content and taxonomy routes")
    func navigationSelectionIgnoresContentAndTaxonomyRoutes() {
        #expect(NavigationSelection(path: "/posts/welcome-to-tsubame/").activeItem == nil)
        #expect(NavigationSelection(path: "/categories/tech/").activeItem == nil)
        #expect(NavigationSelection(path: "/tags/swift/").activeItem == nil)
    }

    @Test("navigation item exposes stable primary links")
    func navigationItemExposesStablePrimaryLinks() {
        #expect(NavigationItem.primary.map(\.id) == [.home, .archive, .about])
        #expect(NavigationItem.primary.map(\.label) == ["Home", "Archive", "About"])
        #expect(NavigationItem.primary.map(\.path) == ["/", "/archive/", "/about/"])
    }
}
```

- [ ] **Step 2: Run the focused failing test**

Run:

```bash
swift test --filter ChromeSupportTests
```

Expected: FAIL because `NavigationSelection` and `NavigationItem` do not exist.

- [ ] **Step 3: Implement navigation models**

Create `Sources/Components/Chrome/NavigationSelection.swift`:

```swift
import Foundation

struct NavigationSelection: Equatable, Sendable {
    enum Item: String, Sendable {
        case home
        case archive
        case about
    }

    let activeItem: Item?

    init(path: String) {
        let normalizedPath = Self.normalized(path)

        if normalizedPath == SiteRoutes.archive {
            self.activeItem = .archive
        } else if normalizedPath == SiteRoutes.about {
            self.activeItem = .about
        } else if normalizedPath == SiteRoutes.home || Self.isPaginatedHome(normalizedPath) {
            self.activeItem = .home
        } else {
            self.activeItem = nil
        }
    }

    func isActive(_ item: NavigationItem) -> Bool {
        activeItem == item.id
    }

    private static func normalized(_ path: String) -> String {
        guard path.hasSuffix("/") else {
            return path + "/"
        }

        return path
    }

    private static func isPaginatedHome(_ path: String) -> Bool {
        let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return !trimmed.isEmpty && trimmed.allSatisfy(\.isNumber)
    }
}
```

Create `Sources/Components/Chrome/NavigationItem.swift`:

```swift
import Foundation

struct NavigationItem: Equatable, Identifiable, Sendable {
    let id: NavigationSelection.Item
    let label: String
    let path: String

    static let primary: [NavigationItem] = [
        NavigationItem(id: .home, label: "Home", path: SiteRoutes.home),
        NavigationItem(id: .archive, label: "Archive", path: SiteRoutes.archive),
        NavigationItem(id: .about, label: "About", path: SiteRoutes.about)
    ]
}
```

- [ ] **Step 4: Run focused model tests**

Run:

```bash
swift test --filter ChromeSupportTests
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Components/Chrome/NavigationSelection.swift Sources/Components/Chrome/NavigationItem.swift Tests/RaptorTsubameTests/Components/ChromeSupportTests.swift
git commit -m "feat: add chrome navigation selection"
```

## Task 2: Chrome Primitive Components And Styles

**Files:**
- Create: `Sources/Components/Chrome/ChromeSurface.swift`
- Create: `Sources/Components/Chrome/ChromeButtonLink.swift`
- Create: `Sources/Components/Chrome/ChromeBadge.swift`
- Create: `Sources/Components/Chrome/ChromeSectionTitle.swift`
- Create: `Sources/Components/Chrome/ChromeIconBox.swift`
- Create: `Sources/Styles/Chrome/ChromePrimitiveStyles.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Write failing CSS test for primitive styles**

Add this test to `SitePublishingTests` near the other generated CSS tests:

```swift
@Test("generated CSS includes chrome primitive styles")
func generatedCSSIncludesChromePrimitiveStyles() async throws {
    let harness = try await publishedSite()
    let css = try harness.contents(of: "css/raptor-core.css")

    #expect(css.contains(".chrome-surface-style"))
    #expect(css.contains(".chrome-button-link-style"))
    #expect(css.contains(".chrome-badge-style"))
    #expect(css.contains(".chrome-section-title-style"))
    #expect(css.contains(".chrome-icon-box-style"))
    #expect(css.contains(".chrome-muted-text-style"))

    let surfaceRule = try cssRule(in: css, containing: ".chrome-surface-style")
    #expect(surfaceRule.contains("rgb(251 253 255 / 100%)"))
    #expect(surfaceRule.contains("rgb(200 221 242 / 100%)"))

    let buttonRule = try cssRule(in: css, containing: ".chrome-button-link-style")
    #expect(buttonRule.contains("text-decoration: none;"))
    #expect(buttonRule.contains("border-radius:"))

    let badgeRule = try cssRule(in: css, containing: ".chrome-badge-style")
    #expect(badgeRule.contains("border-radius: 999px;"))

    try expectDarkBlueThemeRule(in: css, containing: ".chrome-surface-style") { rule in
        #expect(rule.contains("rgb(11 23 38 / 100%)"))
        #expect(rule.contains("rgb(36 71 98 / 100%)"))
    }
}
```

- [ ] **Step 2: Run the focused failing test**

Run:

```bash
swift test --filter SitePublishingTests/generatedCSSIncludesChromePrimitiveStyles
```

Expected: FAIL because primitive style classes do not exist.

- [ ] **Step 3: Implement primitive components**

Create `Sources/Components/Chrome/ChromeSurface.swift`:

```swift
import Foundation
import Raptor

struct ChromeSurface<Content: HTML>: HTML {
    let marker: String?
    let content: () -> Content

    init(marker: String? = nil, @HTMLBuilder content: @escaping () -> Content) {
        self.marker = marker
        self.content = content
    }

    var body: some HTML {
        if let marker {
            Tag("div") {
                content()
            }
            .style(ChromeSurfaceStyle())
            .data(marker, "true")
        } else {
            Tag("div") {
                content()
            }
            .style(ChromeSurfaceStyle())
        }
    }
}
```

Create `Sources/Components/Chrome/ChromeButtonLink.swift`:

```swift
import Foundation
import Raptor

struct ChromeButtonLink: HTML {
    let label: String
    let destination: String
    let markerName: String?
    let markerValue: String?
    let isActive: Bool

    init(
        _ label: String,
        destination: String,
        markerName: String? = nil,
        markerValue: String? = nil,
        isActive: Bool = false
    ) {
        self.label = label
        self.destination = destination
        self.markerName = markerName
        self.markerValue = markerValue
        self.isActive = isActive
    }

    var body: some HTML {
        if let markerName, let markerValue {
            if isActive {
                Link(label, destination: destination)
                    .style(ChromeButtonLinkStyle(isActive: true))
                    .attribute("aria-label", label)
                    .attribute("aria-current", "page")
                    .data("nav-current", "true")
                    .data(markerName, markerValue)
            } else {
                Link(label, destination: destination)
                    .style(ChromeButtonLinkStyle(isActive: false))
                    .attribute("aria-label", label)
                    .data(markerName, markerValue)
            }
        } else {
            if isActive {
                Link(label, destination: destination)
                    .style(ChromeButtonLinkStyle(isActive: true))
                    .attribute("aria-label", label)
                    .attribute("aria-current", "page")
                    .data("nav-current", "true")
            } else {
                Link(label, destination: destination)
                    .style(ChromeButtonLinkStyle(isActive: false))
                    .attribute("aria-label", label)
            }
        }
    }
}
```

Create `Sources/Components/Chrome/ChromeBadge.swift`:

```swift
import Foundation
import Raptor

struct ChromeBadge: HTML {
    let text: String

    var body: some HTML {
        Text(text)
            .style(ChromeBadgeStyle())
            .data("chrome-badge", "true")
    }
}
```

Create `Sources/Components/Chrome/ChromeSectionTitle.swift`:

```swift
import Foundation
import Raptor

struct ChromeSectionTitle: HTML {
    let text: String

    var body: some HTML {
        Text(text)
            .style(ChromeSectionTitleStyle())
            .data("chrome-section-title", text.lowercased())
    }
}
```

Create `Sources/Components/Chrome/ChromeIconBox.swift`:

```swift
import Foundation
import Raptor

struct ChromeIconBox: HTML {
    let label: String

    var body: some HTML {
        Text(label)
            .style(ChromeIconBoxStyle())
            .attribute("aria-hidden", "true")
            .data("chrome-icon-box", "true")
    }
}
```

- [ ] **Step 4: Implement primitive styles**

Create `Sources/Styles/Chrome/ChromePrimitiveStyles.swift`:

```swift
import Foundation
import Raptor

struct ChromeSurfaceStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.width(.percent(100)))
            .style(.borderRadius(.px(16)))
            .style(.paddingBlock(.px(16)))
            .style(.paddingInline(.px(16)))
            .background(palette.surface)
            .foregroundStyle(palette.text)
            .border(palette.border, width: 1, style: .solid)
            .shadow(palette.shadow, radius: 18, x: 0, y: 10)
    }
}

struct ChromeButtonLinkStyle: Style {
    let isActive: Bool

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.gap(.px(8)))
            .style(.minWidth(.px(0)))
            .style(.paddingBlock(.px(10)))
            .style(.paddingInline(.px(14)))
            .style(.borderRadius(.px(12)))
            .style(.textDecoration(.none))
            .font(.system(size: 14, weight: .semibold))
            .background(isActive ? palette.surfaceRaised : palette.surface)
            .foregroundStyle(isActive ? palette.accent : palette.text)
            .border(isActive ? palette.accent : palette.border, width: 1, style: .solid)
    }
}

struct ChromeBadgeStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.paddingBlock(.px(3)))
            .style(.paddingInline(.px(8)))
            .style(.borderRadius(.px(999)))
            .font(.system(size: 12, weight: .semibold))
            .background(palette.canvasBackground)
            .foregroundStyle(palette.mutedText)
            .border(palette.border, width: 1, style: .solid)
    }
}

struct ChromeSectionTitleStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.block))
            .style(.textTransform(.uppercase))
            .style(.letterSpacing(.px(1)))
            .style(.fontSize(.px(13)))
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(palette.accent)
    }
}

struct ChromeIconBoxStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.width(.px(32)))
            .style(.height(.px(32)))
            .style(.borderRadius(.px(10)))
            .font(.system(size: 13, weight: .bold))
            .background(palette.surfaceRaised)
            .foregroundStyle(palette.accent)
            .border(palette.border, width: 1, style: .solid)
    }
}

struct ChromeMutedTextStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .foregroundStyle(palette.mutedText)
            .font(.system(size: 14, weight: .regular))
    }
}
```

- [ ] **Step 5: Seed primitive styles**

Because some primitives may not be used immediately in Stage 9 output, add `ChromeStyleSeed` in `Sources/Components/Chrome/ChromeStyleSeed.swift`:

```swift
import Foundation
import Raptor

struct ChromeStyleSeed: HTML {
    var body: some HTML {
        EmptyHTML().style(ChromeSurfaceStyle())
        EmptyHTML().style(ChromeButtonLinkStyle(isActive: false))
        EmptyHTML().style(ChromeButtonLinkStyle(isActive: true))
        EmptyHTML().style(ChromeBadgeStyle())
        EmptyHTML().style(ChromeSectionTitleStyle())
        EmptyHTML().style(ChromeIconBoxStyle())
        EmptyHTML().style(ChromeMutedTextStyle())
    }
}
```

Then add `ChromeStyleSeed()` once near the top of `HomePage.body` beside `ArticleStyleSeed()`:

```swift
if pageNumber == 1 {
    ArticleStyleSeed()
    ChromeStyleSeed()
}
```

- [ ] **Step 6: Run focused CSS test**

Run:

```bash
swift test --filter SitePublishingTests/generatedCSSIncludesChromePrimitiveStyles
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add Sources/Components/Chrome Sources/Styles/Chrome Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift Sources/Pages/HomePage.swift
git commit -m "feat: add chrome primitive styles"
```

## Task 3: Branded Top Navigation

**Files:**
- Modify: `Sources/Components/Chrome/TopNavigation.swift`
- Create: `Sources/Styles/Chrome/TopNavigationStyle.swift`
- Modify: `Sources/Layouts/MainLayout.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Write failing navigation publishing tests**

Replace the existing `expectSharedNavigation(in:)` helper assertions with marker-aware checks, and add route-active assertions.

Add this test to `SitePublishingTests`:

```swift
@Test("top navigation marks active primary routes")
func topNavigationMarksActivePrimaryRoutes() async throws {
    let harness = try await publishedSite()

    let homeNav = try topNavigationSlice(of: harness.contents(of: "index.html"))
    let pageTwoNav = try topNavigationSlice(of: harness.contents(of: "2/index.html"))
    let archiveNav = try topNavigationSlice(of: harness.contents(of: "archive/index.html"))
    let aboutNav = try topNavigationSlice(of: harness.contents(of: "about/index.html"))
    let postNav = try topNavigationSlice(of: harness.contents(of: "posts/welcome-to-tsubame/index.html"))
    let categoryNav = try topNavigationSlice(of: harness.contents(of: "categories/tech/index.html"))
    let tagNav = try topNavigationSlice(of: harness.contents(of: "tags/swift/index.html"))

    try expectActiveNavItem(in: homeNav, item: "home", href: "/")
    try expectActiveNavItem(in: pageTwoNav, item: "home", href: "/")
    try expectActiveNavItem(in: archiveNav, item: "archive", href: "/archive/")
    try expectActiveNavItem(in: aboutNav, item: "about", href: "/about/")

    try expectNoActivePrimaryNav(in: postNav)
    try expectNoActivePrimaryNav(in: categoryNav)
    try expectNoActivePrimaryNav(in: tagNav)
}
```

Add these helpers near the existing navigation helpers:

```swift
private func topNavigationSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-top-navigation=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let closeRange = try #require(html[marker.upperBound...].range(of: "</nav>"))
    return String(html[openStart.lowerBound..<closeRange.upperBound])
}

private func expectActiveNavItem(in nav: String, item: String, href: String) throws {
    let opening = try openingTag(containing: "data-nav-item=\"\(item)\"", in: nav)
    #expect(opening.contains("href=\"\(href)\""))
    #expect(opening.contains("data-nav-current=\"true\""))
    #expect(opening.contains("aria-current=\"page\""))
}

private func expectNoActivePrimaryNav(in nav: String) throws {
    #expect(!nav.contains("data-nav-current=\"true\""))
    #expect(!nav.contains("aria-current=\"page\""))
}
```

Update `expectSharedNavigation(in:)` to assert:

```swift
private func expectSharedNavigation(in html: String) throws {
    let nav = try topNavigationSlice(of: html)

    #expect(nav.contains("data-nav-brand=\"true\""))
    #expect(nav.contains("aria-label=\"Raptor Tsubame home\""))
    #expect(nav.contains("href=\"/\""))
    #expect(nav.contains("data-nav-item=\"home\""))
    #expect(nav.contains("data-nav-item=\"archive\""))
    #expect(nav.contains("data-nav-item=\"about\""))
    #expect(nav.contains("top-navigation-style"))
    #expect(nav.contains("top-navigation-brand-style"))
    #expect(nav.contains("top-navigation-link-style"))

    try expectLink(in: nav, label: "Home", href: "/")
    try expectLink(in: nav, label: "Archive", href: "/archive/")
    try expectLink(in: nav, label: "About", href: "/about/")
}
```

Remove `expectOneNavLinkPerListItem(in:)` if the new navigation no longer uses list items.

- [ ] **Step 2: Run focused failing tests**

Run:

```bash
swift test --filter SitePublishingTests/topNavigationMarksActivePrimaryRoutes
```

Expected: FAIL because markers and active state do not exist.

- [ ] **Step 3: Implement top navigation styles**

Create `Sources/Styles/Chrome/TopNavigationStyle.swift`:

```swift
import Foundation
import Raptor

struct TopNavigationStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            return content
                .style(.display(.flex))
                .style(.flexDirection(.column))
                .style(.gap(.px(12)))
                .style(.width(.percent(100)))
                .style(.paddingBlock(.px(14)))
                .style(.paddingInline(.px(14)))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
        } else {
            return content
                .style(.display(.flex))
                .style(.alignItems(.center))
                .style(.justifyContent(.spaceBetween))
                .style(.gap(.px(18)))
                .style(.width(.percent(100)))
                .style(.maxWidth(.px(1120)))
                .style(.marginInline(nil))
                .style(.paddingBlock(.px(14)))
                .style(.paddingInline(.px(18)))
                .style(.borderRadius(.px(16)))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
                .shadow(palette.shadow, radius: 18, x: 0, y: 10)
        }
    }
}

struct TopNavigationBrandStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.gap(.px(10)))
            .style(.textDecoration(.none))
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(palette.accent)
    }
}

struct TopNavigationLinksStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.display(.flex))
            .style(.alignItems(.center))
            .style(.gap(.px(10)))
            .style(.flexWrap(.wrap))
    }
}

struct TopNavigationActionsStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.display(.flex))
            .style(.alignItems(.center))
            .style(.gap(.px(8)))
            .style(.minWidth(.px(0)))
    }
}
```

- [ ] **Step 4: Implement branded navigation**

Replace `Sources/Components/Chrome/TopNavigation.swift` with:

```swift
import Foundation
import Raptor

struct TopNavigation: HTML {
    let siteName: String
    let selection: NavigationSelection

    var body: some HTML {
        Tag("nav") {
            Link(destination: SiteRoutes.home) {
                InlineText(siteName)
            }
            .style(TopNavigationBrandStyle())
            .attribute("aria-label", "\(siteName) home")
            .data("nav-brand", "true")

            Tag("div") {
                ForEach(NavigationItem.primary) { item in
                    ChromeButtonLink(
                        item.label,
                        destination: item.path,
                        markerName: "nav-item",
                        markerValue: item.id.rawValue,
                        isActive: selection.isActive(item)
                    )
                }
            }
            .style(TopNavigationLinksStyle())
            .data("nav-primary", "true")

            Tag("div") {
                EmptyHTML()
            }
            .style(TopNavigationActionsStyle())
            .data("nav-actions", "reserved")
        }
        .style(TopNavigationStyle())
        .data("top-navigation", "true")
    }
}
```

- [ ] **Step 5: Wire navigation through layout**

Modify `MainLayout`:

```swift
private var navigationSelection: NavigationSelection {
    NavigationSelection(path: page.url.path)
}
```

Change:

```swift
Navigation { TopNavigation().body }
```

to:

```swift
Navigation { TopNavigation(siteName: site.name, selection: navigationSelection).body }
```

- [ ] **Step 6: Run focused navigation tests**

Run:

```bash
swift test --filter SitePublishingTests/includesSharedNavigation
swift test --filter SitePublishingTests/topNavigationMarksActivePrimaryRoutes
```

Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add Sources/Components/Chrome/TopNavigation.swift Sources/Styles/Chrome/TopNavigationStyle.swift Sources/Layouts/MainLayout.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "feat: add branded top navigation"
```

## Task 4: Footer Chrome

**Files:**
- Modify: `Sources/Components/Chrome/PageFooter.swift`
- Create: `Sources/Styles/Chrome/PageFooterStyle.swift`
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Write failing footer assertions**

Add this test to `SitePublishingTests`:

```swift
@Test("shared footer renders site identity and publishing links")
func sharedFooterRendersSiteIdentityAndPublishingLinks() async throws {
    let harness = try await publishedSite()

    let homepage = try harness.contents(of: "index.html")
    let footer = try footerSlice(of: homepage)

    #expect(footer.contains("data-site-footer=\"true\""))
    #expect(footer.contains("Raptor Tsubame"))
    #expect(footer.contains("data-footer-link=\"rss\""))
    #expect(footer.contains("href=\"/rss.xml\""))
    #expect(footer.contains("data-footer-link=\"sitemap\""))
    #expect(footer.contains("href=\"/sitemap.xml\""))
    #expect(footer.contains("data-footer-link=\"raptor\""))
    #expect(footer.contains("href=\"https://raptor.build\""))
    #expect(footer.contains("page-footer-style"))
    #expect(footer.contains("page-footer-links-style"))
}
```

Add helper:

```swift
private func footerSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-site-footer=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let closeRange = try #require(html[marker.upperBound...].range(of: "</footer>"))
    return String(html[openStart.lowerBound..<closeRange.upperBound])
}
```

- [ ] **Step 2: Run the focused failing test**

Run:

```bash
swift test --filter SitePublishingTests/sharedFooterRendersSiteIdentityAndPublishingLinks
```

Expected: FAIL because the footer markers do not exist.

- [ ] **Step 3: Implement footer styles**

Create `Sources/Styles/Chrome/PageFooterStyle.swift`:

```swift
import Foundation
import Raptor

struct PageFooterStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.width(.percent(100)))
            .style(.maxWidth(.px(1120)))
            .style(.marginInline(nil))
            .style(.paddingBlock(.px(28)))
            .style(.paddingInline(.px(18)))
            .style(.textAlign(.center))
            .foregroundStyle(palette.mutedText)
            .border(palette.border, width: 1, style: .solid, edges: .top)
    }
}

struct PageFooterLinksStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.display(.flex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.gap(.px(12)))
            .style(.flexWrap(.wrap))
    }
}

struct PageFooterLinkStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.textDecoration(.none))
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(palette.accent)
    }
}
```

- [ ] **Step 4: Implement footer content**

Replace `Sources/Components/Chrome/PageFooter.swift` with:

```swift
import Foundation
import Raptor

struct PageFooter: HTML {
    let siteName: String
    let year: Int

    init(siteName: String, year: Int = Calendar.current.component(.year, from: Date())) {
        self.siteName = siteName
        self.year = year
    }

    var body: some HTML {
        Tag("div") {
            VStack(alignment: .center, spacing: 10) {
                Text("Copyright \(year) \(siteName). All Rights Reserved.")
                    .style(ChromeMutedTextStyle())
                    .data("footer-copyright", "true")

                Tag("div") {
                    footerLink("RSS", destination: "/rss.xml", marker: "rss")
                    footerLink("Sitemap", destination: "/sitemap.xml", marker: "sitemap")
                    footerLink("Raptor", destination: "https://raptor.build", marker: "raptor")
                }
                .style(PageFooterLinksStyle())
            }
        }
        .style(PageFooterStyle())
        .data("site-footer", "true")
    }

    private func footerLink(_ label: String, destination: String, marker: String) -> some HTML {
        Link(label, destination: destination)
            .style(PageFooterLinkStyle())
            .attribute("aria-label", label)
            .data("footer-link", marker)
    }
}
```

Modify `MainLayout` footer call:

```swift
Footer { PageFooter(siteName: site.name) }
```

- [ ] **Step 5: Run footer tests**

Run:

```bash
swift test --filter SitePublishingTests/sharedFooterRendersSiteIdentityAndPublishingLinks
swift test --filter SitePublishingTests/includesSharedNavigation
```

Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add Sources/Components/Chrome/PageFooter.swift Sources/Styles/Chrome/PageFooterStyle.swift Sources/Layouts/MainLayout.swift Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "feat: add site footer chrome"
```

## Task 5: Final Chrome CSS And Output Verification

**Files:**
- Modify only if verification exposes a real Stage 9 defect.

- [ ] **Step 1: Add focused shell CSS assertions**

Add this focused test to `SitePublishingTests`:

```swift
@Test("generated CSS includes top navigation and footer chrome")
func generatedCSSIncludesTopNavigationAndFooterChrome() async throws {
    let harness = try await publishedSite()
    let css = try harness.contents(of: "css/raptor-core.css")

    #expect(css.contains(".top-navigation-style"))
    #expect(css.contains(".top-navigation-brand-style"))
    #expect(css.contains(".top-navigation-links-style"))
    #expect(css.contains(".top-navigation-actions-style"))
    #expect(css.contains(".page-footer-style"))
    #expect(css.contains(".page-footer-links-style"))
    #expect(css.contains(".page-footer-link-style"))

    let navRule = try cssRule(in: css, containing: ".top-navigation-style")
    #expect(navRule.contains("rgb(251 253 255 / 100%)"))
    #expect(navRule.contains("rgb(200 221 242 / 100%)"))

    let footerRule = try cssRule(in: css, containing: ".page-footer-style")
    #expect(footerRule.contains("text-align: center;"))
    #expect(footerRule.contains("rgb(88 113 139 / 100%)"))

    try expectDarkBlueThemeRule(in: css, containing: ".top-navigation-style") { rule in
        #expect(rule.contains("rgb(11 23 38 / 100%)"))
        #expect(rule.contains("rgb(36 71 98 / 100%)"))
    }
}
```

Run:

```bash
swift test --filter SitePublishingTests/generatedCSSIncludesTopNavigationAndFooterChrome
```

Expected: PASS.

- [ ] **Step 2: Run full test suite**

Run:

```bash
swift test
```

Expected: PASS.

- [ ] **Step 3: Build the static site**

Run:

```bash
swift run RaptorTsubame
```

Expected: PASS. The existing Prism warning is acceptable if unchanged.

- [ ] **Step 4: Inspect generated chrome markers**

Run:

```bash
rg -n "data-top-navigation|data-nav-current|data-site-footer|data-footer-link" Build/index.html Build/2/index.html Build/archive/index.html Build/about/index.html Build/posts/welcome-to-tsubame/index.html Build/categories/tech/index.html Build/tags/swift/index.html
```

Expected:

- `Build/index.html` and `Build/2/index.html` show `data-nav-current="true"` on the Home link.
- `Build/archive/index.html` shows `data-nav-current="true"` on the Archive link.
- `Build/about/index.html` shows `data-nav-current="true"` on the About link.
- Post/category/tag pages render navigation and footer markers but no `data-nav-current`.

- [ ] **Step 5: Inspect generated CSS markers**

Run:

```bash
rg -n "top-navigation|page-footer|chrome-(surface|button-link|badge|section-title|icon-box|muted-text)" Build/css/raptor-core.css
```

Expected: CSS includes all top navigation, footer, and chrome primitive style families.

- [ ] **Step 6: Check git status**

Run:

```bash
git status --short
```

Expected: no unrelated dirty files. If generated `Build/` output is ignored, it should not appear.

- [ ] **Step 7: Commit any verification corrections**

Only run this commit after making concrete test or implementation corrections during Task 5:

```bash
git add Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift Sources/Components/Chrome Sources/Styles/Chrome Sources/Layouts/MainLayout.swift
git commit -m "fix: stabilize site chrome"
```

Do not create an empty commit.

## Self-Review Checklist

- [ ] Stage 9 stays static: no JavaScript menu, dropdown, search, theme switcher, hue picker, or page transition code.
- [ ] Navigation active state uses public `@Environment(\.page)` and project-owned route matching.
- [ ] Home, Archive, and About are the only primary active states.
- [ ] Post/category/tag routes do not incorrectly mark a primary nav link active.
- [ ] Footer has identity and publishing-link slots, but Stage 13 still owns RSS/sitemap verification.
- [ ] Primitive styles use existing `SiteThemePalette` tokens.
- [ ] Shared primitives are not tied to post cards, archive, taxonomy, or sidebar internals.
- [ ] Tests assert final emitted HTML/CSS markers, not just local component strings.
