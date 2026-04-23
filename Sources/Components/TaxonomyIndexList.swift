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

    var body: some HTML {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                TaxonomyIndexItem(name: item.name, path: item.path, count: item.count)
            }
        }
    }
}
