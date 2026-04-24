# Fuwari Shell Visual Stabilization Stage 3.5 Design

## Context

Stage 1 established the core content-driven information architecture. Stage 2 added taxonomy routes and article metadata. Stage 3 introduced a shared site shell with a persistent sidebar containing `Profile`, `Categories`, and `Tags`.

The current shell is structurally correct, but its visual and responsive rules are still mostly carried by raw Raptor stack output and small inline layout hints. Stage 3.5 stabilizes the shell visually before adding richer features such as TOC, search, animation, or theme settings.

This stage references Fuwari's visual direction, but it does not copy Fuwari's Astro components, Tailwind classes, exact CSS values, animation system, or full theme variables. The goal is to rebuild the intent in Raptor's own layers.

## Goals

- Create a stable Fuwari-inspired reading shell for the existing site structure.
- Move shell/sidebar/main visual rules into semantic Raptor styles.
- Give the sidebar a clear visual track, width behavior, and panel rhythm.
- Give the main content region clear flex behavior and readable width constraints.
- Preserve content-first DOM order while keeping the sidebar visually leading on desktop.
- Provide a simple mobile fallback where content appears before sidebar.
- Clean up ambiguous shell markers so selectors and tests have clearer meaning.

## Non-Goals

- No right-side table of contents.
- No search UI.
- No theme switcher, hue selector, or display settings panel.
- No banner or hero image system.
- No animation or page transition layer.
- No article previous/next navigation.
- No one-to-one visual clone of Fuwari.
- No major redesign of article cards, taxonomy pages, or markdown typography.

## Visual Direction

The shell should borrow Fuwari's broad intent:

- Soft panel surfaces.
- Calm border and shadow treatment.
- A stable left identity/navigation rail.
- A main content area that feels lighter and easier to read.
- A content site mood rather than an application dashboard.

Implementation should remain conservative. This stage should not introduce a large color system or broad typography redesign. The styling should be enough to make the shell stable and readable, while leaving room for later visual refinement.

## Architecture

Stage 3.5 keeps the current source layering:

- `Styles` own semantic visual rules.
- `Components` own reusable structure.
- `Layouts` own page skeleton.
- `Pages` continue to compose content only.

Add a focused `Sources/Styles/Shell/` group containing:

- `SiteShellStyle`
- `ShellMainStyle`
- `ShellSidebarStyle`
- `SidebarPanelStyle`

These styles are intentionally shell-specific. They should not become a broad theme system, and they should not pull page-specific decisions into layout code.

## Layout Strategy

Desktop behavior:

- The DOM order remains main content first, then sidebar.
- The sidebar appears visually on the left through shell styling.
- The sidebar has a stable width range, roughly in the 260-300px range.
- The main content takes the remaining space but is protected by a readable max width.
- Sidebar sizing must not be affected by inner content such as homepage pagination spacers.

Mobile behavior:

- The shell becomes a single column.
- Main content remains before sidebar.
- The sidebar remains visible below the main content.
- No drawer, collapse, or animation is introduced.
- Sidebar spacing becomes slightly tighter than desktop.

This preserves the accessibility benefits of content-first DOM order while matching the chosen Stage 3 shell direction on desktop.

## Component Boundaries

`MainLayout` should only assemble the shell:

- top navigation
- shell wrapper
- main content wrapper
- sidebar wrapper
- footer

`MainLayout` should not keep low-level inline style decisions such as raw `order: -1`. Visual ordering should move into `ShellSidebarStyle`.

Sidebar components remain structural:

- `SidebarContainer`
- `SidebarProfile`
- `SidebarCategories`
- `SidebarTags`

If sidebar sections need a panel treatment, components apply `SidebarPanelStyle` rather than carrying raw visual properties directly.

## Marker Cleanup

Current Stage 3 output uses `data-sidebar-shell` on both the outer shell and the `<aside>`. Stage 3.5 should make the marker ownership clearer:

- outer shell keeps `data-sidebar-shell="true"`
- sidebar container uses `data-sidebar-container="true"`
- `data-sidebar-profile`, `data-sidebar-categories`, and `data-sidebar-tags` remain on their existing blocks
- `data-sidebar-position="leading"` remains available as a visual intent marker
- `data-shell-layout="two-column"` remains on the shell wrapper

Tests should assert that `data-sidebar-shell` appears once within each relevant `<main>` region.

## Testing

Existing publishing tests should continue to cover the major route types:

- homepage
- archive
- about
- article page
- tag index/detail
- category index/detail

Stage 3.5 should update or add tests for:

- shell marker ownership is unambiguous
- homepage includes `data-sidebar-container`
- archive/about/article/taxonomy pages include `data-sidebar-container`
- `data-sidebar-shell` appears once per main shell
- existing sidebar block markers remain present

Run the full suite with:

```bash
swift test
```

Also publish the site and inspect key outputs:

```bash
swift run RaptorTsubame
rg -n "site-shell|data-sidebar-shell|data-sidebar-container|data-shell-layout|data-sidebar-position" Build/index.html Build/archive/index.html Build/about/index.html Build/posts/welcome-to-tsubame/index.html
```

## Acceptance Criteria

- Shell visual rules live in semantic style types, not scattered inline layout properties.
- Desktop shell has explicit sidebar and main content sizing behavior.
- Mobile shell degrades to content first, sidebar second.
- Sidebar visually leads on desktop while DOM order remains content first.
- `data-sidebar-shell` is no longer duplicated between shell and aside.
- `data-sidebar-container` identifies the actual sidebar container.
- Existing Stage 1, Stage 2, and Stage 3 routes remain published.
- `swift test` passes.

## Residual Risks

- Raptor's generated stack markup is still string-tested in places, so tests can remain somewhat coupled to rendered HTML.
- This stage does not validate actual viewport rendering with a browser screenshot. If visual fidelity becomes important before Stage 4, add a browser-based verification step.
- The Fuwari-inspired visual direction remains intentionally light; deeper typography, color, and motion work should be handled in a later stage.
