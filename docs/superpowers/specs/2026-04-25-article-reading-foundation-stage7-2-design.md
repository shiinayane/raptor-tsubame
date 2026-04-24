# Article Reading Foundation Stage 7.2A Design

## Context

Stage 6 added article reading stats and adjacent article navigation. Stage 7.1 then stabilized the content metadata contract with Fuwari-aligned `image`, `updated`, and `lang` fields, while keeping `draft` compatibility-only.

Stage 7.2 should now improve the article reading experience, but it should not expand into cover rendering, table of contents, heading anchors, related posts, series navigation, or search. The chosen direction is **A. Typography Foundation**, with the structure kept extensible enough to support later B/C stages.

## Goals

- Make article pages feel like intentional reading pages rather than raw Markdown output.
- Preserve the existing site shell, sidebar behavior, route structure, taxonomy badges, reading stats, and adjacent navigation.
- Add stable article-level structure and markers that future stages can extend.
- Improve spacing, rhythm, line length, and surface treatment through public Raptor APIs.
- Keep Markdown rendering delegated to Raptor's `post.text`.
- Avoid private Raptor APIs or brittle CSS injection for descendant selectors that are not publicly supported.

## Non-Goals

- No cover image rendering.
- No visible `updated` or `lang` metadata UI.
- No table of contents.
- No heading anchors.
- No related posts or series navigation.
- No search or discovery changes.
- No JavaScript interaction.
- No replacement of Raptor's Markdown parser.
- No route changes.
- No sidebar layout changes.

## Raptor API Boundary

Raptor's `post.text` renders a `PostText` element as a `section` with the `markdown` class. This gives the project a stable Markdown output anchor.

Current public `Style` usage in this project is strongest for styling the element receiving the style class. Raptor's internal CSS generator has selector support, but the project should not depend on package-private selector APIs for arbitrary descendant rules.

Stage 7.2A should therefore split the work into two layers:

- Article structure and container styling that public Raptor APIs support now.
- Future Markdown-descendant styling hooks that are documented and marked in HTML, but not forced through private APIs.

If implementation discovers a public Raptor API for safe descendant styling, it may use it with tests. Otherwise, Stage 7.2A should stop at stable wrappers, markers, spacing, and container-level typography.

## Architecture

Add focused article components under the existing posts component area:

- `ArticleContent`: owns the article page body structure.
- `ArticleHeader`: owns title, metadata, reading stats, and taxonomy badges.
- `ArticleBody`: owns the Markdown content wrapper.

Keep `ArticlePage` small:

- It should gather `category`, `tags`, and `adjacentPosts`.
- It should render `ArticleContent`.
- It should not become the owner of article layout details.

Keep `MarkdownContent` as the Raptor Markdown boundary:

- It should continue to render `post.text`.
- It should gain a stable marker such as `data-markdown-content`.
- It should be wrapped by `ArticleBody`, not replaced.

Add visual styles under `Sources/Styles/Visual`:

- `ArticleSurfaceStyle`: article page card/surface spacing, border, shadow, and color tokens.
- `ArticleHeaderStyle`: title/header rhythm and separation from Markdown body.
- `ArticleBodyStyle`: readable line height, max width behavior, and body text color.

These styles should use `SiteThemePalette.resolve(for:)` and the existing light/dark token direction.

## Extensibility

Stage 7.2A should leave clear landing points for later work:

- B. Article Header Upgrade can add `image`, `updated`, and `lang` display inside `ArticleHeader`.
- C. Full Reading System can add heading anchors, TOC, or related/series blocks without rewriting `ArticlePage`.
- If a future TOC is added, it should not fight the existing sidebar shell. It should either live inside the main article flow or be introduced only after a deliberate shell/outline design.

Stable markers should support these future additions:

- `data-article-page`
- `data-article-header`
- `data-article-body`
- `data-markdown-content`

## Visual Direction

The article should remain content-first and aligned with the existing Fuwari-ish air-blue / midnight-blue theme:

- The article surface should feel slightly more intentional than list cards.
- The title and metadata should have clearer hierarchy.
- The Markdown body should have more comfortable reading rhythm.
- Mobile should remain single-column and content-first.
- Desktop should stay inside the current main column width and not push against the sidebar.

Do not copy Fuwari's Tailwind classes or exact styles. Use the same mood: calm blue surfaces, readable spacing, and restrained accents.

## Testing

Add published-output tests rather than direct component body tests when verifying Raptor-rendered article structure.

Tests should prove:

- Article pages include `data-article-page`.
- Article header includes title, metadata, reading stats, and taxonomy badges.
- Article body includes `data-article-body`.
- Markdown content includes `data-markdown-content` and still renders existing Markdown body content.
- Generated CSS includes the new article style class prefixes.
- Generated CSS includes light and dark token-dependent rules for article styles if those styles use `EnvironmentConditions.colorScheme`.
- Existing shell/sidebar tests remain valid.

Run:

```bash
swift test
```

Publish and inspect generated output if article rendering or CSS output changes:

```bash
swift run RaptorTsubame
rg -n "data-article-page|data-article-header|data-article-body|data-markdown-content|article-surface-style|article-header-style|article-body-style" Build/posts/welcome/index.html Build/css/raptor-core.css
```

## Acceptance Criteria

- Article page structure is split into focused components.
- `ArticlePage` remains a thin page composition layer.
- Markdown rendering still uses Raptor `post.text`.
- Stable article markers exist in published article HTML.
- Article styles use existing theme tokens and public Raptor style APIs.
- No cover image, TOC, heading anchor, related post, series, search, route, or sidebar behavior is introduced.
- Tests cover published article structure and generated style output.
- `swift test` passes.

## Residual Risks

- Deep styling for Markdown descendants may require public API support that is not currently available. Stage 7.2A should avoid private selector APIs and keep descendant-level polish for a later explicit design if needed.
- Without descendant styling, code blocks, tables, and blockquotes may only partially improve in this stage. The structural markers still make the next typography pass safer.
- Visual tuning may need a browser QA pass after implementation, especially for mobile line rhythm and dark-mode contrast.
