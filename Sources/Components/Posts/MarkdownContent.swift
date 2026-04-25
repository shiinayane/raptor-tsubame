import Foundation
import Raptor

struct MarkdownContent: HTML {
    private let html: String

    init(post: Post) {
        self.html = renderedHTML(
            from: post.text
                .data("markdown-content", "true")
        )
    }

    init(renderedMarkdown: ArticleRenderedMarkdown) {
        self.html = renderedMarkdown.html
    }

    var body: some HTML {
        html
    }
}

func renderedHTML(from html: some HTML) -> String {
    let markup = html.render()

    // Raptor exposes Markup publicly, but its backing HTML string is package-scoped.
    return Mirror(reflecting: markup).children.first { child in
        child.label == "string"
    }?.value as? String ?? ""
}
