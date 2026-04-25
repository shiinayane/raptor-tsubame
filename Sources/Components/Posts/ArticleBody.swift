import Foundation
import Raptor

struct ArticleBody: HTML {
    private let post: Post?
    private let renderedMarkdown: ArticleRenderedMarkdown?

    init(post: Post) {
        self.post = post
        self.renderedMarkdown = nil
    }

    init(renderedMarkdown: ArticleRenderedMarkdown) {
        self.post = nil
        self.renderedMarkdown = renderedMarkdown
    }

    var body: some HTML {
        Tag("div") {
            if let renderedMarkdown {
                MarkdownContent(renderedMarkdown: renderedMarkdown)
            } else if let post {
                MarkdownContent(post: post)
            }
        }
        .style(ArticleBodyStyle())
        .data("article-body", "true")
    }
}
