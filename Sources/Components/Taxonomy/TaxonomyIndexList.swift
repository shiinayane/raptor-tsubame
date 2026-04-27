import Foundation
import Raptor

struct TaxonomyIndexList: HTML {
    struct Item: Identifiable {
        let name: String
        let path: String
        let count: Int

        var id: String { path }
    }

    let items: [Item]
    let kind: TaxonomyKind

    var body: some HTML {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(items.count) \(kind.pluralName.lowercased())")
                .style(TaxonomyIndexSummaryStyle())
            ForEach(items) { item in
                TaxonomyIndexItem(name: item.name, path: item.path, count: item.count, kind: kind)
            }
        }
        .style(TaxonomyIndexListStyle())
    }
}
