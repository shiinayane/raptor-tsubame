# Stage 12A Code Block And Prism Stability Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stabilize article code block publishing by removing current Prism warnings, preserving safe HTML code output, and verifying generated Prism assets.

**Architecture:** Keep the project on Raptor public APIs. Configure an explicit syntax highlighter theme in `SiteTheme`, and normalize Markdown fenced `html` language tags to Raptor's bundled Prism markup resource before `MarkdownToHTML` sees them. Publishing tests verify generated assets and rendered code output; a local upstream note records the Raptor `html`/`prism-html` mismatch.

**Tech Stack:** Swift, Raptor public API, Swift Testing, generated HTML/CSS/JS assertions, static publishing output inspection.

---

## Scope Boundaries

Included:

- Explicit site syntax highlighter theme.
- Project-side normalization from author-written fenced `html` blocks to Raptor-supported `xml` Prism resources.
- Tests that prove HTML code remains visible and escaped.
- Tests that prove Prism JS/CSS and syntax-theme CSS are generated.
- Local upstream note documenting the Raptor Prism `html` mapping mismatch.

Excluded:

- License or ownership blocks.
- Structured article metadata.
- Full Markdown extension policy.
- Markdown renderer replacement.
- Copy-code buttons or JavaScript interactions.
- Final Fuwari-style code-block visual polish.

## File Structure

- Modify `Sources/Theme/SiteTheme.swift`: declare `.xcode` syntax highlighter theme through Raptor's public theme modifier.
- Modify `Sources/Markdown/SafeMarkdownToHTML.swift`: normalize supported fenced language aliases before passing Markdown to Raptor.
- Modify `Tests/RaptorTsubameTests/Markdown/SafeMarkdownToHTMLTests.swift`: cover `html` fence normalization and escaping.
- Modify `Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`: verify visible escaped HTML code in published output.
- Modify `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`: verify Prism assets and syntax-theme CSS in generated output.
- Create `docs/upstream-raptor-prism-html-language-mapping.md`: document the upstream mismatch and local workaround.

