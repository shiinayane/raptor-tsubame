import Testing

@Suite("Markdown compatibility publishing", .serialized)
struct MarkdownCompatibilityPublishingTests {
    @Test("publishes markdown compatibility lab through article pipeline")
    func publishesCompatibilityLab() async throws {
        let harness = try await publishedSite()

        #expect(harness.fileExists("posts/markdown-compatibility-lab/index.html"))

        let page = try harness.contents(of: "posts/markdown-compatibility-lab/index.html")
        let main = try mainSlice(of: page)
        let markdown = try compatibilityMarkdownSlice(of: main)

        #expect(main.contains("data-article-page=\"true\""))
        #expect(main.contains("Markdown Compatibility Lab"))
        #expect(markdown.contains("data-markdown-content=\"true\""))
        #expect(markdown.contains("compat-basic-paragraph-marker"))
        #expect(markdown.contains("compat-fenced-html-code-marker"))
    }

    @Test("compatibility lab does not affect post indexes or taxonomy listings")
    func compatibilityLabDoesNotAffectPostIndexes() async throws {
        let harness = try await publishedSite()

        let homepage = try harness.contents(of: "index.html")
        let archive = try harness.contents(of: "archive/index.html")
        let tags = try harness.contents(of: "tags/index.html")
        let categories = try harness.contents(of: "categories/index.html")
        let raptorTag = try harness.contents(of: "tags/raptor/index.html")
        let notesCategory = try harness.contents(of: "categories/notes/index.html")

        try expectCompatibilityLabAbsent(from: homepage)
        try expectCompatibilityLabAbsent(from: archive)
        try expectCompatibilityLabAbsent(from: tags)
        try expectCompatibilityLabAbsent(from: categories)
        try expectCompatibilityLabAbsent(from: raptorTag)
        try expectCompatibilityLabAbsent(from: notesCategory)
        #expect(!tags.contains("Markdown (1)"))
        #expect(!harness.fileExists("tags/markdown/index.html"))
    }

    @Test("documents supported markdown structures")
    func documentsSupportedMarkdownStructures() async throws {
        let markdown = try await compatibilityMarkdown()
        let page = try await compatibilityPage()
        let head = try headSlice(of: page)

        #expect(head.contains("href=\"/css/markdown-reading.css\""))
        #expect(markdown.contains("<h2>Basic Inline Markup</h2>"))
        #expect(markdown.contains("<strong>strong text</strong>"))
        #expect(markdown.contains("<em>emphasis</em>"))
        #expect(markdown.contains("href=\"https://example.com\""))
        #expect(markdown.contains("<code>inline code</code>"))
        #expect(markdown.contains("<img src=\"/images/tsubame-cover.svg\""))
        #expect(markdown.contains("<ol>"))
        #expect(markdown.contains("<ul>"))
        #expect(markdown.contains("<blockquote>"))
        #expect(markdown.contains("<table>"))
        #expect(markdown.contains("<hr"))
    }

    @Test("documents raw HTML and HTML code behavior")
    func documentsHTMLCompatibilityBehavior() async throws {
        let markdown = try await compatibilityMarkdown()
        let compactMarkdown = compactHTMLWhitespace(in: markdown)

        #expect(compactMarkdown.contains(#"<div data-compat-raw-html="true"> Raw HTML should render as HTML. </div>"#))
        #expect(markdown.contains(#"<span data-compat-inline-html="true">Inline HTML should render as HTML.</span>"#))
        #expect(!markdown.contains("&lt;div data-compat-raw-html="))
        #expect(!markdown.contains("&lt;span data-compat-inline-html="))
        #expect(markdown.contains("&lt;/code&gt;&lt;script&gt;alert(\"inline\")&lt;/script&gt;"))
        #expect(markdown.contains("&lt;/code&gt;&lt;script&gt;alert(\"block\")&lt;/script&gt;"))
        #expect(markdown.contains("&lt;already escaped=\"true\"&gt;"))
        #expect(!markdown.contains(#"<script>alert("inline")</script>"#))
        #expect(!markdown.contains(#"<script>alert("block")</script>"#))
        #expect(!markdown.contains("<script"))
    }

    @Test("documents current Raptor flattening of multi-paragraph list items")
    func documentsCurrentRaptorListParagraphFlattening() async throws {
        let markdown = try await compatibilityMarkdown()

        let marker = try #require(markdown.range(of: "compat-multiparagraph-list-marker"))
        let sampleEnd = try #require(markdown[marker.upperBound...].range(of: "Second item after the known bug sample"))
        let sample = String(markdown[marker.lowerBound..<sampleEnd.upperBound])

        #expect(sample.contains("<li><strong>\u{201c}Elegant\u{201d} abstractions can be misleading</strong>A unified system looks great on paper"))
        #expect(!sample.contains("<p><strong>\u{201c}Elegant\u{201d} abstractions can be misleading</strong></p>"))
        #expect(!sample.contains("<p>A unified system looks great on paper"))
    }
}

private func expectCompatibilityLabAbsent(from html: String) throws {
    #expect(!html.contains("Markdown Compatibility Lab"))
    #expect(!html.contains("Fixture for auditing Raptor Markdown compatibility in Tsubame."))
}

private func compatibilityMarkdownSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-markdown-content=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let end = html[marker.upperBound...].range(of: "data-article-navigation")?.lowerBound ?? html.endIndex
    return String(html[openStart.lowerBound..<end])
}

private func compatibilityPage() async throws -> String {
    let harness = try await publishedSite()
    return try harness.contents(of: "posts/markdown-compatibility-lab/index.html")
}

private func compatibilityMarkdown() async throws -> String {
    let page = try await compatibilityPage()
    return try compatibilityMarkdownSlice(of: try mainSlice(of: page))
}

private func headSlice(of html: String) throws -> String {
    let headOpen = try #require(html.range(of: "<head"))
    let headClose = try #require(html.range(of: "</head>"))
    return String(html[headOpen.lowerBound..<headClose.upperBound])
}

private func compactHTMLWhitespace(in html: String) -> String {
    html.split(whereSeparator: \.isWhitespace).joined(separator: " ")
}
