import Foundation
import Raptor

struct ArticleContent: HTML {
    let post: Post
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]
    let newer: Post?
    let older: Post?

    var body: some HTML {
        let renderedMarkdown = ArticleRenderedMarkdown(
            html: renderedHTML(
                from: post.text
                    .data("markdown-content", "true")
            )
        )

        Tag("article") {
            VStack(alignment: .leading, spacing: 22) {
                ArticleHeader(post: post, category: category, tags: tags)
                ArticleTOC(outline: renderedMarkdown.outline)
                ArticleBody(renderedMarkdown: renderedMarkdown)
                ArticleNavigation(newer: newer, older: older)
            }
        }
        .style(ArticleSurfaceStyle())
        .data("article-page", "true")
    }
}