## Task 1: Syntax Theme And Prism Asset Publishing Tests

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift`

- [ ] **Step 1: Add failing Prism asset publishing test**

Add this test near the existing generated CSS tests in `SitePublishingTests`:

```swift
@Test("generated output includes Prism assets and syntax theme CSS")
func generatedOutputIncludesPrismAssetsAndSyntaxThemeCSS() async throws {
    let harness = try await publishedSite()

    #expect(harness.fileExists("js/prism.js"))
    #expect(harness.fileExists("css/prism.css"))

    let prismJS = try harness.contents(of: "js/prism.js")
    let prismCSS = try harness.contents(of: "css/prism.css")
    let coreCSS = try harness.contents(of: "css/raptor-core.css")
    let markdownReadingLab = try harness.contents(of: "posts/markdown-reading-lab/index.html")

    #expect(prismJS.contains("Prism.languages.markup"))
    #expect(prismJS.contains("Prism.languages.swift"))
    #expect(prismJS.contains("Prism.languages.css"))
    #expect(prismCSS.contains("[data-highlighter-theme] pre[class*=\"language-\"]"))
    #expect(coreCSS.contains("data-highlighter-theme"))
    #expect(coreCSS.contains("--highlighter-theme: \"xcode\""))
    #expect(markdownReadingLab.contains("href=\"/css/prism.css\""))
    #expect(markdownReadingLab.contains("src=\"/js/prism.js\""))
}
```

- [ ] **Step 2: Verify RED**

Run:

```bash
swift test --filter SitePublishingTests/generatedOutputIncludesPrismAssetsAndSyntaxThemeCSS
```

Expected: FAIL because author-written `html` fences still register Raptor's `.html` highlighter, which requests missing `prism-html.js`; `Build/js/prism.js` should not yet contain `Prism.languages.markup` for those HTML fences.

- [ ] **Step 3: Commit test**

```bash
git add Tests/RaptorTsubameTests/Publishing/SitePublishingTests.swift
git commit -m "test: cover prism publishing assets"
```

## Task 2: Explicit Syntax Highlighter Theme

**Files:**
- Modify: `Sources/Theme/SiteTheme.swift`

- [ ] **Step 1: Configure syntax theme**

Replace `SiteTheme.theme(site:colorScheme:)` with:

```swift
struct SiteTheme: Theme {
    func theme(site: Content, colorScheme: ColorScheme) -> Content {
        let themedSite = site.syntaxHighlighterTheme(.xcode)

        if colorScheme == .dark {
            return themedSite.background(SiteThemePalette.dark.pageBackground)
        } else {
            return themedSite.background(SiteThemePalette.light.pageBackground)
        }
    }
}
```

This uses Raptor's public `Theme`/`Content` modifier and removes the fallback-theme warning without changing final article layout.

- [ ] **Step 2: Verify focused test now reaches the Prism HTML mapping gap**

Run:

```bash
swift test --filter SitePublishingTests/generatedOutputIncludesPrismAssetsAndSyntaxThemeCSS
```

Expected: FAIL because the explicit theme removes the fallback-theme problem, but `html` fences still request the missing `prism-html.js` resource until Task 3 normalizes them.

- [ ] **Step 3: Commit syntax theme**

```bash
git add Sources/Theme/SiteTheme.swift
git commit -m "fix: configure syntax highlighter theme"
```

## Task 3: Markdown HTML Fence Normalization

**Files:**
- Modify: `Tests/RaptorTsubameTests/Markdown/SafeMarkdownToHTMLTests.swift`
- Modify: `Sources/Markdown/SafeMarkdownToHTML.swift`

- [ ] **Step 1: Add failing unit test**

Add this test to `SafeMarkdownToHTMLTests`:

```swift
@Test("HTML fences use bundled Prism markup highlighter while keeping escaped code")
func htmlFencesUseBundledPrismMarkupHighlighter() throws {
    var processor = SafeMarkdownToHTML()

    let processed = try processor.process(
        """
        ```html
        <section data-demo="true">Visible code</section>
        ```
        """
    )

    #expect(processed.body.contains(#"<code class="language-xml">"#))
    #expect(processed.body.contains(#"&lt;section data-demo="true"&gt;Visible code&lt;/section&gt;"#))
    #expect(!processed.body.contains(#"<code class="language-html">"#))
    #expect(!processed.body.contains(#"<section data-demo="true">Visible code</section>"#))
    #expect(processor.syntaxHighlighterLanguages.contains(.markup))
    #expect(!processor.syntaxHighlighterLanguages.contains(.html))
}
```

- [ ] **Step 2: Verify RED**

Run:

```bash
swift test --filter SafeMarkdownToHTMLTests/htmlFencesUseBundledPrismMarkupHighlighter
```

Expected: FAIL because `SafeMarkdownToHTML` currently preserves the author-written `html` info string and Raptor registers `.html`.

- [ ] **Step 3: Implement normalization**

In `Sources/Markdown/SafeMarkdownToHTML.swift`, change `process(_:)` to normalize code fence languages after escaping code content:

```swift
mutating func process(_ markup: String) throws -> ProcessedPost {
    processor.process(normalizeMarkdownFenceLanguages(in: escapeMarkdownCode(in: markup)))
}
```

Add this helper near the existing private helpers:

```swift
private func normalizeMarkdownFenceLanguages(in markup: String) -> String {
    var result = ""
    var index = markup.startIndex

    while index < markup.endIndex {
        let lineEnd = markup[index...].firstIndex(of: "\n") ?? markup.endIndex
        let line = String(markup[index..<lineEnd])
        let newline = lineEnd < markup.endIndex ? "\n" : ""

        result += normalizeFenceOpeningLine(line) + newline
        index = lineEnd < markup.endIndex ? markup.index(after: lineEnd) : lineEnd
    }

    return result
}

private func normalizeFenceOpeningLine(_ line: String) -> String {
    let indentation = line.prefix(min(indentationCount(in: line), 3))
    let trimmed = line.dropFirst(indentation.count)
    guard let first = trimmed.first, first == "`" || first == "~" else {
        return line
    }

    let fenceLength = trimmed.prefix { $0 == first }.count
    guard fenceLength >= 3 else { return line }

    let fence = String(repeating: String(first), count: fenceLength)
    let info = trimmed.dropFirst(fenceLength)
    let leadingWhitespace = info.prefix { $0.isWhitespace }
    let infoText = info.dropFirst(leadingWhitespace.count)
    guard infoText.lowercased() == "html" else {
        return line
    }

    return "\(indentation)\(fence)\(leadingWhitespace)xml"
}
```

This deliberately maps author-facing `html` fences to Raptor's `.markup` enum case, whose raw value is `xml` and whose bundled Prism resource exists as `prism-xml.js`.

- [ ] **Step 4: Verify GREEN**

Run:

```bash
swift test --filter SafeMarkdownToHTMLTests/htmlFencesUseBundledPrismMarkupHighlighter
swift test --filter SafeMarkdownToHTMLTests
```

Expected: PASS.

- [ ] **Step 5: Commit normalization**

```bash
git add Sources/Markdown/SafeMarkdownToHTML.swift Tests/RaptorTsubameTests/Markdown/SafeMarkdownToHTMLTests.swift
git commit -m "fix: normalize html code fences for prism"
```

## Task 4: Published HTML Code Block Assertions

**Files:**
- Modify: `Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift`

- [ ] **Step 1: Strengthen compatibility publishing assertions**

Extend `documentsHTMLCompatibilityBehavior()` with:

```swift
#expect(markdown.contains(#"<code class="language-xml">"#))
#expect(markdown.contains(#"&lt;/code&gt;&lt;script&gt;alert("block")&lt;/script&gt;"#))
#expect(!markdown.contains(#"<code class="language-html">"#))
```

- [ ] **Step 2: Verify RED or GREEN with normalization**

Run:

```bash
swift test --filter MarkdownCompatibilityPublishingTests/documentsHTMLCompatibilityBehavior
```

Expected: PASS after Task 3. The test should verify the existing hostile fenced HTML sample from `Posts/pages/markdown-compatibility-lab.md` remains escaped inside a `language-xml` code block.

- [ ] **Step 3: Commit publishing assertion**

```bash
git add Tests/RaptorTsubameTests/Publishing/MarkdownCompatibilityPublishingTests.swift
git commit -m "test: verify published html code blocks"
```

## Task 5: Upstream Note For Prism HTML Mapping

**Files:**
- Create: `docs/upstream-raptor-prism-html-language-mapping.md`

- [ ] **Step 1: Write upstream note**

Create `docs/upstream-raptor-prism-html-language-mapping.md`:

```markdown
# Raptor Prism HTML Language Mapping Note

