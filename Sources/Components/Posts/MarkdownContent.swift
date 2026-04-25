import Foundation
import Raptor

struct MarkdownContent: HTML {
    private let post: Post?
    private let html: String?

    init(post: Post) {
        self.post = post
        self.html = nil
    }

    init(renderedMarkdown: ArticleRenderedMarkdown) {
        self.post = nil
        self.html = renderedMarkdown.html
    }

    var body: some HTML {
        if let html {
            html
        } else if let post {
            post.text
                .data("markdown-content", "true")
        }
    }
}
