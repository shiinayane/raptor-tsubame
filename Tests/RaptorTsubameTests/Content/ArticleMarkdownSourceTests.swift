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

    @Test("expands supported Raptor include tokens before rendering article source")
    func expandsSupportedIncludeTokens() throws {
        let root = try makeTemporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        let sources = root.appending(path: "Sources")
        let posts = root.appending(path: "Posts/posts")
        try FileManager.default.createDirectory(at: sources, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: posts, withIntermediateDirectories: true)

        try """
        import Foundation

        struct IncludedSnippet {
            let value = "<escaped>"
        }
        """.write(to: sources.appending(path: "snippet.swift"), atomically: false, encoding: .utf8)

        try """

        ### Included Text Heading

        Included text body.

        """.write(to: sources.appending(path: "include.md"), atomically: false, encoding: .utf8)

        try """
        ---
        title: Include Demo
        path: /posts/include-demo/
        ---

        ## Include Demo

        @{text:include.md}

        @{code:noimports:snippet.swift}

        $@{text:include.md}
        """.write(to: posts.appending(path: "include-demo.md"), atomically: false, encoding: .utf8)

        let renderer = ArticleMarkdownSourceRenderer(rootDirectory: root)
        let rendered = try #require(renderer.render(path: "/posts/include-demo/"))

        #expect(rendered.html.contains(#"<h3 id="included-text-heading" data-article-heading-anchor="true">Included Text Heading</h3>"#))
        #expect(rendered.html.contains("Included text body."))
        #expect(rendered.html.contains("struct IncludedSnippet"))
        #expect(rendered.html.contains("&lt;escaped&gt;"))
        #expect(!rendered.html.contains("import Foundation"))
        #expect(rendered.html.contains("@{text:include.md}"))
    }
}
