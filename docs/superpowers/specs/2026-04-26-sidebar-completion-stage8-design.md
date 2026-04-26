# Sidebar Completion Stage 8 Design

## Context

The current sidebar is structurally present across the primary site shell. It already includes profile, categories, and tags, and it participates in the responsive shell layout. That means Stage 8 is not a first implementation of sidebar layout. It is a completion pass for information hierarchy, navigation clarity, and visual rhythm.

Stage 7.2E/F added an inline article TOC. Stage 8 should not immediately migrate that TOC into a right sidebar. The site should first make the existing left sidebar feel complete and intentional.

## Goal

Complete the existing left site sidebar as a stable browsing surface for identity and taxonomy navigation.

The sidebar should feel like a durable part of the site chrome, not a collection of plain links inside panels.

## Non-Goals

- No right-side TOC.
- No sticky sidebar.
- No three-column shell.
- No JavaScript interactions.
- No search.
- No recent posts block.
- No comments, analytics, or external widgets.
- No changes to article heading extraction or TOC generation.
- No new content model beyond small site-level sidebar configuration if needed.

## Direction

Use the current left sidebar and refine it.

The selected direction is:

**A. Complete the left site sidebar, keep article TOC inline.**

This preserves the current shell architecture and avoids making Stage 7.2F obsolete immediately after it landed. A future stage can still introduce a right-side TOC after the article shell itself is deliberately redesigned.

## Sidebar Content Model

The completed sidebar should have three durable areas:

1. Profile
2. Categories
3. Tags

### Profile

Profile remains site-level, not post-derived.

It should support:

- Site avatar text or avatar placeholder.
- Site name.
- Site description.
- Optional site links such as GitHub, RSS, or About.

If optional links are added, they should come from a small site-level structure rather than hard-coded inside the component. The first pass may ship without external links if the structure would over-expand the stage.

### Categories

Categories are primary browsing navigation.

They should render as compact navigation rows with:

- Name.
- Count.
- Link to category detail route.
- Current-route marker when the page belongs to that category route.

### Tags

Tags are secondary browsing navigation.

They should render as denser chips or compact links with:

- Name.
- Count.
- Link to tag detail route.
- Current-route marker when the page belongs to that tag route.

Tags should not visually compete with categories.

## Route Awareness

Stage 8 should introduce route-aware sidebar rendering if it can be done cleanly through public project data.

Minimum route awareness:

- `/categories/<slug>/` highlights the matching category.
- `/tags/<slug>/` highlights the matching tag.

Optional route awareness:

- Article pages may highlight their post category and tags if this can be done without pushing post-specific logic into `MainLayout`.

If article-page route awareness requires awkward coupling between layout and current post metadata, defer it. Category/tag detail route awareness is the core requirement.

## Component Boundaries

Keep the existing component family:

- `SidebarContainer`
- `SidebarProfile`
- `SidebarCategories`
- `SidebarTags`

Add small focused helpers only if they reduce duplication:

- `SidebarSectionTitle`
- `SidebarNavItem`
- `SidebarTagChip`

Do not create a generic all-purpose sidebar component that hides the difference between profile, categories, and tags. These blocks have different semantics and should remain readable.

## Styling Direction

The sidebar should follow the existing pale-blue light theme and deep-blue dark theme.

Visual refinements:

- Clear section labels.
- Better distinction between category rows and tag chips.
- Muted count badges.
- Subtle active state using the existing accent color.
- Consistent panel padding and internal spacing.
- Mobile layout remains below main content and should not become visually overwhelming.

The sidebar should stay quieter than the article body and main cards.

## Responsive Behavior

Keep the current shell behavior:

- Desktop: left sidebar, main content to the right.
- Mobile: sidebar appears after main content.

Stage 8 may refine mobile spacing and panel density, but should not introduce collapsible behavior.

## Testing

Published-output tests should cover:

- Sidebar profile still renders across home, article, about, taxonomy routes.
- Categories and tags keep their route links and counts.
- Category detail pages expose a current category marker.
- Tag detail pages expose a current tag marker.
- Generated CSS includes sidebar navigation/chip/active-state styles.
- Mobile/desktop shell marker ownership remains unchanged.

Tests should continue to assert published HTML/CSS rather than private Raptor internals.

## Acceptance Criteria

- The left sidebar feels visually complete and intentionally navigable.
- Category and tag sections are visually distinct.
- Category/tag detail routes expose current-state markers.
- The existing responsive shell remains intact.
- Article TOC remains inline.
- No right sidebar, sticky behavior, JavaScript, recent posts block, or search is introduced.
