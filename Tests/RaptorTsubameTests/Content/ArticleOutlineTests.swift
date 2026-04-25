import Testing
@testable import RaptorTsubame

@Suite("Article outline")
struct ArticleOutlineTests {
    @Test("slugger normalizes headings and deduplicates IDs")
    func sluggerNormalizesAndDeduplicates() {
        var slugger = ArticleHeadingSlugger()

        #expect(slugger.slug(for: "Basic Inline Markup") == "basic-inline-markup")
        #expect(slugger.slug(for: "Basic Inline Markup") == "basic-inline-markup-2")
        #expect(slugger.slug(for: "  Swift & Raptor: Notes!  ") == "swift-raptor-notes")
        #expect(slugger.slug(for: "中文 标题") == "section-1")
        #expect(slugger.slug(for: "???") == "section-2")
    }

    @Test("outline stores stable heading data")
    func outlineStoresHeadingData() {
        let outline = ArticleOutline(
            items: [
                ArticleOutlineItem(id: "intro", title: "Intro", level: .h2),
                ArticleOutlineItem(id: "details", title: "Details", level: .h3)
            ]
        )

        #expect(!outline.isEmpty)
        #expect(outline.shouldRender)
        #expect(outline.items.map(\.id) == ["intro", "details"])
        #expect(outline.items.map(\.level) == [.h2, .h3])
    }

    @Test("single heading outline does not render TOC chrome")
    func singleHeadingOutlineDoesNotRender() {
        let outline = ArticleOutline(
            items: [
                ArticleOutlineItem(id: "intro", title: "Intro", level: .h2)
            ]
        )

        #expect(!outline.isEmpty)
        #expect(!outline.shouldRender)
    }

    @Test("rendered markdown adds heading IDs and extracts outline")
    func renderedMarkdownAddsHeadingIDsAndExtractsOutline() {
        let rendered = ArticleRenderedMarkdown(
            html: """
            <div class="markdown" data-markdown-content="true">
              <h2>Basic Inline Markup</h2>
              <p>Body.</p>
              <h3>Details &amp; Examples</h3>
              <h2>Basic Inline Markup</h2>
            </div>
            """
        )

        #expect(rendered.html.contains(#"<h2 id="basic-inline-markup" data-article-heading-anchor="true">Basic Inline Markup</h2>"#))
        #expect(rendered.html.contains(#"<h3 id="details-examples" data-article-heading-anchor="true">Details &amp; Examples</h3>"#))
        #expect(rendered.html.contains(#"<h2 id="basic-inline-markup-2" data-article-heading-anchor="true">Basic Inline Markup</h2>"#))
        #expect(rendered.outline.items == [
            ArticleOutlineItem(id: "basic-inline-markup", title: "Basic Inline Markup", level: .h2),
            ArticleOutlineItem(id: "details-examples", title: "Details & Examples", level: .h3),
            ArticleOutlineItem(id: "basic-inline-markup-2", title: "Basic Inline Markup", level: .h2)
        ])
    }

    @Test("rendered markdown does not overwrite existing heading IDs")
    func renderedMarkdownPreservesExistingHeadingIDs() {
        let rendered = ArticleRenderedMarkdown(
            html: """
            <h2 id="custom-id">Custom Heading</h2>
            <h3>Child Heading</h3>
            """
        )

        #expect(rendered.html.contains(#"<h2 id="custom-id" data-article-heading-anchor="true">Custom Heading</h2>"#))
        #expect(rendered.outline.items.first?.id == "custom-id")
        #expect(rendered.outline.items.first?.title == "Custom Heading")
        #expect(rendered.outline.items.first?.level == .h2)
        #expect(rendered.outline.items.last?.id == "child-heading")
    }

    @Test("rendered markdown ignores h1 and deeper headings")
    func renderedMarkdownIgnoresUnsupportedHeadingLevels() {
        let rendered = ArticleRenderedMarkdown(
            html: """
            <h1>Page Title</h1>
            <h2>Included</h2>
            <h4>Not Included</h4>
            """
        )

        #expect(!rendered.html.contains(#"id="page-title""#))
        #expect(rendered.html.contains(#"id="included""#))
        #expect(!rendered.html.contains(#"id="not-included""#))
        #expect(rendered.outline.items.map(\.title) == ["Included"])
    }
}
