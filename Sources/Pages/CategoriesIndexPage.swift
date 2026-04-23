import Foundation
import Raptor

struct CategoriesIndexPage: Page {
    @Environment(\.posts) private var posts

    var title: String { "Categories" }
    var path: String { SiteRoutes.categories }

    private var items: [TaxonomyIndexList.Item] {
        PostQueries.categoryGroups(posts).map { group in
            TaxonomyIndexList.Item(
                name: group.term.name,
                path: group.term.path,
                count: group.posts.count
            )
        }
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            Text("Categories").font(.title1)
            TaxonomyIndexList(items: items)
        }
    }
}
