# Article TOC Visual Refinement Stage 7.2F Design

## Context

Stage 7.2E added the article outline pipeline, heading anchors, and an inline `ArticleTOC` component. That work intentionally prioritized data correctness and migration boundaries over visual polish. The current TOC is functional but too plain for the article reading surface.

Stage 7.2F refines the inline TOC using the selected visual direction: **A. Quiet Index**.

## Goal

Make the inline TOC feel like a quiet reading aid that belongs to the current blue article system, without turning it into a separate navigation feature.

## Non-Goals

- No sticky TOC.
- No right-sidebar TOC migration.
- No scroll-spy or JavaScript.
- No per-post `toc` front matter switch.
- No changes to outline extraction, heading slugging, or markdown preprocessing.
- No redesign of article shell, site sidebar, or post cards.

## Visual Direction

Use a restrained card with clear hierarchy:

- Compact uppercase label: `Contents`.
- H2 entries are the primary rhythm and carry a subtle blue left accent.
- H3 entries are indented and quieter.
- Link targets remain full-row readable, but without heavy button chrome.
- The card background should align with the existing page/surface palette and avoid reintroducing large background mismatch issues.

The TOC should read as part of the article body, not as a promotional card or a second site navigation.

## Component Contract

`ArticleTOC` remains a standalone component that accepts `ArticleOutline`.

Stage 7.2F should complete the published markup markers that were planned in Stage 7.2E:

- `data-article-toc="true"` on the root.
- `data-article-toc-title="true"` on the title.
- `data-article-toc-list="true"` on the ordered list.
- `data-article-toc-item="true"` on each list item.
- `data-article-toc-level="h2"` / `data-article-toc-level="h3"` on each list item.
- `data-article-toc-link="true"` on each link.

The markers describe the component, not its current inline placement, so the component remains movable later.

## Styling Contract

`ArticleTocStyle` should continue using public Raptor style APIs and `SiteThemePalette`.

The style should provide:

- A restrained surface with border and radius.
- Better spacing between title and list.
- List marker removal.
- H2/H3 hierarchy through indentation, text weight, and color.
- A small blue accent for H2 items.
- Matching dark-mode treatment using existing palette values.
- Mobile-friendly width and padding.

Avoid one-off global CSS when the behavior can be expressed through the component style. If nested selector support is insufficient in public Raptor APIs, add minimal stable data markers first and only then use scoped CSS through the existing article CSS path in a later stage.

## Testing

Published-output tests should cover:

- TOC root, list, item, link, title, and level markers.
- H2/H3 hierarchy markers in the markdown reading fixture.
- Generated CSS includes TOC styling and dark-mode coverage.
- Short articles still do not render TOC chrome.

Regression scope should stay on published HTML/CSS rather than private Raptor internals.

## Acceptance Criteria

- Long articles render a clearer inline TOC with visible H2/H3 hierarchy.
- Short articles remain free of empty TOC chrome.
- The component remains migration-ready for a future sidebar/sticky TOC stage.
- No JavaScript, sticky layout, sidebar shell change, or front matter switch is introduced.
