import Foundation
import Raptor

struct ArticleBody: HTML {
    let renderedMarkdown: ArticleRenderedMarkdown

    var body: some HTML {
        Tag("div") {
            MarkdownContent(renderedMarkdown: renderedMarkdown)
        }
        .style(ArticleBodyStyle())
        .data("article-body", "true")
    }
}
