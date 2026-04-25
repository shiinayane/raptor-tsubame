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
