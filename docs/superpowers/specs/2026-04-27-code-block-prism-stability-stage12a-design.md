# Stage 12A Code Block And Prism Stability Design

Date: 2026-04-27

## Purpose

Stage 12A starts the article-completion track by stabilizing code block behavior and the current Prism publishing path. The site already has an article body pipeline, scoped Markdown reading CSS, HTML-code escaping tests, and an upstream bug note for multi-paragraph list items. The remaining article infrastructure risk is that language-tagged code blocks currently publish with Prism warnings and an implicit fallback syntax theme.

Stage 12A should make code blocks suitable for long-term publishing without rewriting the Markdown renderer or starting the broader Markdown extension policy work.

## Scope

Stage 12A includes:

- Configure an explicit Raptor syntax highlighter theme so language-tagged code blocks do not rely on the built-in fallback.
- Resolve the current missing `Resources/js/prism/prism-html` warning while keeping author-facing Markdown language tags stable.
- Verify generated Prism assets in `Build/js/prism.js` and `Build/css/prism.css`.
- Strengthen publishing tests for visible and safe HTML code blocks.
- Keep `SafeMarkdownToHTML` behavior unchanged for escaped inline code, fenced HTML code, and hostile `</code><script>` samples.
- Document any project-side compatibility layer that should later become an upstream Raptor issue.

Stage 12A excludes:

- License or ownership blocks.
- Structured article metadata.
- Full Markdown extension policy.
- A Markdown renderer replacement.
- A complete Fuwari visual code-block polish pass.
- JavaScript copy-code buttons or other article interactions.

## Current Behavior

Publishing currently succeeds but emits Prism-related warnings when language-tagged code blocks are present:

- `Failed to locate syntax highlighter JavaScript: Resources/js/prism/prism-html.`
- `Language-tagged code blocks are present, but no syntax-highlighter theme is defined.`

The second warning is configuration-owned by this project and should be fixed by declaring a syntax highlighter theme through Raptor's public theme API.

The first warning comes from a language/resource mismatch: Markdown authors can write fenced `html` blocks, but the checked Raptor resources include Prism `markup`, `xml`, and other languages rather than a `prism-html.js` file. Stage 12A should not alter upstream Raptor source. It should add a minimal project-side compatibility resource or route the site's Markdown language usage through a public, stable mapping.

## Design

### Syntax Theme

`SiteTheme` should declare a syntax highlighter theme explicitly. The first implementation may use Raptor's built-in `.xcode` or another built-in theme if it behaves correctly in both light and dark schemes.

The important contract is not final visual taste. The contract is:

- Prism theme CSS is generated intentionally.
- The fallback warning disappears.
- Code remains readable in both light and dark site themes.
- Later visual refinement can swap the syntax theme without changing article rendering behavior.

### Prism HTML Compatibility

Stage 12A should prefer a compatibility layer that lets authors keep writing fenced code as:

````markdown
```html
<div>Example</div>
```
````

The implementation should avoid changing upstream Raptor files. If Raptor's resource loader can include target resources from this package, add a minimal `prism-html` compatibility resource in the project. If Raptor only reads Prism files from its own bundle, use the narrowest project-level language normalization before Markdown conversion, mapping fenced `html` to a Raptor-supported Prism language such as `markup`, while preserving visible code output.

Whichever path is chosen must be documented in a short local upstream note. The note should explain that Raptor appears to request `prism-html` for Markdown `html` fences while its bundled Prism resources use `prism-markup`.

### Code Block Output

Published article output should prove that HTML code is still code:

- Fenced HTML samples render inside code/pre markup.
- Literal angle brackets in code are escaped.
- Raw HTML samples that are intentionally raw remain raw outside code.
- Hostile code samples containing `</code><script>` remain escaped and cannot create real script tags.
- Existing scoped Markdown CSS remains linked from `<head>`.

This continues the Stage 7.2D safety boundary. Stage 12A should not weaken `SafeMarkdownToHTML` to make Prism easier.

### Generated Assets

When the site contains language-tagged code blocks:

- `Build/js/prism.js` should exist.
- `Build/css/prism.css` should exist.
- `Build/css/raptor-core.css` should contain syntax highlighter theme output.
- The generated page should still link the existing `markdown-reading.css`.

Tests should assert these generated artifacts directly, not just the absence of warnings.

## Testing Strategy

Add or extend publishing tests so Stage 12A has durable coverage:

- A focused publishing test for Prism assets and syntax-theme CSS.
- Compatibility lab assertions that fenced HTML code remains escaped and visible.
- A full publishing verification command that confirms `swift run RaptorTsubame` exits 0 without the two current Prism warnings.

Unit tests around `SafeMarkdownToHTML` should remain focused on source transformation and hostile-code escaping. Publishing tests should own generated asset and page-output checks.

## Acceptance Criteria

Stage 12A is complete when:

- `swift test` passes.
- `swift run RaptorTsubame` exits 0 without the current Prism missing-resource and fallback-theme warnings.
- `Build/js/prism.js` and `Build/css/prism.css` are generated when compatibility lab code blocks are present.
- Published HTML code blocks remain visible as code and do not execute as raw HTML.
- A local upstream note records the Prism `html` resource mismatch if the implementation needs a project-side workaround.
- No license, metadata, full Markdown policy, renderer replacement, or copy-code interaction is introduced.

## Risks

- Raptor may only load Prism resources from its own module bundle. If so, a project-side `prism-html` file may not be sufficient, and language normalization may be the safer short-term route.
- Mapping `html` to `markup` could affect generated class names or CSS selectors. Tests should assert visible behavior and generated assets rather than overfitting to every class.
- Removing warnings from `swift run` may require capturing command output in tests or using a verification script. The final implementation plan should choose the least brittle verification path.
