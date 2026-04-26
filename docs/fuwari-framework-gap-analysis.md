# Fuwari Framework Gap Analysis

Date: 2026-04-26

This document compares the local `Examples/fuwari` theme against Raptor Tsubame's current framework. The goal is not a one-to-one port. The goal is to define the remaining base framework stages that must be completed before the project moves into fine visual refinement.

## Source Areas Reviewed

Fuwari reference areas:

- `Examples/fuwari/src/layouts/Layout.astro`
- `Examples/fuwari/src/layouts/MainGridLayout.astro`
- `Examples/fuwari/src/components/Navbar.astro`
- `Examples/fuwari/src/components/Footer.astro`
- `Examples/fuwari/src/components/PostCard.astro`
- `Examples/fuwari/src/components/PostPage.astro`
- `Examples/fuwari/src/components/PostMeta.astro`
- `Examples/fuwari/src/components/ArchivePanel.svelte`
- `Examples/fuwari/src/components/widget/SideBar.astro`
- `Examples/fuwari/src/components/widget/Profile.astro`
- `Examples/fuwari/src/components/widget/Categories.astro`
- `Examples/fuwari/src/components/widget/Tags.astro`
- `Examples/fuwari/src/components/widget/TOC.astro`
- `Examples/fuwari/src/config.ts`
- `Examples/fuwari/src/content/config.ts`

Current Tsubame areas:

- `Sources/Layouts/MainLayout.swift`
- `Sources/Components/Chrome`
- `Sources/Components/Posts`
- `Sources/Components/Sidebar`
- `Sources/Components/Taxonomy`
- `Sources/Content`
- `Sources/Pages`
- `Sources/Styles`
- `Sources/Theme`

## Already Aligned Enough

These areas have a durable framework foundation and should not be re-opened unless a later stage exposes a real integration issue.

- Main shell: unified content plus left sidebar layout exists across home, archive, about, article, category, and tag pages.
- Content contract: title, date, description, image, category, tags, language, published/draft compatibility, and content kind are represented.
- Post routes: homepage pagination, post pages, archive route, tag routes, and category routes exist.
- Sidebar architecture: profile, categories, and tags are layout-owned, not page-owned.
- Sidebar route awareness: category and tag detail routes mark active sidebar entries using public `@Environment(\.page)`.
- Article reading shell: article header, cover, metadata row, reading stats, inline TOC, body container, and adjacent navigation exist.
- Theme direction: light mode uses a pale blue/near-white direction, and dark mode uses a deep blue/near-black direction.
- Markdown safety path: article rendering uses a project-owned source-rendering path and compatibility tests instead of relying on private Raptor internals.

## Accepted Divergences From Fuwari

These are intentional differences, not gaps.

- Tsubame keeps the article TOC inline in the article flow. Fuwari uses a right-side desktop TOC. The inline approach avoids a three-column shell and preserves the existing left sidebar.
- Tsubame does not add Fuwari's Pagefind search as part of the framework-completion track. Search can come later when content volume justifies it.
- Tsubame does not add Fuwari's hue picker, display settings panel, or JavaScript page transitions as a baseline requirement.
- Tsubame does not add a `Recent Posts` sidebar widget. The main content region already owns post discovery.
- Tsubame should stay Fuwari-inspired, not Fuwari-identical.

## Remaining Framework Gaps

### Site Chrome

Fuwari has a complete top chrome layer: brand/home affordance, primary links, external link handling, mobile menu panel, search action, display settings, theme switch, and a styled footer. Tsubame currently has a bare `TopNavigation` with three unstyled links and a minimal footer.

Required before fine visual refinement:

- Branded top navigation.
- Primary route links with current-page state.
- Mobile navigation behavior that does not fight the sidebar.
- Footer shell with copyright and stable site links.
- A static extension slot for future actions such as search or theme switching without implementing those features now.

### Shared UI Primitive Baseline

Fuwari relies on repeated visual primitives such as `card-base`, `btn-plain`, `btn-card`, badges, float panels, rounded containers, primary accent bars, and motion classes. Tsubame currently has focused `Style` types but no explicit primitive layer that pages can reuse consistently.

Required before fine visual refinement:

- Card, button/link, badge, section-title, and metadata-chip primitives.
- Consistent icon box sizing rules where icons are used.
- A motion policy for load/hover transitions that can be applied route-wide.
- Light/dark token usage through `SiteThemePalette`, not page-local color decisions.

### Home Feed And Post Cards

