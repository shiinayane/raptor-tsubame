import Testing
@testable import RaptorTsubame

@Suite("Safe Markdown to HTML")
struct SafeMarkdownToHTMLTests {
    @Test("escaped code entities stay stable while raw HTML code is escaped")
    func preservesExistingEntitiesInCode() throws {
        var processor = SafeMarkdownToHTML()

        let processed = try processor.process(
            """
            Inline escaped: `&lt;div class="x"&gt;`.

            Inline ampersand: `Tom &amp; "Jerry"`.

            ```html
            &lt;div class="block"&gt;
            ```

            ```html
            <div class="raw">Raw</div>
            ```
            """
        )

        #expect(!processed.body.contains("&amp;lt;"))
        #expect(!processed.body.contains("&amp;amp;"))
        #expect(processed.body.contains(#"&lt;div class="x"&gt;"#))
        #expect(processed.body.contains(#"Tom &amp; "Jerry""#))
        #expect(processed.body.contains(#"&lt;div class="block"&gt;"#))
        #expect(processed.body.contains(#"&lt;div class="raw"&gt;Raw&lt;/div&gt;"#))
        #expect(!processed.body.contains(#"<div class="raw">Raw</div>"#))
    }

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

    @Test("raw HTML with code-prefixed custom elements is not consumed as code")
    func leavesCodePrefixedRawHTMLElementUntouched() throws {
        var processor = SafeMarkdownToHTML()

        let processed = try processor.process(
            """
            <codepen-embed data-id="demo"></codepen-embed>

            Inline HTML code: `<span>visible</span>`.
            """
        )

        #expect(processed.body.contains(#"<codepen-embed data-id="demo"></codepen-embed>"#))
        #expect(processed.body.contains("&lt;span&gt;visible&lt;/span&gt;"))
        #expect(!processed.body.contains("<span>visible</span>"))
    }

    @Test("literal closing code tags inside code cannot escape the code element")
    func escapesLiteralClosingCodeTagsInsideCode() throws {
        var processor = SafeMarkdownToHTML()

        let processed = try processor.process(
            """
            Inline hostile code: `</code><script>alert("inline")</script>`.

            ```html
            </code><script>alert("block")</script>
            ```
            """
        )

        #expect(processed.body.contains("&lt;/code&gt;&lt;script&gt;alert(\"inline\")&lt;/script&gt;"))
        #expect(processed.body.contains("&lt;/code&gt;&lt;script&gt;alert(\"block\")&lt;/script&gt;"))
        #expect(!processed.body.contains(#"<script>alert("inline")</script>"#))
        #expect(!processed.body.contains(#"<script>alert("block")</script>"#))
    }

    @Test("fence-like code lines with trailing text stay inside escaped code")
    func doesNotTreatFenceWithTrailingTextAsClosingFence() throws {
        var processor = SafeMarkdownToHTML()

        let processed = try processor.process(
            """
            ```html
            ```not a close
            </code><script>alert("still code")</script>
            ```
            """
        )

        #expect(processed.body.contains("```not a close"))
        #expect(processed.body.contains("&lt;/code&gt;&lt;script&gt;alert(\"still code\")&lt;/script&gt;"))
        #expect(!processed.body.contains(#"<script>alert("still code")</script>"#))
    }

    @Test("multiple real code elements are escaped")
    func escapesMultipleCodeElements() throws {
        var processor = SafeMarkdownToHTML()

        let processed = try processor.process(
            """
            First: `<one>`.

            Second: `<two attr="value">`.

            ```html
            <three>
            ```
            """
        )

        #expect(processed.body.contains("&lt;one&gt;"))
        #expect(processed.body.contains(#"&lt;two attr="value"&gt;"#))
        #expect(processed.body.contains("&lt;three&gt;"))
        #expect(!processed.body.contains("<one>"))
        #expect(!processed.body.contains(#"<two attr="value">"#))
        #expect(!processed.body.contains("<three>"))
    }
}
