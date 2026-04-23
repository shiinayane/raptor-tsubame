Date: 2026-04-24
Project: `raptor-tsubame`
Scope: Stage 3 shell and sidebar architecture for the Fuwari-inspired Raptor site

# Goal

Stage 3 upgrades the site from a completed information architecture into a stable site shell inspired by Fuwari's outer structure.

The primary objective is to introduce a unified two-column layout across the site's major pages, with a persistent left sidebar and a main content region. This stage is about structural shell and browsing posture, not about reproducing Fuwari's full visual system or interaction density.

# Core Principles

- Preserve the Stage 1 and Stage 2 route and content architecture.
- Introduce a stable site shell rather than page-specific sidebar hacks.
- Keep the sidebar as part of layout composition, not page-specific content assembly.
- Reuse Stage 2 taxonomy aggregation for sidebar taxonomy blocks.
- Keep `Profile` separate from taxonomy-derived sidebar content.
- Continue respecting the existing `Tokens -> Styles -> Components -> Layouts -> Pages` boundary.

# Relationship To Previous Stages

Stage 1 established:

- homepage pagination
- post detail pages
- archive page
- Markdown-owned `/about/`
- shared top navigation and basic page shell

Stage 2 added:

- `category` and `tags` metadata
- taxonomy index/detail pages
- taxonomy metadata on article pages

Stage 3 does not introduce a new content model. It re-houses the existing pages inside a more complete outer shell and adds first-pass sidebar browsing structure.

# Stage 3 Site Surface

This stage keeps the existing public routes unchanged:

- `/`
- `/<page>/`
- `/posts/<slug>/`
- `/archive/`
- `/about/`
- `/tags/`
- `/tags/<slug>/`
- `/categories/`
- `/categories/<slug>/`

The change in this stage is structural presentation, not route expansion.

# Shell Direction

Stage 3 adopts a single stable shell for the main site experience:

- top navigation
- persistent left sidebar
- primary content area on the right

This is the recommended "balanced shell" direction. It most closely matches the intended Fuwari-like browsing posture while still fitting the current Raptor architecture.

The shell should apply consistently to all primary page types:

- homepage
- archive page
- taxonomy index pages
- taxonomy detail pages
- article pages
- about page

Stage 3 explicitly avoids splitting the site into separate layout families such as "homepage with sidebar, article without sidebar." The shell should be unified now so later stages can add refinements without re-breaking layout boundaries.

# Sidebar Scope

The Stage 3 sidebar includes exactly three blocks:

- `Profile`
- `Categories`
- `Tags`

It does not include:

- `Recent Posts`
- search
- TOC
- settings controls
- promotional banner blocks

The reason to exclude `Recent Posts` is structural clarity. The main content region already carries the site's primary content flow on homepage, archive, and taxonomy pages, so duplicating "recent content" in the sidebar would add noise rather than a new navigation affordance.

# Data Model And Content Sources

Stage 3 sidebar content comes from two different classes of source and should not be forced into one shared content system.

## Profile

`Profile` represents site identity, not content aggregation.

It should come from a lightweight site-level configuration source rather than from Markdown post content. First-pass profile content should include:

- site name
- short description
- optional avatar or graphic placeholder

This block is intentionally static in nature.

## Categories

`Categories` is taxonomy-driven and should reuse the Stage 2 query layer.

It should display:

- all published categories currently in use
- article count per category
- link to `/categories/<slug>/`

## Tags

`Tags` is also taxonomy-driven and should reuse the Stage 2 query layer.

It should display:

- all published tags currently in use
- article count per tag
- link to `/tags/<slug>/`

No special weighting, popularity ranking, or tag cloud behavior is part of Stage 3.

# Raptor Architecture

Stage 3 should extend the existing architecture rather than collapsing responsibilities into page bodies.

## Layouts

`MainLayout` should evolve into the real site shell for this stage.

Responsibilities:

- top navigation
- sidebar container region
- primary content container region
- desktop/mobile shell responsiveness

Non-responsibilities:

- querying posts directly
- deciding which taxonomy terms exist
- page-specific content selection

The sidebar is a layout concern, not a page concern.

## Components

Stage 3 should introduce focused sidebar components such as:

- `SidebarProfile`
- `SidebarCategories`
- `SidebarTags`
- `SidebarContainer`

Exact names may vary slightly if the existing codebase suggests a clearer naming scheme, but the separation of responsibilities should remain:

- one component for profile identity
- one component for category navigation
- one component for tag navigation
- one wrapper to compose the sidebar structure

These components should render given data. They should not perform route discovery or raw content loading.

## Content / Queries

`PostQueries` remains the query boundary for taxonomy-derived sidebar content.

Stage 3 may add sidebar-focused helpers if the current Stage 2 helpers are not ergonomic enough, but it should not introduce a second taxonomy loading system or move taxonomy logic into layout or page bodies.

Expected sidebar query needs are limited to:

- categories with counts
- tags with counts

## Pages

Stage 3 pages should continue owning only their main content region.

This includes:

- `HomePage`
- `ArchivePage`
- `TagsIndexPage`
- `TagPage`
- `CategoriesIndexPage`
- `CategoryTermPage`
- `ArticlePage`
- Markdown-owned `/about/`

They should not manually assemble sidebar sections.

# Responsive Behavior

Stage 3 must work for both desktop and mobile, but responsive behavior should remain pragmatic.

Desktop expectation:

- left sidebar visibly present
- main content area remains the dominant reading region

Mobile expectation:

- layout degrades cleanly into a stacked or simplified arrangement
- no broken overlap or unusable narrow columns

Stage 3 does not require animated drawer behavior or sophisticated mobile interactions. A clean, static responsive collapse is sufficient for this stage.

# Explicit Non-Goals

Stage 3 does not include:

- right-side TOC
- `Recent Posts`
- search
- collapsible sidebar interactions
- mobile drawer animation
- theme switching
- display settings panel
- banner or hero system
- previous/next article navigation
- one-to-one visual reproduction of Fuwari

# Acceptance Criteria

Stage 3 is complete when all of the following are true:

- all primary pages render within a stable unified shell:
  - homepage
  - archive
  - taxonomy pages
  - article pages
  - about page
- the left sidebar contains exactly:
  - `Profile`
  - `Categories`
  - `Tags`
- `Categories` and `Tags` are driven by real Stage 2 taxonomy aggregation
- page main-content responsibilities remain unchanged and page bodies do not assemble the sidebar themselves
- desktop and mobile both render acceptably, with mobile degrading cleanly instead of breaking
- Stage 1 and Stage 2 route behavior, about behavior, taxonomy behavior, and tests do not regress

# Implementation Notes

This stage is intentionally structural and should be treated as the site-shell counterpart to the earlier architecture work.

The most important design decision is not the exact visual treatment. It is preserving the architectural fact that:

- the sidebar belongs to layout
- profile belongs to site configuration
- categories and tags belong to taxonomy queries

If those boundaries remain intact, later stages can safely add richer widget styling, article-page enhancements, and stronger visual Fuwari influence without reworking the site's foundations.
