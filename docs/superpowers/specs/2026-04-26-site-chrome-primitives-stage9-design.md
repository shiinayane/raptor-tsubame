# Stage 9 Site Chrome And UI Primitives Design

Date: 2026-04-26

## Purpose

Stage 9 completes the site's outer chrome foundation before the project upgrades post cards, archive pages, taxonomy pages, and identity pages. The current top navigation is only three bare links, and reusable UI primitives are still implicit in one-off `Style` types. This stage turns those into durable framework pieces.

This is a framework-completion stage, not final visual polish.

## Scope

Stage 9 includes:

- Branded top navigation.
- Primary navigation links for Home, Archive, and About.
- Current-page state for primary navigation.
- Responsive static navigation layout.
- Styled footer shell with copyright and stable publishing-link slots.
- Shared UI primitives for future stages:
  - chrome/card surface
  - button/link
  - badge
  - section title
  - icon box
  - muted metadata text
- Published HTML and CSS regression coverage.

Stage 9 does not include:

- Search.
- Theme switcher.
- Hue picker or display settings.
- JavaScript menu toggles.
- Dropdown menus.
- Page transitions.
- Banner system.
- Changes to post card content structure.
- Changes to archive, category, or tag page information architecture.
- Sidebar tag-count removal or category-width tuning. Those remain Stage 11 work.

## Fuwari Reference

Relevant Fuwari pieces:

- `Examples/fuwari/src/components/Navbar.astro`
- `Examples/fuwari/src/components/Footer.astro`
- `Examples/fuwari/src/components/control/ButtonLink.astro`
- `Examples/fuwari/src/components/control/ButtonTag.astro`
- `Examples/fuwari/src/components/widget/WidgetLayout.astro`
- `Examples/fuwari/src/layouts/MainGridLayout.astro`

The alignment target is structural:

- Fuwari has a clear top brand area; Tsubame should too.
- Fuwari's nav links are visually grouped and responsive; Tsubame should not leave them as bare anchors.
- Fuwari relies on repeated button/card/badge primitives; Tsubame should establish equivalent Swift/Raptor primitives before expanding page designs.

The alignment target is not one-to-one behavior:

- Fuwari has search, theme switch, display settings, mobile float panel, and page transition behavior. Tsubame does not add these in Stage 9.
- Tsubame should reserve future action slots where appropriate, but keep them inert/static in this stage.

## Navigation Design

The top navigation should become a site-level component with three conceptual zones:

- Brand: site name linking to `/`.
- Primary links: Home, Archive, About.
- Future actions slot: a static reserved region for later search/theme actions, initially empty or represented by non-interactive structure only if useful for layout tests.

Current page detection should use the same public Raptor boundary already proven in Stage 8:

```swift
@Environment(\.page) private var page
```

Navigation active state should be derived from `page.url.path` through project-owned logic, not by reading private Raptor rendering context.

Route matching should be conservative:

- `/` and paginated home routes such as `/2/` belong to Home.
- `/archive/` belongs to Archive.
- `/about/` belongs to About.
- Posts, categories, and tags do not need a primary nav active state unless a future route model deliberately groups them.

Responsive behavior:

- Desktop: brand left, primary links right or center-right.
- Mobile: brand remains visible; primary links wrap or compress into a simple static row.
- No JavaScript menu toggle in Stage 9.
- No hidden navigation that requires interaction to discover links.

Accessibility:

- Top navigation should have stable `data-top-navigation="true"` marker.
- Brand link should have an accessible label.
- Active primary link should emit `aria-current="page"` and a stable `data-nav-current="true"` marker.
- Inactive links must not emit active markers.

## Footer Design

The footer should become a real site chrome surface rather than a one-line "Built with Raptor" text.

Content:

- Copyright line using the current year and site/profile name.
- RSS link slot.
- Sitemap link slot.
- Powered-by Raptor link.

If RSS or sitemap output is not yet verified in the project, the footer may still reserve the links structurally, but Stage 13 remains responsible for publishing verification.

Markers:

