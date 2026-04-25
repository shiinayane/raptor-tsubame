# Article Reading Typography Stage 7.2C Design

## Context

Stage 7.1 stabilized the content metadata contract. Stage 7.2A split article pages into focused article components and added article-level structure. Stage 7.2B upgraded the article header with reading metadata, optional cover rendering, and reusable metadata icon blocks.

Stage 7.2 still has a major gap: the Markdown body itself is not yet a complete reading system. Current article body styling mostly affects the wrapper element, while headings, paragraphs, lists, blockquotes, tables, inline code, and code blocks still depend heavily on default output.

Fuwari's article body provides the reference direction, but not the implementation model. Fuwari uses an Astro Markdown pipeline, Tailwind Typography's `prose` wrapper, `custom-md` scoped styles, Expressive Code, heading slug/autolink plugins, TOC integration, and optional Markdown extensions. Raptor Tsubame should translate the architecture intent into the current Swift/Raptor boundaries rather than copying Astro plugins or Tailwind classes.

## Goals

- Make the Markdown body read as an intentional article surface instead of raw default HTML.
- Add scoped typography rules for headings, paragraphs, lists, blockquotes, tables, links, inline code, and code blocks.
- Keep all Markdown-specific styling scoped to the article Markdown boundary.
- Preserve the current article header, cover, sidebar, shell, taxonomy, and adjacent navigation behavior.
- Treat HTML code visibility as a high-risk acceptance condition.
- Use public Raptor APIs when practical, but allow one explicit narrow CSS resource if public `Style` APIs cannot express safe descendant selectors.

## Non-Goals

- No table of contents.
- No heading anchors.
- No related posts.
- No series navigation.
- No admonition or GitHub-card directive system.
- No code-copy button.
- No JavaScript-driven article interaction.
- No Markdown parser replacement.
- No broad global typography reset.
- No discovery, archive, tag, or category redesign.

## Fuwari Reference Findings

Fuwari's relevant body system has three layers:

- `Markdown.astro` wraps rendered content in a stable Markdown container with `prose`, dark-mode inversion, and `custom-md`.
- `astro.config.mjs` adds reading-time, sectioning, heading slugs, heading autolinks, directive components, math, and Expressive Code.
- `markdown.css` and `markdown-extend.styl` scope custom rules to `.custom-md`, including heading anchors, link treatment, inline code, code block spacing, list markers, blockquote accent bars, images, horizontal rules, iframes, admonitions, and extension cards.

Tsubame should adopt the same separation of responsibility:

- One stable Markdown boundary.
- Scoped article-body rules.
- Token-based code and prose colors.
- Optional future landing points for TOC/anchors/extensions.

Tsubame should not adopt Fuwari's full plugin stack in Stage 7.2C.

## HTML Code Visibility Constraint

Raptor's Markdown processor currently returns raw HTML blocks and inline HTML as raw HTML. Code blocks render as `<pre><code>...</code></pre>`, and HTML examples inside code blocks must remain visible as code instead of becoming real DOM nodes.

Stage 7.2C must therefore include fixture coverage for HTML examples:

- A fenced `html` code block containing markup such as `<div class="demo">Hello</div>`.
- Inline code containing markup-like text such as `<span>inline</span>`.
- A raw HTML block, documented as intentionally rendered HTML rather than display code.

Acceptance should distinguish these cases:

- Fenced and inline HTML code must remain visibly encoded or otherwise safely contained in code markup.
- Raw HTML should remain raw HTML because that is Raptor's current Markdown behavior.
- Article typography styles must not make code invisible by inheriting body text color/background combinations incorrectly.

If implementation discovers that fenced HTML code is emitted as unescaped raw markup, Stage 7.2C should not silently style around it. It should add a tested project-level workaround or explicitly stop and document the Raptor behavior as a blocker for safe HTML code examples.

## Architecture

Keep the existing article component structure:

- `ArticlePage` remains a thin `PostPage`.
- `ArticleContent` remains the article composition root.
- `ArticleHeader` remains the header owner.
- `ArticleBody` remains the body wrapper.
- `MarkdownContent` remains the Raptor `post.text` boundary.

Stage 7.2C should add a focused Markdown reading layer:

