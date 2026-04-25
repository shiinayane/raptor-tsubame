import Foundation
import Raptor

struct ArticleContent: HTML {
    let post: Post
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]
    let newer: Post?
    let older: Post?

    var body: some HTML {
        let renderedMarkdown = ArticleMarkdownSourceRenderer().render(post: post)

        Tag("article") {
            VStack(alignment: .leading, spacing: 22) {
                ArticleHeader(post: post, category: category, tags: tags)
                if let renderedMarkdown {
                    ArticleTOC(outline: renderedMarkdown.outline)
                    ArticleBody(renderedMarkdown: renderedMarkdown)
                } else {
                    ArticleBody(post: post)
                }
                ArticleNavigation(newer: newer, older: older)
            }
        }
        .style(ArticleSurfaceStyle())
        .data("article-page", "true")
    }
}
