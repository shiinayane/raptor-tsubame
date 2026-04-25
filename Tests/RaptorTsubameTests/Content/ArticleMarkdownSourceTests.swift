import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Article Markdown source rendering")
struct ArticleMarkdownSourceTests {
    @Test("renders article markdown from source without Raptor Markup extraction")
    func rendersArticleMarkdownFromSource() throws {
        let renderer = ArticleMarkdownSourceRenderer(rootDirectory: packageRoot())
        let rendered = try #require(renderer.render(path: "/posts/markdown-reading-lab/"))

        #expect(rendered.html.contains("data-markdown-content=\"true\""))
        #expect(rendered.html.contains(#"<h2 id="heading-level-two" data-article-heading-anchor="true">Heading Level Two</h2>"#))
        #expect(rendered.outline.items.map(\.id) == ["heading-level-two", "heading-level-three"])
    }
}
