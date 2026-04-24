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

- `cover`: optional article cover image path.
- `series`: optional series name for grouped posts.
- `toc`: optional table-of-contents preference.
- `pinned`: optional homepage/discovery weight.
- `lang`: optional content language marker if multilingual content becomes real.

Initial implementation should be conservative:

- Document all candidate fields.
- Implement only fields needed by the next stage.
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

## Current Recommendation

The next implementation stage should be Stage 7.1, limited to a content contract design and the smallest metadata parsing support needed for Stage 7.2. Avoid implementing cover images, series pages, TOC, and search all at once.

After Stage 7.1, move into Stage 7.2 article reading work. That is the best place to improve both core blog value and visual expression without scattering effort across unrelated surfaces.
