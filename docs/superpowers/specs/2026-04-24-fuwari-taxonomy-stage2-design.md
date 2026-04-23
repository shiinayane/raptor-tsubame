Date: 2026-04-24
Project: `raptor-tsubame`
Scope: Stage 2 taxonomy architecture for the Fuwari-inspired Raptor site

# Goal

Extend the Stage 1 site with first-class taxonomy support by introducing independent `category` and `tags` content metadata, taxonomy index pages, taxonomy detail pages, and taxonomy metadata display on article pages.

This stage stays focused on information architecture and content modeling. It does not yet attempt to recreate Fuwari's sidebar widget system or higher-density taxonomy UI.

# Core Principles

- Keep Markdown as the source of truth for long-form content and taxonomy metadata.
- Treat `category` and `tags` as independent content semantics, not as one overloaded field.
- Keep `category` single-valued and `tags` multi-valued.
- Continue to respect the existing `Tokens -> Styles -> Components -> Layouts -> Pages` boundary.
- Keep taxonomy aggregation in render-time query helpers, not in page bodies.
- Avoid introducing a second content-loading system for taxonomy pages.

# Relationship To Stage 1

Stage 1 established:

- homepage pagination
- post detail pages
- archive page
- Markdown-owned `/about/`
- shared top-level layout and navigation

Stage 2 adds taxonomy architecture on top of those foundations without replacing them.

The Stage 1 routes and publishing behavior remain valid and must not regress.

# Taxonomy Scope

Stage 2 introduces two taxonomy systems:

- `category`
- `tags`

Both are independent front matter fields and both publish dedicated routes.

## Field Semantics

### `category`

- optional
- single string value
- expresses the primary classification for a post
- only `kind: post` content participates

### `tags`

- optional
- multiple values
- expresses secondary or cross-cutting metadata
- only `kind: post` content participates

For this stage, `tags` should be authored as a comma-separated front matter string rather than a YAML array.

Example:

```yaml
category: Notes
tags: raptor, swift, design
```

## Participation Rules

Only content matching all of the following participates in taxonomy aggregation:

- `kind == post`
- `published != false`

The following must not participate:

- `kind: page`
- drafts
- standalone Markdown-backed pages such as `/about/`

# Routing Rules

Stage 2 adds four new public route groups:

- `/tags/`
- `/tags/<slug>/`
- `/categories/`
- `/categories/<slug>/`

## Tags

`/tags/`

- index of all used tags
- sorted by display name
- displays post count per tag

`/tags/<slug>/`

- lists all published posts using that tag
- posts sorted by descending date

## Categories

`/categories/`

- index of all used categories
- sorted by display name
- displays post count per category

`/categories/<slug>/`

- lists all published posts in that category
- posts sorted by descending date

## Slug Rules

Taxonomy detail routes use normalized slugs derived from authored values, but UI display uses the original human-authored text.

This means:

- URL paths use slug form
- page titles and link labels use original names

# Display Rules

Taxonomy metadata should be displayed in article detail pages only.

Stage 2 does not add taxonomy badges or labels to:

- homepage lists
- archive lists
- top-level navigation

## Article Page Behavior

Each article page should display:

- its category, if present
- its tags, if present

These should render as clickable links to their taxonomy detail pages.

If a post has no category or no tags, the corresponding UI should simply be omitted rather than replaced with placeholder text.

# Raptor Architecture

Stage 2 should extend the existing Stage 1 architecture rather than introducing a separate taxonomy subsystem.

## Content Layer

Continue using the existing content-query approach.

`SiteContentLoader`

- remains limited to `prepare()`-time lightweight scanning
- should not become the main taxonomy query engine

`PostQueries`

- remains the render-time aggregation entry point
- should be extended to provide taxonomy grouping and lookup helpers over real `Post` values from `@Environment(\.posts)`

Expected responsibilities added to the query layer:

- resolve category metadata for a post
- resolve tag metadata for a post
- group posts by category
- group posts by tag
- fetch posts for a given category
- fetch posts for a given tag
- generate stable slug/display representations for taxonomy terms

## Pages

Stage 2 should add these page types:

- `TagsIndexPage`
- `TagPage`
- `CategoriesIndexPage`
- `CategoryPage`

Responsibilities:

- index pages list taxonomy terms and counts
- detail pages list posts belonging to a selected term

Non-responsibilities:

- direct metadata parsing
- inline visual logic
- duplicating list rendering logic already handled by shared components

## Components

Stage 2 should add focused structural components for taxonomy presentation.

Recommended additions:

- `TaxonomyBadgeList`
- `TaxonomyIndexList`
- `TaxonomyIndexItem`
- `TaxonomyPostListHeader`

Responsibilities:

- render article-page taxonomy metadata
- render taxonomy index rows
- render taxonomy detail headers

Non-responsibilities:

- route computation
- querying posts
- deciding which taxonomy terms exist

## Existing Pages

Stage 2 should update:

- `ArticlePage`

To display taxonomy metadata.

Stage 2 should not change the Stage 1 behavior of:

- `HomePage`
- `ArchivePage`
- Markdown-owned `/about/`

# Navigation Rules

Top-level shared navigation remains unchanged in Stage 2:

- Home
- Archive
- About

`Tags` and `Categories` should be accessible via links from article metadata and direct route entry, but should not yet be promoted into the primary nav.

This preserves a clean top-level shell while taxonomy becomes part of the site architecture.

# Explicit Non-Goals

Stage 2 does not include:

- sidebar taxonomy widgets
- tag cloud presentation
- taxonomy pagination
- taxonomy search or combined filtering
- homepage taxonomy display
- archive taxonomy display
- hierarchical categories
- multi-valued categories
- taxonomy-specific SEO enhancement work

# Acceptance Criteria

Stage 2 is complete when all of the following are true:

- posts can declare a single `category` and multiple `tags` in front matter
- `/tags/` and `/categories/` publish complete taxonomy index pages with counts
- `/tags/<slug>/` and `/categories/<slug>/` publish post lists sorted by descending date
- article pages display category and tag metadata with working links
- pages and drafts are excluded from taxonomy aggregation
- Stage 1 routes and tests remain intact
- taxonomy implementation follows the existing query/components/pages boundaries rather than creating an ad hoc parallel system
