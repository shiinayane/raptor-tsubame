import Foundation
import Raptor

struct ArticlePage: PostPage {
    private var category: TaxonomyTerm? {
        PostQueries.category(for: post)
    }

    private var tags: [TaxonomyTerm] {
        PostQueries.tags(for: post)
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 16) {
            Text(post.title)
                .font(.title1)

            PostMeta(post: post)
            TaxonomyBadgeList(category: category, tags: tags)

            MarkdownContent(post: post)
        }
    }
}
