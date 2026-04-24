import Foundation
import Raptor

struct ArticleHeader: HTML {
    let post: Post
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.title)
                .font(.title1)

            PostMeta(post: post)
            ArticleReadingStats(post: post)
            TaxonomyBadgeList(category: category, tags: tags)
        }
        .style(ArticleHeaderStyle())
        .data("article-header", "true")
    }
}
