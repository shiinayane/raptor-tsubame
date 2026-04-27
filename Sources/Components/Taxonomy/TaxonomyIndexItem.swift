import Foundation
import Raptor

struct TaxonomyIndexItem: HTML {
    let name: String
    let path: String
    let count: Int
    let kind: TaxonomyKind

    var body: some HTML {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text(kind.displayName)
                    .style(TaxonomyIndexItemContextStyle())
                Link(name, destination: path)
                    .style(TaxonomyIndexItemLinkStyle())
                Text("\(count) \(count == 1 ? "post" : "posts")")
                    .style(TaxonomyIndexItemCountStyle())
            }
        }
            .style(TaxonomyIndexItemStyle())
            .data("taxonomy-index-item", kind.rawValue)
    }
}
