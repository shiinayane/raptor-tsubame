import Foundation
import Raptor

struct ArticlePage: PostPage {
    @Environment(\.posts) private var posts

    private var category: TaxonomyTerm? {
        PostQueries.category(for: post)
    }

    private var tags: [TaxonomyTerm] {
        PostQueries.tags(for: post)
    }

    private var adjacentPosts: (newer: Post?, older: Post?) {
        PostQueries.adjacentPosts(to: post, in: posts)
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 16) {
            Text(post.title)
                .font(.title1)

            PostMeta(post: post)
            ArticleReadingStats(post: post)
            TaxonomyBadgeList(category: category, tags: tags)

            MarkdownContent(post: post)
            ArticleNavigation(newer: adjacentPosts.newer, older: adjacentPosts.older)
        }
    }
}
