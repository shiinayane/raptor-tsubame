import Foundation
import Raptor

struct CategoryTermPage: Page {
    @Environment(\.posts) private var posts

    let term: TaxonomyTerm

    var title: String { "Category: \(term.name)" }
    var path: String { term.path }

    private var categoryPosts: [Post] {
        PostQueries.posts(inCategory: term.slug, posts: posts)
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            TaxonomyPostListHeader(title: "Category: \(term.name)", count: categoryPosts.count)
            PostList(posts: categoryPosts)
        }
    }
}
