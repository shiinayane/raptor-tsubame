# Upstream Raptor Bug: HTML Prism Language Mapping

## Summary

Raptor currently maps `SyntaxHighlighterLanguage.html` to `Resources/js/prism/prism-html.js`, but the bundled Prism resources do not include `prism-html.js`.

The bundled Prism resources include `prism-markup.js` and `prism-xml.js`. Prism itself aliases HTML to markup, so HTML code fences should be satisfiable by the bundled markup/XML highlighter instead of requesting a missing `prism-html.js` file.

## Local Evidence

When published content contains a Markdown fence such as:

~~~markdown
```html
<section>Visible HTML code</section>
```
~~~

Raptor attempts to locate:

```text
Resources/js/prism/prism-html.js
```

The generated publish step reports:

```text
Failed to locate syntax highlighter JavaScript: Resources/js/prism/prism-html.
```

## Local Workaround

This project normalizes author-written `html` fenced code blocks to `xml` before passing Markdown to Raptor:

~~~markdown
```html
```
~~~

becomes:

~~~markdown
```xml
```
~~~

This keeps the authoring experience stable while making Raptor include the bundled Prism markup/XML highlighter. It also preserves the existing `SafeMarkdownToHTML` escaping boundary, so HTML code remains visible as escaped code rather than becoming raw HTML.

## Suggested Upstream Fix

One of these upstream fixes would remove the need for the local workaround:

1. Map `SyntaxHighlighterLanguage.html` to the bundled Prism markup/XML asset.
2. Add a bundled `prism-html.js` shim or alias that loads the markup grammar.
3. Treat `html` as an alias of `markup` during syntax highlighter asset resolution.

The safest behavior is likely aliasing `html` to Prism markup at asset-resolution time, because it matches Prism's own grammar model and avoids changing author-facing language names.

## Current Project Status

Tracked locally in Stage 12A as a project-side compatibility workaround. The local workaround should be removed if Raptor fixes the asset mapping upstream.
