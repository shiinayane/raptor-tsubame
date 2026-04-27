import Foundation
import Raptor

struct TagPage: Page {
    @Environment(\.posts) private var posts

    let term: TaxonomyTerm

    var title: String { "Tag: \(term.name)" }
    var path: String { term.path }

    private var tagPosts: [Post] {
        PostQueries.posts(tagged: term.slug, in: posts)
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            TaxonomyPostListHeader(kind: .tag, termName: term.name, count: tagPosts.count)
            PostList(posts: tagPosts)
        }
        .style(TaxonomyDetailStyle())
        .data("taxonomy-detail", TaxonomyKind.tag.rawValue)
    }
}
