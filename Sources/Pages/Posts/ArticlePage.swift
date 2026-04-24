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
        ArticleContent(
            post: post,
            category: category,
            tags: tags,
            newer: adjacentPosts.newer,
            older: adjacentPosts.older
        )
    }
}
