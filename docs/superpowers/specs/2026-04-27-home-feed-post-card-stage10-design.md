# Stage 10 Home Feed And Post Card Framework Design

Date: 2026-04-27

## Purpose

Stage 10 upgrades the homepage and paginated post-list surfaces from simple link lists into a durable home feed and post card framework.

This stage also records an architectural concern raised during review: the project now contains many wrapper elements, generated style classes, and `data-*` markers. The stage must not continue by blindly adding more `Div`, `class`, and marker layers. Raptor Tsubame should preserve Raptor's declarative component intent: Swift components describe semantic site structure, `Style` types own visual rules, and raw HTML/class escape hatches remain limited to renderer boundaries.

Stage 10 is therefore both a feed/card upgrade and a semantic markup discipline pass for the post-list area.

## Scope

Stage 10 includes:

- A semantic audit of home feed and post card markup before visual expansion.
- A documented distinction between semantic structure, Raptor-generated style classes, and stable `data-*` test hooks.
- A richer post card structure for homepage and paginated home routes.
- Category and tag links on post cards where metadata exists.
- Date, description or excerpt, and reading stats on post cards.
- Optional cover thumbnail support when `image` metadata exists.
- Pagination controls using the shared chrome/button visual language.
- Published HTML and CSS tests for home page and page-two output.

Stage 10 does not include:

- Archive timeline redesign.
- Category and tag index/detail redesign.
- Sidebar tag-count removal or category-width tuning.
- Search.
- JavaScript-driven card interactions.
- Final visual polish.
- A global rewrite of every `Div` in the project.

## Raptor Markup Discipline

The goal is not "no divs". HTML needs wrappers for layout, especially cards and responsive feed rows. The goal is that each wrapper has a clear responsibility.

Allowed:

- Raptor `Style` types that generate CSS classes through `.style(...)`.
- Semantic HTML elements when the framework exposes a suitable primitive.
- `Div` or stack layout components when they represent a real layout grouping.
- `data-*` markers on component boundaries and important state boundaries used by tests or scoped CSS.
- One wrapper around rendered Markdown HTML, because Markdown output is already an HTML string boundary.

Discouraged:

- `Div` wrappers that exist only because a visual tweak was convenient.
- Hand-authored CSS class names that bypass the Raptor `Style` system.
- `data-*` markers on every internal leaf node.
- Tests that assert incidental generated class names when a semantic marker or route-level output would be more stable.
- Page-local colors or inline CSS when a `Style` and `SiteThemePalette` role can express the same rule.

Stage 10 should add a small project doc or extend an existing code-quality doc so future stages can apply the same rules.

## Fuwari Reference

Relevant Fuwari areas:

- `Examples/fuwari/src/components/PostCard.astro`
- `Examples/fuwari/src/components/PostMeta.astro`
- `Examples/fuwari/src/components/FormattedDate.astro`
- `Examples/fuwari/src/pages/page/[page].astro`
- `Examples/fuwari/src/components/control/ButtonLink.astro`

Alignment target:

- Post cards are the primary browsing unit.
- Metadata is visible without making the card noisy.
- Cover/no-cover layouts both feel intentional.
- Pagination uses the same visual language as card and button primitives.

Accepted divergence:

- Tsubame should not copy Fuwari's exact DOM, class names, animation utilities, or Astro/Svelte-specific structure.
- Tsubame should keep the left-sidebar shell and current Raptor component organization.
- Tsubame can keep a simpler motion policy until the framework-completion track is done.

## Home Feed Design

The home feed should have a clear container boundary:

- `data-home-feed="true"` on the feed region.
- `data-post-card="true"` on each post card.
- `data-post-card-cover="true"` only when a card renders cover media.
- `data-post-card-taxonomy="true"` on the taxonomy row if category or tags exist.
- `data-post-card-stats="true"` on the reading-stats row.

These markers should be boundary markers. They should not be added to every span or small internal node.

Card content priority:

1. Title link.
2. Date and optional reading stats.
3. Description or excerpt.
4. Category and tags.
5. Optional cover thumbnail.

Responsive behavior:

- No-cover cards remain single-column.
- Cover cards may use a two-column treatment on wider screens.
- Mobile cards should stack with text first or cover first only if the visual result is clearly better. Avoid cramped side-by-side thumbnails on mobile.

## Pagination Design

Pagination should move away from plain text links and use Stage 9 chrome primitives.

Requirements:

- Keep existing route behavior.
- Render "Newer" and "Older" links only when available.
- Keep page number context.
- Use stable markers such as `data-pagination="true"` and `data-pagination-link="older"`.
- Avoid JS or client-side state.

## Testing Strategy

Component/model tests should cover:

- Reading stat formatting used by post cards.
- Post card view model or helper behavior if one is introduced.
- Pagination link availability remains unchanged.

Published output tests should cover:

- Homepage renders a feed boundary and the expected number of post cards.
- Page two renders the same feed/card structure.
- Cards include title, date, description, reading stats, and taxonomy where metadata exists.
- Cards with cover metadata render a cover boundary and image/link output.
- Cards without cover metadata do not render empty cover shells.
- Pagination emits stable markers and button-like links.
- Tests use semantic `data-*` boundary markers rather than incidental generated class names unless verifying CSS generation specifically.

CSS tests should cover:

- Post card style classes are generated.
- Feed style classes are generated.
- Cover/no-cover layout rules exist.
- Pagination reuses or aligns with chrome button/link visual language.
- Light and dark palette values come from `SiteThemePalette`.

## Acceptance Criteria

Stage 10 is complete when:

- The Raptor markup discipline concern is documented.
- Home and paginated feed routes use a deliberate feed/card structure.
- Post cards expose metadata, taxonomy, description/excerpt, reading stats, and optional cover output.
- Pagination visually aligns with Stage 9 chrome primitives.
- Unnecessary new wrappers and marker sprawl are avoided.
- Published HTML/CSS tests cover the new feed/card framework.
- Archive/discovery/sidebar finalization remains Stage 11.