Date: 2026-04-27

## Summary

Raptor's Markdown pipeline accepts fenced code blocks labelled `html` and registers `SyntaxHighlighterLanguage.html`. The current Prism resource generator then looks for `Resources/js/prism/prism-html.js`.

In the checked Raptor package, the bundled Prism markup resources are present as `prism-markup.js` and `prism-xml.js`, while `prism-html.js` is absent. This makes publishing succeed with a non-fatal warning:

`Failed to locate syntax highlighter JavaScript: Resources/js/prism/prism-html.`

## Local Workaround

Raptor Tsubame keeps author-facing Markdown fences as `html`, but normalizes them to `xml` before handing Markdown to Raptor's `MarkdownToHTML`. In Raptor's public enum, `SyntaxHighlighterLanguage.markup` has raw value `xml`, which points at the existing bundled Prism markup resource.

This avoids changing upstream Raptor source and keeps generated code blocks highlighted through the bundled markup highlighter.

## Upstream Issue Candidate

Raptor could either:

- map `SyntaxHighlighterLanguage.html` to the bundled Prism markup resource, or
- ship a `prism-html.js` alias/resource, or
- document that authors should use `xml`/`markup` rather than `html` for Prism-backed HTML code fences.

The first option appears most author-friendly because Markdown authors commonly write `html` fences.
```

- [ ] **Step 2: Commit note**

```bash
git add docs/upstream-raptor-prism-html-language-mapping.md
git commit -m "docs: record prism html mapping issue"
```

## Task 6: Final Verification

**Files:**
- No new files unless verification exposes a necessary fix.

- [ ] **Step 1: Run focused publishing tests**

Run:

```bash
swift test --filter SitePublishingTests/generatedOutputIncludesPrismAssetsAndSyntaxThemeCSS
swift test --filter MarkdownCompatibilityPublishingTests/documentsHTMLCompatibilityBehavior
```

Expected: PASS.

- [ ] **Step 2: Run full test suite**

Run:

```bash
swift test
```

Expected: PASS.

- [ ] **Step 3: Run site generator and inspect warnings**

Run:

```bash
swift run RaptorTsubame
```

Expected: exits 0 and no longer prints either of these warnings:

- `Failed to locate syntax highlighter JavaScript: Resources/js/prism/prism-html.`
- `Language-tagged code blocks are present, but no syntax-highlighter theme is defined.`

- [ ] **Step 4: Inspect generated artifacts**

Run:

```bash
rg -n "Prism.languages.markup|Prism.languages.swift|Prism.languages.css" Build/js/prism.js
rg -n "data-highlighter-theme|data-inline-highlighter-theme" Build/css/raptor-core.css Build/css/prism.css
rg -n "language-xml|&lt;|data-markdown-content" Build/posts/markdown-compatibility-lab/index.html Build/posts/markdown-reading-lab/index.html
```

Expected:

- `Build/js/prism.js` contains markup, Swift, and CSS highlighters.
- `Build/css/raptor-core.css` contains syntax highlighter theme variables.
- `Build/css/prism.css` contains Prism selectors.
- Published article output contains `language-xml` for author-written `html` fences and escaped angle brackets inside code.

## Implementation Notes

- Do not modify `../raptor`.
- Do not add copy-code buttons.
- Do not add license/metadata/Markdown policy features.
- Keep the local normalization narrow: only exact `html` fence info strings should become `xml`.
- Do not normalize inline code or raw HTML.
- If a future article needs other aliases such as `js`, add a separate tested alias map in another stage rather than expanding this task opportunistically.
