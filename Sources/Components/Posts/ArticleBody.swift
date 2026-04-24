import Foundation
import Raptor

struct ArticleBody: HTML {
    let post: Post

    var body: some HTML {
        Tag("div") {
            MarkdownContent(post: post)
        }
        .style(ArticleBodyStyle())
        .data("article-body", "true")
    }
}