- `data-site-footer="true"`
- `data-footer-link="rss"`
- `data-footer-link="sitemap"`
- `data-footer-link="raptor"`

Accessibility:

- Footer links should have clear labels.
- External links should be marked consistently if opening behavior is added later. Stage 9 should not add new-window behavior unless already used elsewhere.

## UI Primitive Layer

Stage 9 should introduce focused primitives that future stages can reuse without duplicating visual rules.

Recommended components:

- `ChromeSurface`: a general shell/chrome card wrapper.
- `ChromeButtonLink`: a reusable link styled as a button.
- `ChromeBadge`: a compact count/status badge.
- `ChromeSectionTitle`: a section title with accent treatment.
- `ChromeIconBox`: a fixed-size icon container for future icon usage.

Recommended styles:

- `ChromeSurfaceStyle`
- `ChromeButtonLinkStyle`
- `ChromeBadgeStyle`
- `ChromeSectionTitleStyle`
- `ChromeIconBoxStyle`
- `TopNavigationStyle`
- `TopNavigationBrandStyle`
- `TopNavigationLinksStyle`
- `TopNavigationLinkStyle`
- `PageFooterStyle`
- `PageFooterLinksStyle`

These names may be adjusted during implementation if a shorter naming scheme fits existing source organization better, but the boundaries should remain:

- top navigation styles do navigation layout only
- footer styles do footer layout only
- primitive styles are reusable and not tied to a specific page

Token policy:

- Use `SiteThemePalette`.
- Do not add new palette tokens unless implementation proves the current palette cannot express surface, raised surface, border, text, muted text, accent, and shadow states.
- Do not introduce page-local raw colors where existing palette roles work.

## Source Organization

Expected new or changed areas:

- `Sources/Components/Chrome/TopNavigation.swift`
- `Sources/Components/Chrome/PageFooter.swift`
- new components under `Sources/Components/Chrome/` for chrome primitives
- new styles under `Sources/Styles/Chrome/` or `Sources/Styles/Shell/`
- `Sources/Layouts/MainLayout.swift` only as needed to pass route selection and site identity
- publishing tests under `Tests/RaptorTsubameTests/Publishing/`

Prefer `Sources/Styles/Chrome/` if Stage 9 introduces enough chrome-specific style files. If implementation only needs one compact file, `Sources/Styles/Shell/ChromeStyle.swift` is acceptable.

## Testing Strategy

HTML tests should prove:

- Home, page two, archive, about, post, category, and tag pages all render the shared top navigation.
- Top navigation has brand, Home, Archive, and About links.
- Home active state appears on `/` and `/2/`.
- Archive active state appears on `/archive/`.
- About active state appears on `/about/`.
- Posts/categories/tags do not incorrectly mark Archive or About active.
- Footer renders outside `<main>`.
- Footer includes expected RSS, sitemap, and Raptor link markers.

CSS tests should prove:

- top navigation style classes are generated
- footer style classes are generated
- primitive style classes are generated
- generated rules include light palette values
- dark theme scoped rules include dark palette values
- no accidental `@media (min-width: 0px)` regression for chrome styles if the existing project tests enforce that pattern

Build/output verification should include:

```bash
swift test --filter SitePublishingTests/includesSharedNavigation
swift test --filter SitePublishingTests/generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint
swift test
swift run RaptorTsubame
rg -n "data-top-navigation|data-nav-current|data-site-footer|data-footer-link" Build/index.html Build/archive/index.html Build/about/index.html Build/posts/welcome-to-tsubame/index.html
```

## Acceptance Criteria

Stage 9 is complete when:

- Top navigation is no longer a set of bare links.
- Navigation includes site brand and primary links.
- Primary nav active state works on home, archive, and about.
- Mobile navigation remains fully accessible without JavaScript.
- Footer has stable identity and publishing-link slots.
- Shared chrome primitives exist for later stages.
- Published HTML and CSS tests cover the new chrome and primitives.
- Search, theme switcher, display settings, and JS menu behavior remain out of scope.
