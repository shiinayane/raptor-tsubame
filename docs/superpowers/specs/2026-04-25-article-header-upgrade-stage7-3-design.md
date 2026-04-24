# Article Header Upgrade Stage 7.3 Design

## Context

Stage 7.1 added a stable content metadata contract for `image`, `updated`, and `lang`. Stage 7.2A then split article pages into focused `ArticleContent`, `ArticleHeader`, and `ArticleBody` components with token-driven article surface styles.

Stage 7.3 should use that foundation to make the top of an article feel intentional. The direction is inspired by Fuwari's article header hierarchy, but should not copy its classes, layout implementation, or exact visual values.

## Goals

- Upgrade the article header into a clear reading entry point.
- Use existing metadata fields where they improve the header: `image`, `updated`, and `lang`.
- Preserve existing reading stats, date, category, tag, description, article body, adjacent navigation, shell, and sidebar behavior.
- Establish one reusable metadata item/icon-block pattern so icon block size, glyph scale, alignment, and text color stay consistent.
- Keep the visual direction aligned with the current pale blue light mode and deep blue dark mode.
- Add tests against published HTML and generated CSS instead of relying on component internals.

## Non-Goals

- No TOC.
- No heading anchors.
- No related posts.
- No series navigation.
- No archive, tag, or category page redesign.
- No search.
- No JavaScript.
- No Markdown parser replacement.
- No new route shape.
- No private Raptor CSS selector or build context API.

## Visual Direction

The article header should be stronger than the list-card header but still calm:

- Top reading stats row: low-density, muted, but readable.
- Title row: large high-contrast title with a small vertical blue accent bar on the leading edge.
- Metadata row: date, optional updated date, optional language, category, and tags as compact metadata items.
- Cover image: optional, only rendered when `image` exists.
- Cover caption/source: optional and only rendered when source metadata exists in a later contract stage; Stage 7.3 may reserve a component boundary but should not invent ad hoc front matter parsing for it.

The reference image uses compact square icon blocks with visible glyphs centered inside the block. The implementation should preserve that principle:

- Icon blocks should be compact, around the visual density of the reference image.
- Reading stat icon blocks and metadata icon blocks may share the same block size unless implementation proves a smaller stats block is cleaner.
- If different block sizes are used, glyphs must occupy a similar percentage of their block.
- Glyphs must be centered with a reusable layout rule such as flex/grid centering, not by relying on text baseline behavior.
- Title color should use a high-contrast text token.
- Stats and metadata text should use muted text tokens that remain readable in both light and dark mode.
- Icon foreground should use the accent token.
- Icon background should use a low-emphasis blue surface token, not raw gray.

## Metadata Contract

Stage 7.3 should use fields already present in `SiteContentMetadata` and avoid new parser paths.

Use now:

- `image`: render an optional cover image.
- `updated`: render an optional updated date metadata item.
- `lang`: render an optional language metadata item.

Continue using existing Raptor/Post values:

- `post.date`: publish date.
- `post.title`: title.
- `post.description`: description.
- `post.estimatedWordCount`: word count.
- `post.estimatedReadingMinutes`: reading time.
- taxonomy helpers: category and tags.

Do not add `coverSource` or similar front matter in this stage. If cover attribution becomes important, it should be a separate metadata-contract stage or a narrow Stage 7.3 follow-up.

## Architecture

Keep `ArticlePage` as a thin composition layer. Stage 7.3 should remain inside article header components and styles.

Expected component boundaries:

- `ArticleHeader`: owns the overall header order and decides which optional header subcomponents render.
- `ArticleTitleBlock`: owns the accent bar and title text.
- `ArticleMetadataItem`: reusable item with an icon block and label/content text.
- `ArticleMetadataRow`: owns publish date, updated date, language, category, and tags.
- `ArticleCover`: owns optional cover rendering and cover style marker.
- `ArticleReadingStats`: should either use `ArticleMetadataItem` or share the same icon-block style rules.

Expected style boundaries:

- `ArticleHeaderStyle`: overall header spacing and bottom separation.
- `ArticleTitleBlockStyle`: title row spacing, accent bar, and title text treatment if public Raptor APIs make this practical.
- `ArticleMetadataItemStyle`: icon block, glyph centering, text color, gap, and responsive wrapping.
- `ArticleCoverStyle`: cover dimensions, radius, object-fit behavior if supported, border, and dark-mode readability.

If Raptor's public image API is insufficient for the desired cover output, use `Tag("img")` with public attributes rather than private APIs. The output must include stable markers for tests.

## Responsive Behavior

Desktop:

- Header remains inside the current article surface and main column.
- Cover image should be wide and rounded, but must not push into the sidebar area.
- Metadata rows may wrap naturally rather than shrinking text aggressively.

Mobile:

- Content stays first; no side header or secondary panel.
- Title should scale down enough to avoid cramped line breaks.
- Metadata items should wrap to multiple rows cleanly.
- Cover should remain below metadata and above Markdown body.

## Testing

Add published-output tests that prove the header contract:

- Article header contains a title block marker.
- Article header contains reading stats metadata items with icon markers.
- Article header contains publish date metadata item.
- Article header renders optional updated metadata when present in front matter.
- Article header renders optional language metadata when present in front matter.
- Article header renders category and tags without breaking existing taxonomy links.
- Article header renders optional cover when `image` exists.
- Article header does not render cover markup when `image` is absent.
- Generated CSS includes article header metadata/icon/cover style class prefixes.
- CSS assertions cover light and dark token values for header metadata and cover surfaces.

Verification should include:

```bash
swift test
swift run RaptorTsubame
rg -n "data-article-title|data-article-meta-item|data-article-cover|article-metadata-item-style|article-cover-style" Build/posts/welcome-to-tsubame/index.html Build/css/raptor-core.css
```

## Acceptance Criteria

- `ArticleHeader` has a stronger hierarchy matching the approved Stage 7.3 direction.
- Header metadata uses one reusable icon-block pattern.
- Icons are visually centered in their blocks.
- Metadata text colors are theme-token based and readable in light and dark mode.
- Existing reading stats, date, description, category, and tag behavior remains intact.
- `image`, `updated`, and `lang` are used only through the existing content metadata contract.
- Cover rendering is optional and does not create broken placeholder UI.
- No new unrelated discovery or reading-system features are introduced.
- `swift test` passes.
- Published HTML and CSS checks pass.

## Residual Risks

- Raptor's current post-page style registration behavior may still require style seeding for article-only styles. If new article-only styles are added, the implementation must either reuse the existing seed pattern or otherwise prove generated CSS includes those classes.
- Icon glyph rendering can differ by system font. Implementation should prefer simple, stable symbols or a small internal label abstraction over visually fragile characters.
- Cover images may have very different aspect ratios. Stage 7.3 should choose one safe aspect-ratio treatment and leave advanced art direction for a later visual stage.
