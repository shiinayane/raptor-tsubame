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
}
