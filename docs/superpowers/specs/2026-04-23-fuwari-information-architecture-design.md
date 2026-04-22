# Fuwari-Inspired Information Architecture Design

Date: 2026-04-23
Project: `raptor-tsubame`
Scope: First-pass information architecture for a Raptor site inspired by `Examples/fuwari`

## Goal

Build the first pass of a Raptor-based site that takes structural inspiration from the `fuwari` Astro theme without copying its implementation or reproducing it one-to-one.

This phase is intentionally limited to information architecture. The goal is to establish the correct content model, routing model, and Raptor code boundaries so later visual and interaction work can be layered on cleanly.

## Core Principles

- Recreate intent, not Astro/Tailwind implementation details.
- Keep Markdown as the single source of long-form content.
- Treat homepage, archive, and article pages as different views over the same content set.
- Preserve strict separation of `Tokens -> Styles -> Components -> Layouts -> Pages`.
- Do not place visual logic in pages.
- Do not let components absorb content-loading or routing responsibilities.

## Source Reference

The design target is informed by `Examples/fuwari`, specifically its high-level site structure:

- paginated homepage
- individual post pages
- archive page
- standalone about page
- top-level navigation as the primary entry point

The following are explicitly not targets for this first pass:

- sidebar widget system
- profile card
- category/tag widgets
- right-side TOC
- search
- banner layout
- display settings panel
- Astro-style page transitions

## First-Pass Site Surface

The first pass publishes four user-facing routes:

- `/`
- `/<page>/` for pagination such as `/2/`, `/3/`
- `/posts/<slug>/`
- `/archive/`
- `/about/`

These routes form the minimum public structure required to match the intended content architecture.

## Content Model

All long-form content lives in `Posts/` as Markdown with front matter.

The system distinguishes content by purpose rather than folder-specific parsing logic. The first-pass content model introduces two semantic kinds:

- `post`
- `page`

The recommended front matter fields are:

- `title`
- `date`
- `description`
- `published`
- `path`
- `kind`

### Kind Semantics

`kind: post`

- eligible for homepage listing
- eligible for pagination
- eligible for archive listing
- generates an individual article page

`kind: page`

- not included in homepage pagination
- not included in archive listing
- used for standalone Markdown-backed pages
- first pass uses this only for the About page

### Publishing Rules

Homepage and archive include only content where:

- `kind == post`
- `published != false`

The About page is resolved from content where:

- `kind == page`
- `path == /about/`
- `published != false`

Any Markdown with `published: false` is excluded from all published outputs in the first pass.

## Routing Rules

### Homepage Pagination

The homepage is a paginated view over all published `post` content sorted by descending date.

Publishing rules:

- first page publishes at `/`
- subsequent pages publish at `/2/`, `/3/`, and so on

The homepage is not a separate content source. It is a projection over the `post` set.

### Post Pages

Each published `post` generates a canonical page at:

- `/posts/<slug>/`

The slug should come from the post path or normalized file-derived path, but the public URL must remain under `/posts/` for first-pass consistency.

### Archive Page

The archive publishes at:

- `/archive/`

It is a complete index over all published `post` content. Its purpose is navigational completeness rather than preview-heavy reading flow.

### About Page

The About page publishes at:

- `/about/`

It is backed by Markdown content, not hardcoded Swift content. Functionally it is a standalone `page` entry rendered through the common site structure.

## Raptor Architecture

The Raptor code structure should follow the framework boundaries rather than imitating Astro file organization.

### Layouts

First pass should define one main site layout:

- `SiteLayout`

Responsibilities:

- top navigation
- main content container
- footer
- shared page width and structural rhythm

Non-responsibilities:

- sidebar widgets
- TOC placement
- banner overlay logic
- page-specific aggregation

### Pages

The first pass should include the following page-level types:

- `HomePage`
- `ArchivePage`
- `AboutPage`

Responsibilities:

- select which content appears
- determine ordering and grouping
- compose reusable components

Non-responsibilities:

- inline visual styling
- raw property-level layout tuning
- Markdown parsing logic

### PostPage

Article pages should be represented by a dedicated `PostPage` type.

Responsibilities:

- article title
- article metadata
- article body container
- optional previous/next article navigation block

The article body must come directly from `post.text`. The page should not reimplement Markdown parsing.

### Components

First pass should keep components minimal and structural. Recommended reusable components:

- `TopNavigation`
- `PostList`
- `PostListItem`
- `PostMeta`
- `ArchiveList`
- `MarkdownContent`
- `PageFooter`

Responsibilities:

- reusable structure
- repeated composition
- stable markup boundaries for later styling work

Non-responsibilities:

- page-level routing decisions
- raw content discovery
- arbitrary visual decisions in component bodies

### Styles

Visual behavior should be gathered into semantic styles rather than scattered modifiers. First-pass style units may include:

- `PageCardStyle`
- `PostTitleStyle`
- `PostMetaStyle`
- `ArchiveGroupStyle`
- `NavButtonStyle`

These names are intentionally semantic. The exact style inventory may change during implementation, but the rule is fixed:

- no page-level visual logic
- no arbitrary property chains in pages
- no atomic style naming

## Data and Aggregation Rules

The site should expose one unified published post collection that supports three projections:

- homepage list
- archive list
- individual article lookup

The About page should be resolved separately from the same Markdown source set using the `kind: page` and `path: /about/` rule.

This keeps the content system unified while preserving route clarity.

## Non-Goals

This design explicitly excludes the following from first-pass implementation:

- recreating Fuwari's visual polish one-to-one
- matching Fuwari component names or Astro file structure
- banner-backed layout
- profile sidebar
- categories and tags widgets
- search integration
- TOC logic
- palette picker and display settings
- motion-heavy transitions

These may be added later, but they must not shape the first-pass architecture.

## Error Handling Expectations

First pass should fail clearly when required content is missing.

Expected failure cases:

- no published About page content exists for `/about/`
- malformed or missing required metadata prevents stable route generation

Preferred behavior:

- fail during build with explicit diagnostics
- do not silently publish partial or ambiguous route output

## Testing Expectations

Implementation should be validated against the architectural contract, not just rendered HTML existence.

Minimum verification targets:

- published `post` content appears on homepage pages in descending date order
- homepage pagination routes are generated correctly
- post detail pages publish under `/posts/<slug>/`
- archive page contains all published posts
- About page is rendered from Markdown content, not Swift-authored body text
- unpublished content is excluded from all outputs

## Acceptance Criteria

The first pass is complete only when all of the following are true:

- Markdown in `Posts/` generates stable article pages
- `/` and subsequent pagination pages list posts in descending date order
- `/archive/` exposes a complete post index
- `/about/` is driven by Markdown content
- code structure respects `Layouts / Pages / PostPage / Components / Styles` boundaries
- pages do not contain visual logic
- components do not own content parsing or route discovery

## Rationale

The point of this phase is not to make the site already look like Fuwari.

The point is to establish the same class of information architecture in a way that is natural for Raptor. If this phase is done correctly, future iterations can safely add:

- sidebar modules
- tag/category views
- TOC
- richer navigation
- banner layout
- Fuwari-adjacent visual language

without reworking the core content and routing model.
