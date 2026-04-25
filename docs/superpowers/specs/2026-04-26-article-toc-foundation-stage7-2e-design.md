# Article TOC Foundation Stage 7.2E Design

## Summary

Stage 7.2E adds an inline article table-of-contents foundation for Raptor Tsubame.

The goal is to make long articles easier to scan after Stage 7.2C/D stabilized Markdown typography and compatibility behavior. This stage should add heading anchors, generate a reusable article outline, and render a lightweight TOC inside the article content area.

This is not a sidebar migration stage. The implementation should keep the TOC data and TOC rendering portable so a later stage can move the rendered TOC into a sidebar or split layout without rewriting heading extraction.

## Current Context

The current article stack is:

- `ArticlePage` resolves taxonomy and adjacent posts, then renders `ArticleContent`.
- `ArticleContent` composes `ArticleHeader`, `ArticleBody`, and `ArticleNavigation`.
- `ArticleBody` wraps `MarkdownContent`.
- `MarkdownContent` delegates the rendered body to `post.text` and marks it with `data-markdown-content="true"`.
- Stage 7.2C owns scoped Markdown reading CSS in `Assets/css/markdown-reading.css`.
- Stage 7.2D documents current Raptor Markdown behavior and known upstream gaps.

The roadmap already lists heading anchors and optional TOC under Stage 7.2. This stage continues the article reading system rather than starting Stage 7.3 discovery work.

## Goals

- Generate stable anchor IDs for article body `h2` and `h3` headings.
- Render an inline TOC in the article main column when a post has enough outline entries.
- Keep TOC extraction independent from TOC placement.
- Preserve current Markdown compatibility guarantees, especially raw HTML/code escaping behavior from Stage 7.2D.
- Keep the first implementation readable in both light and dark themes using existing blue visual tokens.
- Provide route-level tests that prove anchors and TOC links appear in published output.

## Non-Goals

- No sticky TOC.
- No scroll spy or active section highlighting.
- No mobile collapse interaction.
- No JavaScript.
- No sidebar TOC migration in this stage.
- No per-post `toc` front matter switch.
- No Markdown renderer replacement.
- No workaround for the upstream multi-paragraph list item bug.
- No broad discovery features such as search, related posts, or archive redesign.

## Recommended Approach

Use an output-oriented outline pipeline:

1. Convert the article Markdown body into a TOC-ready HTML fragment through the same safe Markdown path used by articles.
2. Add IDs to supported heading elements in that fragment.
3. Extract an `ArticleOutline` from the same transformed fragment.
4. Render the transformed body and the TOC from that shared result.

This keeps TOC behavior aligned with real published HTML instead of trying to infer headings from raw Markdown. It also avoids relying on Raptor private parser internals.

If direct transformation of `post.text` is not practical with public Raptor APIs, the implementation may introduce a small project-level content helper that reuses the same `SafeMarkdownToHTML` behavior from source Markdown content. That helper must be tested against published output and must not fork Markdown semantics.

## Data Model

Add a small article outline model under the article/content layer, for example:

- `ArticleOutline`
- `ArticleOutlineItem`
- `ArticleHeadingLevel`

Each item should contain:

- `id`: stable anchor ID used by the rendered heading and TOC link.
- `title`: plain display text extracted from the heading.
- `level`: at least `.h2` and `.h3`.

IDs should be deterministic and slug-based:

- Lowercase ASCII where possible.
- Collapse whitespace and punctuation into single hyphens.
- Trim leading and trailing hyphens.
- Deduplicate repeated headings with numeric suffixes such as `heading`, `heading-2`, `heading-3`.
- If a heading cannot produce a useful slug, use a stable fallback such as `section-1`.

The slug algorithm should be local and tested. It should not depend on browser behavior or random values.

## Rendering Design

Add an `ArticleTOC` component that accepts an outline and renders nothing when the outline is empty or below the chosen threshold.

Recommended initial threshold:

- Render TOC when there are at least two outline items.
- Do not render for one heading, because a single-link TOC adds chrome without improving navigation.

Recommended inline placement:

- Inside `ArticleContent`, after `ArticleHeader` and before `ArticleBody`.
- Keep this placement behind a small composition boundary so a later stage can move `ArticleTOC` elsewhere.

Required markers:

- `data-article-toc="true"` on the TOC root.
- `data-article-toc-list="true"` on the list container.
- `data-article-toc-link="true"` on each link.
- `data-article-heading-anchor="true"` or equivalent on headings that receive IDs.

Avoid marker names such as `inline-toc`; the marker should describe the component, not its current placement.

## Visual Direction

The inline TOC should feel like a quiet reading aid, not a second navigation bar.

Recommended visual shape:

- Small card or inset block using existing article surface/token colors.
- Compact heading such as `Contents`.
- Links use the current blue accent, with subdued text color and readable hover/focus state.
- H3 entries may be visually indented, but avoid deep nesting beyond h3 in this stage.
- Mobile layout stays in normal article flow.

The CSS should live with the existing article/Markdown visual layer rather than introducing a separate layout system.

## Migration Path To Sidebar TOC

The future sidebar path should require moving composition, not rewriting extraction:

- `ArticleOutline` remains the data contract.
- `ArticleTOC` remains a standalone component.
- `ArticleContent` may pass outline data upward or into a future shell slot.
- Current neutral data markers remain valid after relocation.
- Inline styling should not assume the TOC is permanently inside the article body.

Do not modify the global site sidebar in Stage 7.2E. The existing sidebar already owns profile, category, and tag blocks. A right-side TOC needs a deliberate shell design later.

## Compatibility Notes

- Raptor consumes the first H1 as the article title when `removeTitleFromBody` is true. Stage 7.2E should treat body TOC headings as H2/H3 by default.
- Stage 7.2D intentionally records the current multi-paragraph list item bug. TOC work must not hide or work around it.
- Raw HTML outside code remains allowed for trusted content. HTML inside inline or fenced code must remain escaped.
- If heading extraction sees raw HTML inside a heading, the TOC title should use readable text only and avoid emitting unsafe HTML inside TOC links.

## Testing Strategy

Add focused tests before implementation:

- Slug generation handles punctuation, duplicate headings, empty slugs, and mixed case.
- Published article output includes heading IDs and matching TOC links.
- TOC does not render for articles with fewer than two body outline headings.
- TOC appears on a fixture with H2/H3 headings and preserves H3 hierarchy or indentation markers.
- Stage 7.2D compatibility lab still passes.
- Existing article page, Markdown reading, and full publishing tests still pass.

Verification commands:

- `swift test --filter ArticleOutline`
- `swift test --filter SitePublishingTests`
- `swift test --filter MarkdownCompatibilityPublishingTests`
- `swift test`
- `swift run RaptorTsubame`

## Acceptance Criteria

Stage 7.2E is complete when:

- Published article headings have stable IDs.
- A long article renders an inline TOC with links matching those heading IDs.
- Short articles without enough headings do not render empty TOC chrome.
- TOC data extraction is separated from TOC rendering.
- Existing sidebar shell remains unchanged.
- Existing Markdown compatibility audit tests still pass.
- The implementation is documented by tests and does not introduce JavaScript or a Markdown parser replacement.

## Risks

- Raptor may not expose a convenient public API for mutating rendered `post.text`. If so, the implementation should stop and choose the narrowest public-data approach instead of reaching into private Raptor internals.
- Duplicating Markdown conversion would be risky if it diverges from article rendering. Any source-based helper must share `SafeMarkdownToHTML` behavior and be validated against published output.
- Adding IDs to raw generated HTML can become brittle if done with broad string replacement. Heading transformation should be narrow and covered by tests.
