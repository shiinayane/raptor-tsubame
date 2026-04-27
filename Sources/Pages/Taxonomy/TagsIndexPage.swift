import Foundation
import Raptor

struct TagsIndexPage: Page {
    @Environment(\.posts) private var posts

    var title: String { "Tags" }
    var path: String { SiteRoutes.tags }

    private var items: [TaxonomyIndexList.Item] {
        PostQueries.tagGroups(posts).map { group in
            TaxonomyIndexList.Item(
                name: group.term.name,
                path: group.term.path,
                count: group.posts.count
            )
        }
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            Text("Tags").font(.title1)
            TaxonomyIndexList(items: items, kind: .tag)
        }
        .data("taxonomy-index", TaxonomyKind.tag.rawValue)
    }
}
