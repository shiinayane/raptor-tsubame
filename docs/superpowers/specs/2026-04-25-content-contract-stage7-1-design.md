# Content Contract Stage 7.1 Design

## Context

Stage 6 added article reading metadata and adjacent article navigation. Before adding more article features, Raptor Tsubame needs a stable front matter contract so future rendering, discovery, and SEO work do not grow ad hoc metadata parsing.

The Fuwari reference has a compact post schema:

- `title`
- `published`
- `updated`
- `draft`
- `description`
- `image`
- `tags`
- `category`
- `lang`
- internal adjacent-post fields: `prevTitle`, `prevSlug`, `nextTitle`, `nextSlug`

Raptor Tsubame already supports `kind`, `path`, `published`, `category`, and `tags` through `SiteContentMetadata`. Stage 7.1 should extend that contract deliberately without copying Astro implementation details.

## Goals

- Define a stable content metadata contract for posts and standalone Markdown pages.
- Align compatible field names with Fuwari where that improves migration clarity.
- Keep Raptor's existing public API semantics for publishing and post rendering.
- Centralize all custom front matter parsing in `SiteContentMetadata`.
- Add tests that protect defaults, normalization, and compatibility decisions.
- Preserve current route generation, taxonomy behavior, article navigation, and visual output unless a field is explicitly rendered.

## Non-Goals

- No series pages.
- No pinned or featured post system.
- No per-post table-of-contents control.
- No multilingual routing.
- No image optimization pipeline.
- No draft-field publishing switch in Stage 7.1.
- No replacement for Raptor's built-in `Post` fields such as title, date, description, word count, or reading time.
- No Fuwari internal adjacent-post front matter. Raptor Tsubame should keep dynamic adjacent navigation through `PostQueries.adjacentPosts`.

## Field Contract

### Existing Stable Fields

These fields remain supported:

- `kind`: `post` or `page`, defaulting to `post`.
- `path`: optional custom route for standalone pages.
- `published`: parsed with Raptor-compatible `Bool(rawValue) ?? true` semantics.
- `category`: optional single category name.
- `tags`: comma-separated tag list.

These fields remain owned by Raptor's built-in post model rather than duplicated in the custom metadata layer:

- `title`
- `date`
- `description`

### Stage 7.1 Core Additions

`image`

- Optional string.
- Uses the Fuwari field name rather than `cover`.
- Represents an article cover/banner image path.
- Empty or whitespace-only values are treated as absent.
- Stage 7.1 should parse and expose it, but rendering can wait for a later visual stage unless the next implementation plan explicitly includes a minimal visible use.

`updated`

- Optional front matter date string.
- Represents an author-controlled updated date, not filesystem modification time.
- Stage 7.1 should preserve the raw normalized value unless Raptor exposes a public date parser that can be used consistently.
- Empty or whitespace-only values are treated as absent.

`lang`

- Optional language marker.
- Uses Fuwari-compatible naming.
- Stage 7.1 should parse and expose it as a normalized non-empty string.
- It should not create multilingual routes or change HTML language output yet.

### Compatibility-Only Field

`draft`

- Fuwari uses `draft`; Raptor Tsubame currently uses `published`.
- Stage 7.1 should document this migration difference but should not make `draft` override publishing behavior.
- If later migration tooling is added, it can convert `draft: true` to `published: false`.

### Deferred Fields

`series`

- Useful for grouped technical writing, but Fuwari does not include it in its core schema.
- Defer until article reading and discovery needs justify it.

`pinned`

- Useful for homepage curation, but it changes discovery ranking rules.
- Defer until Stage 7.3 discovery work.

`toc`

- Fuwari controls TOC through site-level configuration and rendered headings, not post front matter.
- Defer per-post TOC until Stage 7.2 proves the article reading layout needs it.

## Architecture

Extend the existing content metadata layer rather than adding page-local parsing:

- `Sources/Content/SiteContentKind.swift` should include new metadata keys if implementation needs enum-backed lookup.
- `Sources/Content/SiteContentMetadata.swift` should expose optional `image`, `updated`, and `lang` properties.
- `Sources/Content/SiteContentLoader.swift` should carry these values only if preparation-time features need them.
- `Sources/Content/PostQueries.swift` should read these fields through `SiteContentMetadata(post.metadata)` when render-time components need them.

Do not add a separate `FrontMatter` parser for these fields. The current parser and `SiteContentMetadata` remain the project boundary.

## Rendering Strategy

Stage 7.1 is primarily a contract stage. Parsed fields do not automatically require UI:

- `image` has a future rendering location in article header/card visuals.
- `updated` has a future rendering location in article metadata.
- `lang` has a future rendering location in SEO and document language metadata.

No placeholder UI should appear just because a field exists. If implementation includes a visible use, it must be backed by a specific published HTML assertion.

## Testing

Add data-only tests for the metadata contract:

- `image` trims whitespace and defaults to `nil`.
- `updated` trims whitespace and defaults to `nil`.
- `lang` trims whitespace and defaults to `nil`.
- `draft` does not change `isPublished`.
- Existing `published`, `kind`, `path`, `category`, and `tags` behavior remains unchanged.

If implementation changes published output, add route-level assertions through `publishedSite()` rather than direct rendering calls.

Run:

```bash
swift test
```

If rendering is touched, also publish:

```bash
swift run RaptorTsubame
```

## Acceptance Criteria

- The content contract is documented with explicit Fuwari compatibility decisions.
- `image`, `updated`, and `lang` are the only Stage 7.1 core additions.
- `draft` is documented as compatibility-only and does not silently change publishing semantics.
- `series`, `pinned`, and per-post `toc` are deferred.
- Custom metadata parsing remains centralized in `SiteContentMetadata`.
- Tests protect parsing defaults and existing behavior.
- Existing site routes and visual output remain stable unless deliberately covered by new assertions.

## Residual Risks

- Raptor's built-in metadata parsing may already normalize some date fields differently than this project-level contract. Stage 7.1 should avoid private APIs and only rely on public `Post` values or custom raw metadata.
- `image` paths need a later decision on asset resolution and generated output paths.
- `draft` compatibility may surprise Fuwari users if they expect it to hide content automatically. Documentation should be explicit that `published` is the active field in this Raptor project.
