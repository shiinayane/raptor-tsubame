# Raptor API Boundaries

This project depends on Raptor's task-local rendering and build contexts. Keep the rules below in place when adding pages, layouts, styles, content queries, or tests.

## Rendering-Only Values

These Raptor values are only valid while Raptor is rendering a page:

- `@Environment(...)` reads from `RenderingContext.current.environment` and traps outside rendering.
- `Layout.content` reads the current page markup from `RenderingContext.current`.
- `PostPage.post` reads the active post from `RenderingContext.current`.

Project rules:

- Use `@Environment(\.posts)` and `@Environment(\.site)` only inside page, layout, or component bodies that Raptor renders.
- Use `content` only inside `Layout.body`.
- Use `post` only inside `PostPage.body` or computed properties that are evaluated from `body`.
- Do not call environment-backed page/layout/post bodies directly from regular unit tests. Verify them through published HTML or through data-only helpers.

Current safe usage:

- `MainLayout` reads `posts`, `site`, and `content` during layout rendering.
- `HomePage`, archive, and taxonomy pages read `posts` during page rendering.
- `ArticlePage` and `MarkdownPage` read `post` during post rendering.

## Site Preparation

Raptor loads Markdown content before calling `Site.prepare()`, and `prepare()` runs with a rendering context installed. Even so, this project keeps `ExampleSite.prepare()` data-only:

- It scans front matter with `SiteContentLoader`.
- It generates homepage, tag, and category route lists.
- It does not read `@Environment`, `Layout.content`, or `PostPage.post`.

This keeps preparation predictable and easy to test without rendering a page.

## Front Matter

Raptor selects `PostPage` implementations by matching front matter `layout` against the exact Swift type name in `postPages`.

Project rules:

- Regular posts use the first `postPages` entry, currently `ArticlePage`.
- Standalone Markdown pages must set `layout: MarkdownPage`.
- Keep custom metadata parsing centralized in `SiteContentMetadata`.
- Match Raptor's `published` semantics: `Bool(value) ?? true`.

Supported custom metadata:

- `kind`: `post` or `page`, defaulting to `post`.
- `path`: custom route for standalone pages.
- `category`: a single category name.
- `tags`: comma-separated tag names.
- `published`: Swift `Bool` string, defaulting to `true`.

## Themes And Styles

Raptor generates theme and style CSS by evaluating each `Style` under combinations of `EnvironmentConditions`.

Project rules:

- Register the site theme through `nonisolated var themes: [any Theme]`.
- Keep page-level background ownership in `Theme`, not inline layout background styles.
- Resolve light/dark visual tokens through `EnvironmentConditions.colorScheme`.
- Keep shell layout styles separate from visual surface styles.
- Avoid relying on guessed theme IDs; assert published HTML/CSS when theme scope matters.

Current required published markers:

- `<html>` should include `data-theme="site-theme"`.
- The generated CSS should include light and dark `--bg-page` variables for `site-theme`.
- Visual styles should generate dark-mode rules scoped under `data-color-scheme="dark"`.

## Tests

Publishing tests are intentionally end-to-end, but they should not publish the full site once per assertion. Use `publishedSite()` from test support to reuse the generated output within a test run.

Project rules:

- Use publishing tests for route, shell, generated CSS, and theme integration coverage.
- Use data-only unit tests for metadata parsing, taxonomy term normalization, and pagination logic.
- Keep shared HTML parsing helpers in test support rather than duplicating them per publishing suite.
- Do not assert exact hashed style class names. Prefer stable class prefixes, data markers, or CSS rule contents.

## Review Checklist

Before adding a new Raptor-facing feature, check:

- Does it access `@Environment`, `content`, or `post` only during rendering?
- Does any front matter parsing duplicate `SiteContentMetadata`?
- Does a new `PostPage` require exact `layout` front matter?
- Does style logic belong in a `Style` rather than in a page/component?
- Does theme-sensitive behavior have published HTML or CSS coverage?
