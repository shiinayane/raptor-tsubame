# Project Roadmap

Raptor Tsubame should grow as a technical blog first, with personal-site identity and visual expression treated as deliberate supporting layers. The project should not expand by adding isolated features one at a time. Each stage must strengthen the content model, reading experience, discovery flow, or site identity while preserving the existing Raptor architecture boundaries.

## Direction

Primary direction:

- A personal technical blog.
- Strong reading experience for posts, code, archives, categories, and tags.
- Stable content metadata before higher-level features depend on it.

Secondary direction:

- A personal homepage layer.
- Profile, about, project, and identity surfaces that support the blog rather than replacing it.

Visual direction:

- Visual expression is not a final polish phase.
- Every stage should include a visual acceptance target.
- Visual work should continue through tokens, styles, components, layouts, and pages instead of page-local styling.
- The site should keep the current soft blue light mode and deep blue dark mode direction unless a future stage deliberately revises the theme system.

## Expansion Rules

- Add content metadata only through a stable contract, not ad hoc per feature.
- Keep Markdown front matter parsing centralized through the content metadata layer.
- Keep render-time content queries in `PostQueries` or focused query helpers.
- Keep visual rules in `Style` types unless the code is only small layout glue.
- Keep published HTML and CSS assertions for route, shell, theme, and article-reading behavior.
- Avoid introducing JavaScript-driven interaction until the static content model is stable.

## Stage 7.1 Content Contract

Goal: define the long-term front matter contract before adding more article features.

Candidate fields:

- `image`: optional article cover image path, aligned with Fuwari front matter.
- `updated`: optional deterministic updated date from front matter.
- `lang`: optional content language marker if multilingual content becomes real.
- `draft`: documented only as a Fuwari migration input; Raptor-facing publishing should keep using `published`.
- `series`, `pinned`, and per-post `toc`: deferred extension candidates, not Stage 7.1 core fields.

Initial implementation should be conservative:

- Document all candidate fields.
- Implement only Fuwari-aligned fields needed by the next stage.
- Add tests proving parsing defaults and invalid values.
- Keep existing `kind`, `path`, `category`, `tags`, and `published` behavior stable.

Visual acceptance:

- No raw display is required for all fields.
- Any implemented field must have a clear future rendering location.
- No placeholder UI should appear just because a field exists.

## Stage 7.2 Article Reading System

Goal: make article pages feel like complete reading pages rather than raw Markdown output.

Potential work:

- Markdown typography for headings, paragraphs, lists, blockquotes, and tables.
- Code block and inline code styling.
- Heading anchors and optional TOC.
- Article bottom area: adjacent navigation, related posts, or series navigation.
- Stable reading metadata.

Visual acceptance:

- Article content should have a readable vertical rhythm.
- Code and prose should remain readable in both light and dark modes.
- TOC or related-content UI must not fight the existing sidebar shell.
- Mobile reading should keep content first and avoid cramped side panels.

## Stage 7.3 Discovery System

Goal: help readers find content after the post count grows.

Potential work:

- Archive grouping improvements.
- Tag and category page hierarchy.
- Search, only after content metadata and route structure are stable.
- Optional pinned or featured content if the content contract supports it.

Visual acceptance:

- Discovery pages should not be simple link dumps.
- Counts, descriptions, and metadata should build clear information hierarchy.
- Search UI, if added, should degrade safely and not become a JavaScript-first dependency.

## Stage 7.4 Site Identity

Goal: expand personal-site surfaces without losing the technical-blog center.

Potential work:

- Stronger profile/sidebar content.
- About page structure.
- Project page or project cards.
- Optional links/friends page.

Visual acceptance:

- Identity pages may be more expressive than post lists.
- They should still use the same tokens and shell language.
- Personal branding should not require a separate layout family unless there is a clear route-level reason.

## Stage 7.5 Production Readiness

Goal: make the site trustworthy to publish and maintain.

Potential work:

- SEO metadata.
- RSS/feed verification.
- Sitemap and robots verification.
- Accessibility checks.
- Build and route validation.
- Deployment documentation.

Visual acceptance:

- Production polish should not introduce visible regressions.
- Accessibility and responsive behavior should be verified alongside HTML output.
- The generated site should remain inspectable through published artifacts and local preview.

## Framework Completion Track

The site should not move into fine visual refinement until the remaining Fuwari-aligned framework surfaces are complete. The detailed comparison is recorded in `docs/fuwari-framework-gap-analysis.md`.

The framework-completion stages are:

- Stage 9: Site Chrome And UI Primitives. Complete the top navigation, footer shell, route-aware primary nav, mobile nav behavior, and shared card/button/badge/section-title primitives.
- Stage 10: Home Feed And Post Card Framework. Upgrade homepage and paginated post lists with richer post cards, metadata, taxonomy links, descriptions or excerpts, reading stats, optional covers, and stronger pagination.
- Stage 11: Discovery And Taxonomy Framework. Upgrade archive, category, and tag pages into real discovery surfaces, then finalize sidebar taxonomy behavior.
- Stage 12: Article Completion And Markdown Infrastructure. Finish article peripherals, code-block behavior, Prism warning handling, license or ownership block policy, structured metadata, and Markdown extension policy.
- Stage 13: Identity And Publishing Readiness. Complete profile/avatar/social-link modeling, about page structure, footer publishing links, RSS/sitemap/robots/favicon/SEO verification, and final framework acceptance checks.

After Stage 13, the site framework should be considered complete enough for a separate fine visual refinement track. Search, user-facing theme switcher, hue picker, page transitions, banner system, comments, full i18n, and right-side dynamic TOC remain post-framework enhancements unless deliberately promoted later.

## Deferred Visual Notes

These notes are accepted follow-up observations, but should not be implemented until the broader base framework is complete enough to batch visual refinements safely.

- Sidebar tags should not show counts. Tags are a lightweight browsing affordance, and count badges add unnecessary density.
- Sidebar category rows need a width/layout pass. The current category treatment works structurally, but the row width and alignment should be tuned together with the later sidebar visual pass.
- Stage 10 should include a semantic markup discipline checkpoint. The project should not keep adding wrapper `Div`s, generated/hand-authored classes, or `data-*` markers without a clear structural reason. Raptor-generated `Style` classes are acceptable; arbitrary class escape hatches and marker sprawl should be avoided.

## Current Recommendation

Stage 7.1 is complete as the conservative content contract foundation.
Stage 7.2 is complete enough for the current framework track: article structure, header/cover, typography compatibility work, inline TOC foundation, and TOC visual refinement are in place.
Stage 8 is complete as the left sidebar framework: profile, categories, tags, route-aware active states, and sidebar navigation styling are in place.
Stage 9 is complete enough as the site chrome and UI primitive foundation: top navigation, footer, route-aware primary links, and shared chrome primitives are in place.

The next implementation stage should be Stage 10: Home Feed And Post Card Framework. It should upgrade the homepage and paginated post-list surfaces while first recording and applying the Raptor markup discipline concern around unnecessary `Div`, `class`, and `data-*` growth.

Avoid starting fine visual refinement until Stages 9 through 13 are complete. Visual improvements inside those stages should be baseline framework visuals, not final polish.