- `MarkdownContent` should keep `data-markdown-content="true"`.
- `ArticleBodyStyle` should remain responsible for container-level body rhythm.
- A new markdown-specific style layer should own descendant typography.

Preferred implementation path:

- First inspect whether Raptor public style APIs can express scoped descendant rules for `[data-markdown-content="true"] h2`, `pre`, `code`, `blockquote`, `table`, and list markers.
- If public APIs are insufficient, add a narrow, explicit CSS resource scoped only under `[data-markdown-content="true"]`.

The CSS-resource fallback is acceptable only if:

- It is stored in a focused source location.
- It is copied through the normal site asset/resource path.
- It is covered by published CSS/output assertions.
- It does not target unscoped global `h1`, `p`, `code`, `pre`, `table`, or `blockquote`.

## Visual Direction

The visual target is Fuwari-inspired but Tsubame-native:

- Headings should have clear vertical rhythm and strong but not oversized hierarchy.
- Paragraphs should retain comfortable line length and line height.
- Links should be visibly interactive without turning the article into a link-heavy UI surface.
- Lists should use restrained spacing and accent-colored markers where safely scoped.
- Blockquotes should use a soft accent rail or subtle panel treatment.
- Tables should be horizontally safe on mobile and readable in dark mode.
- Inline code should use a low-emphasis blue surface and readable monospace text.
- Code blocks should use a distinct dark/code surface, rounded corners, padding, overflow handling, and readable line-height.

The theme should continue the current pale blue light mode and deep blue dark mode direction.

## Article Bottom Area

Stage 7.2C may strengthen the existing adjacent navigation visually, but should not introduce related posts or series navigation.

The target is a simple bottom reading affordance:

- Keep `data-article-navigation="true"`.
- Render newer/older links as clear previous/next cards or buttons.
- Preserve route behavior and existing adjacent post query logic.
- Avoid a new discovery layer; that belongs to Stage 7.3.

## Testing

Use published-output tests as the primary verification path.

Add or expand fixtures to include:

- Heading levels.
- Paragraphs.
- Ordered and unordered lists.
- Blockquote.
- Table.
- Inline code.
- Swift or plain code block.
- HTML code block.
- Raw HTML block as a documented contrast case.

Tests should prove:

- Markdown content stays inside `data-markdown-content="true"`.
- `h2`, `p`, `ul`, `ol`, `blockquote`, `table`, `pre`, and `code` render inside the Markdown slice.
- Inline code and block code remain visible and scoped.
- Fenced HTML code does not become an unscoped real DOM element.
- Raw HTML remains raw HTML, matching Raptor's current behavior.
- Generated CSS includes scoped Markdown reading selectors or style markers.
- Generated CSS does not include broad global rules for Markdown descendants.
- Light and dark theme code/prose colors remain token-based.
- Article header and sidebar style markers remain present.

Run:

```bash
swift test --filter SitePublishingTests
swift test
swift run RaptorTsubame
rg -n "data-markdown-content|blockquote|table|pre|code|language-html" Build/posts/<fixture>/index.html
rg -n "data-markdown-content|markdown-reading|article-body-style" Build/css/raptor-core.css
```

## Acceptance Criteria

- Markdown body typography is visibly more intentional without changing article route structure.
- Code blocks and inline code remain readable in both light and dark modes.
- HTML code examples are protected by tests and do not disappear because of raw HTML interpretation or inherited styling.
- Markdown-specific CSS is scoped to `data-markdown-content`.
- Article header, cover, sidebar, and navigation behavior remain stable.
- No TOC, heading anchors, related posts, series navigation, or JavaScript interaction is introduced.
- `swift test` passes.
- Published HTML and CSS checks pass.

## Residual Risks

- Raptor's current Markdown processor may not escape fenced HTML code. If confirmed, Stage 7.2C needs a narrow project-level workaround or an explicit upstream/Raptor follow-up before HTML example posts can be considered safe.
- Public Raptor `Style` APIs may not expose enough descendant selector control for Markdown typography. A scoped CSS resource may be necessary.
- Deep Markdown styling can become a large theme system by accident. Stage 7.2C should only cover core article elements and defer admonitions, TOC, anchors, and copy buttons.
