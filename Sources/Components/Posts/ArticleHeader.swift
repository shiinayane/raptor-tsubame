import Foundation
import Raptor

struct ArticleHeader: HTML {
    let post: Post
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 16) {
            ArticleReadingStats(post: post)
            ArticleTitleBlock(title: post.title)
            ArticleMetadataRow(post: post, category: category, tags: tags)

            if !post.description.isEmpty {
                Text(post.description)
                    .style(MetadataTextStyle())
                    .data("article-description", "true")
            }

            ArticleCover(post: post)
        }
        .style(ArticleHeaderStyle())
        .data("article-header", "true")
    }
}
