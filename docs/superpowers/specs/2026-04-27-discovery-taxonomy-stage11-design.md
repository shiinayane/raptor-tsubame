# Stage 11 Discovery And Taxonomy Framework Design

Date: 2026-04-27

## Purpose

Stage 11 upgrades archive, category, tag, and sidebar discovery surfaces. Stage 10 made the homepage feed and post cards useful browsing units; Stage 11 applies the same framework-level discipline to the site's discovery routes.

This is not final visual polish. The goal is to make discovery pages structurally complete, visually coherent, and testable before moving to article completion and publishing readiness.

## Scope

Stage 11 includes:

- Archive page upgraded from a plain grouped post list into a discovery surface.
- Category and tag index pages upgraded from plain link lists into structured taxonomy index surfaces.
- Category and tag detail pages upgraded with stable headers, counts, context, and post-list framing.
- Sidebar tag chips lose visible count badges while preserving accessible labels.
- Sidebar category rows keep counts but receive width/alignment treatment.
- Published HTML and CSS tests for archive, taxonomy, and sidebar discovery behavior.

Stage 11 does not include:

- Search.
- Archive filtering.
- JavaScript interactions.
- Right-side dynamic TOC.
- Article license/code-block/Prism work.
- About/profile/social identity work.
- Final visual polish.

## Raptor Markup Discipline

Stage 11 should continue the Stage 10 discipline:

- Use `Style` types for visual classes.
- Use `data-*` markers only for route-level surfaces, component boundaries, and meaningful state.
- Avoid leaf marker sprawl.
- Prefer existing post-card/feed components where they are the right abstraction.
- Add wrappers only when they represent a real discovery structure such as a year group, taxonomy index list, term card, or detail header.

## Fuwari Reference

Relevant Fuwari pieces:

- `Examples/fuwari/src/components/ArchivePanel.svelte`
- `Examples/fuwari/src/components/widget/Categories.astro`
- `Examples/fuwari/src/components/widget/Tags.astro`
- `Examples/fuwari/src/components/PostCard.astro`
- `Examples/fuwari/src/layouts/MainGridLayout.astro`

Alignment target:

- Archive is a browsable timeline-like surface, not just a stack of post cards.
- Taxonomy index pages communicate hierarchy, counts, and navigation clearly.
- Taxonomy detail pages explain the current term and then show matching posts.
- Sidebar tags are lightweight chips without visible counts.
- Sidebar categories remain count-bearing navigation rows.

Accepted divergence:

- Tsubame does not need Fuwari's exact DOM, classes, transitions, or JavaScript.
- Tsubame keeps the current left-sidebar shell.
- Tsubame can keep simple static archive/taxonomy behavior until content volume justifies filtering/search.

## Archive Design

Archive should render:

- `data-archive-page="true"` on the archive route content.
- `data-archive-year-group="true"` for each year group.
- `data-archive-entry="true"` for each archive row/card.
- Year heading, post date, post title link, optional description, and taxonomy hints where available.

Archive entries should not reuse full homepage cards if that makes the archive visually too dense. A compact archive entry component is preferred:

- Date becomes a visible chronological anchor.
- Title remains the main link.
- Description and taxonomy are secondary.
- The layout should be readable on mobile without horizontal timeline dependencies.

## Taxonomy Index Design

Category and tag index pages should render:

- `data-taxonomy-index="category"` or `data-taxonomy-index="tag"`.
- A page header with title and total term count.
- A list/grid of term cards using `data-taxonomy-index-item="category"` or `data-taxonomy-index-item="tag"`.
- Each term card should include name, link, count, and a short context label.

Categories and tags may share one component, but visible behavior should differ where needed:

- Category index count is useful and should be visible.
- Tag index count is also acceptable on the index page because it is a discovery page.
- Sidebar tag chips are the place where visible counts should be removed.

## Taxonomy Detail Design

Category and tag detail pages should render:

- `data-taxonomy-detail="category"` or `data-taxonomy-detail="tag"`.
- A stable detail header with term name and post count.
- A contextual label such as "Category" or "Tag".
- A post feed using Stage 10 post cards for matching posts.

Generated detail pages normally should not be empty, but the component model should still handle empty arrays without producing broken markup.

## Sidebar Finalization

Sidebar tag chips:

- Remove visible numeric count text from tag chips.
- Keep count in `aria-label`, e.g. `Raptor (2)`, so count information is not completely lost.
- Preserve active state markers and `aria-current`.
- Keep `data-sidebar-tag-chip` and `data-sidebar-term-slug`.

Sidebar category rows:

- Keep visible count badges.
- Tune width and alignment so category rows behave as full-width navigation rows inside the panel.
- Preserve active state markers and `aria-current`.

## Testing Strategy

Published HTML tests should cover:

- Archive route emits archive page/year/entry markers.
- Archive entries include date, title link, description, and taxonomy links for representative posts.
- Category index emits taxonomy index marker, term item markers, counts, and links.
- Tag index emits taxonomy index marker, term item markers, counts, and links.
- Category detail emits taxonomy detail marker, header count, and Stage 10 post-card feed.
- Tag detail emits taxonomy detail marker, header count, and Stage 10 post-card feed.
- Sidebar tags no longer show visible count badges in the tag cloud.
- Sidebar tag `aria-label` still includes counts.
- Sidebar categories still show visible count badges.

CSS tests should cover:

- Archive styles are generated.
- Taxonomy index/detail styles are generated.
- Sidebar category/tag finalization styles are generated.
- Light and dark token usage remains under `SiteThemePalette`.

## Acceptance Criteria

Stage 11 is complete when:

- Archive is a real discovery surface with grouped entries.
- Category and tag index pages have stable visual hierarchy.
- Category and tag detail pages have clear headers and post context.
- Sidebar tag visible counts are removed.
- Sidebar category row sizing/alignment is improved.
- Route-level output tests cover archive, taxonomy, and sidebar behavior.
- No search, JS filtering, or final visual polish is introduced.
