# Fuwari Warm Visual Polish Stage 3.6 Design

## Context

Stage 3.5 made the shared shell structurally and responsively stable. The site now has a content-first DOM, a desktop-leading sidebar, a mobile content-first fallback, semantic shell styles, clear sidebar markers, and route-level publishing coverage.

The remaining gap is visual completion. The current pages still read as mostly raw Raptor stacks: links, post lists, page regions, and typography have correct structure but limited theme personality. Stage 3.6 turns the existing shell into a warmer editorial theme without adding new information architecture or interactive features.

The selected direction is **A. Warm Paper Editorial**: warm paper surfaces, soft brown accents, readable card rhythm, and a cozy content-site feeling. It references Fuwari's warmth and content-first mood, but it does not copy Fuwari's Astro components, Tailwind classes, exact colors, animation system, or UI layout.

## Goals

- Give the site a coherent warm editorial visual identity.
- Introduce a small reusable visual style layer for page background, cards, and text hierarchy.
- Make homepage, archive, taxonomy, and article list entries feel intentionally designed.
- Keep sidebar panel styling aligned with the new post/card treatment.
- Preserve Stage 3.5 shell behavior: content-first DOM, desktop visual-leading sidebar, mobile sidebar after content.
- Keep all changes inside Raptor's public API surface and existing source organization.

## Non-Goals

- No search UI.
- No table of contents.
- No theme switcher or color picker.
- No banner, hero image, or cover image system.
- No animation or page transition layer.
- No article previous/next navigation.
- No new content metadata fields.
- No route changes or content loader changes.
- No one-to-one clone of Fuwari.

## Visual Direction

Stage 3.6 should feel like a calm paper notebook rather than a dashboard:

- Background: warm off-white page with a subtle paper-like atmosphere.
- Surfaces: cards and panels use soft cream backgrounds, thin warm borders, and restrained shadows.
- Accent: muted brown/caramel for primary links and small emphasis.
- Typography hierarchy: titles should read more confidently than metadata, but the implementation should not introduce external fonts in this stage.
- Density: lists should breathe more than Stage 3.5, but should not become oversized landing-page cards.

The result should make the existing content feel curated and readable while staying simple enough for later feature stages.

## Architecture

Add a focused visual style group:

- `Sources/Styles/Visual/PageCanvasStyle.swift`
  Owns the site-wide warm page background and page-level padding behavior.
- `Sources/Styles/Visual/ContentSurfaceStyle.swift`
  Owns reusable warm card/surface treatment for content cards.
- `Sources/Styles/Visual/PostCardStyle.swift`
  Owns the list-item card treatment for posts.
- `Sources/Styles/Visual/MetadataTextStyle.swift`
  Owns quieter metadata text treatment.

Keep the existing shell style group:

- `Sources/Styles/Shell/SiteShellStyle.swift`
- `Sources/Styles/Shell/ShellMainStyle.swift`
- `Sources/Styles/Shell/ShellSidebarStyle.swift`
- `Sources/Styles/Shell/SidebarPanelStyle.swift`

Do not merge shell layout styles with visual theme styles. Shell styles answer "where does it go"; visual styles answer "how does this content surface feel."

## Component Changes

`MainLayout` should apply the page-level visual atmosphere outside the existing shell structure. It should not take over post card styling or page-specific decisions.

`PostListItem` should become the main warm editorial card:

- title link remains the primary action
- metadata remains below title
- description remains visible when present
- card treatment applies to the entire list item
- no new fields or thumbnails are introduced

`PostMeta` should receive metadata text treatment so dates and descriptions are visually quieter than titles.

`PostList`, `ArchiveList`, and taxonomy pages should benefit from `PostListItem` automatically rather than each implementing separate card rules.

Sidebar components should keep their Stage 3.5 structure and `SidebarPanelStyle`, but the panel palette can be adjusted to match the warm editorial direction.

## Responsive Behavior

The Stage 3.5 responsive model remains unchanged:

- Base and compact output are mobile-first.
- Regular and expanded width classes restore desktop shell behavior.
- Main content remains before sidebar in DOM.
- Sidebar appears visually leading on desktop through CSS ordering.
- Sidebar appears below main content on narrow screens.

Any new visual style with breakpoint behavior must follow the Raptor rule learned in Stage 3.5: base `.none` and `.compact` should represent compact/mobile output, and desktop-specific styles should apply at `.regular` and `.expanded`.

## Testing

Existing publishing tests should continue to cover:

- homepage
- archive
- about
- article page
- tag index/detail
- category index/detail
- generated responsive shell CSS

Stage 3.6 should add or extend tests for:

- published HTML includes the new post card style class on homepage and archive post entries
- published HTML includes metadata style class inside post metadata blocks
- generated CSS includes warm visual style classes and key properties such as warm backgrounds, borders, shadows, and desktop breakpoint rules where applicable
- no new `@media (min-width: 0px)` override appears for visual styles that would break mobile-first behavior

Run:

```bash
swift test
```

Publish and inspect generated output:

```bash
swift run RaptorTsubame
rg -n "post-card-style|metadata-text-style|content-surface-style|page-canvas-style|sidebar-panel-style" Build/index.html Build/archive/index.html Build/css/raptor-core.css
```

## Acceptance Criteria

- The site has a clear warm editorial visual direction.
- `MainLayout` still preserves Stage 3.5 shell semantics and marker ownership.
- Post list entries render as warm editorial cards across home, archive, and taxonomy-derived lists.
- Post metadata has a quieter visual hierarchy than post titles.
- Sidebar panels visually align with the warm card system.
- Generated CSS proves the new style types are emitted.
- Responsive CSS remains mobile-first and does not reintroduce `min-width: 0px` overrides for desktop behavior.
- `swift test` passes.
- `swift run RaptorTsubame` publishes successfully.

## Residual Risks

- Browser visual judgment remains subjective; generated HTML and CSS tests prove structure and emitted styles, not pixel-perfect aesthetics.
- Without external fonts, the theme's typography remains constrained by Raptor's existing font stack.
- Warm colors may need one follow-up tuning pass after viewing in the browser.
- Raptor's generated CSS may duplicate style blocks across pages; Stage 3.6 should not attempt to solve CSS de-duplication.