Fuwari post cards are a major surface: title accent, metadata row, category/tags, description or excerpt, reading stats, optional cover thumbnail, hover affordance, and responsive layout. Tsubame post cards currently show title, date, and description only.

Required before fine visual refinement:

- Post card structure that can show metadata, tags/category, description/excerpt, reading stats, and optional cover.
- Pagination controls with real button/card treatment instead of plain text links.
- Responsive card layout that works both with and without cover images.

### Archive And Discovery Pages

Fuwari archive is a timeline-style discovery surface with year grouping, date marks, titles, and tag hints. Tsubame archive and taxonomy pages are structurally present but visually basic.

Required before fine visual refinement:

- Archive timeline or grouped-list treatment.
- Category and tag index pages with clear hierarchy rather than plain link lists.
- Category and tag detail pages with page headers, counts, and post-list context.
- Empty-state handling for generated discovery pages, even if normally not reached.

### Sidebar Finalization

Fuwari's category widget keeps counts; its tag widget does not show counts. Tsubame currently shows counts for both. Tsubame category row sizing also still needs a visual/layout pass.

Required before fine visual refinement:

- Remove visible counts from sidebar tag chips while preserving accessible labels if needed.
- Keep category counts, but tune row width, alignment, and badge sizing.
- Preserve current route-aware active states.
- Keep sidebar after content on mobile unless a later shell decision deliberately changes it.

### Article Completion

Tsubame's article framework is largely in place, but Fuwari still has several article peripherals that Tsubame has not settled.

Required before fine visual refinement:

- Decide and implement a license/copyright block, or explicitly mark it out of scope.
- Add structured article metadata where Raptor public APIs make it reasonable.
- Stabilize code block behavior and resolve the current Prism asset warning if the site will keep language-tagged code blocks.
- Decide which Fuwari Markdown extensions are baseline requirements and which are post-framework enhancements.

### Identity And Publishing Surface

Fuwari's site identity is config-driven: profile avatar, bio, social links, favicons, RSS, sitemap, and metadata all form part of the theme surface. Tsubame has profile text and core metadata but not the full identity/publishing surface.

Required before fine visual refinement:

- Profile avatar or intentional avatar placeholder policy.
- Social/profile links model.
- About page card structure that feels intentional rather than raw Markdown in the shell.
- RSS, sitemap, robots, favicon, and SEO verification as explicit route/build checks where supported.

## Framework Completion Stages

The following stages define the remaining framework-completion track. Fine visual refinement should start only after these are complete.

### Stage 9: Site Chrome And UI Primitives

Complete the top navigation, footer shell, and shared visual primitive layer.

Outcome:

- Top navigation is no longer a set of bare links.
- Footer has stable identity and publishing-link slots.
- Shared card/button/badge/section-title primitives exist.
- Future search/theme actions have reserved positions but are not implemented.

### Stage 10: Home Feed And Post Card Framework

Upgrade home and paginated post listing surfaces.

Outcome:

- Post cards support cover/no-cover layouts.
- Post cards expose metadata, taxonomy, descriptions/excerpts, and reading stats.
- Pagination uses the same visual language as the rest of the site.
- Homepage and page-two output can be used for later visual acceptance.

### Stage 11: Discovery And Taxonomy Framework

Upgrade archive, category, tag, and sidebar discovery surfaces.

Outcome:

- Archive becomes a real discovery view, not a plain grouped list.
- Category and tag index/detail pages have stable visual hierarchy.
- Sidebar tag counts are removed.
- Sidebar category row sizing is corrected.
- Discovery pages have route-level output tests.

### Stage 12: Article Completion And Markdown Infrastructure

Finish article peripherals and markdown/code behavior.

Outcome:

- Article page has a deliberate license/ownership decision.
- Code block behavior is stable and the Prism warning is either fixed or explicitly documented.
- Markdown extension policy is defined.
- Structured metadata is added where it fits Raptor's public API.

### Stage 13: Identity And Publishing Readiness

Complete site identity, about/profile surfaces, and publishing outputs.

Outcome:

- Profile/avatar/social link model is stable.
- About page has an intentional card/page structure.
- RSS/sitemap/robots/favicon/SEO routes are verified or explicitly documented as unsupported by the current Raptor stack.
- The project has a repeatable final framework verification checklist.

## Post-Framework Enhancements

These features should not block framework completion:

- Search.
- User-facing theme switcher.
- Hue/color picker.
- Banner system.
- Page transitions.
- Comments.
- Full i18n.
- Right-side dynamic TOC.

They can be revisited after Stage 13 if the site's content volume and maintenance needs justify them.
