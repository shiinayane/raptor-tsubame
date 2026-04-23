import Foundation
import Raptor

struct TaxonomyBadgeList: HTML {
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            if let category {
                HStack(spacing: 8) {
                    Text("Category")
                    Link(category.name, destination: category.path)
                }
            }

            if !tags.isEmpty {
                HStack(spacing: 8) {
                    Text("Tags")
                    ForEach(tags) { tag in
                        Link(tag.name, destination: tag.path)
                    }
                }
            }
        }
    }
}
