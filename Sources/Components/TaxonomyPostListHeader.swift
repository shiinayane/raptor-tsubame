import Foundation
import Raptor

struct TaxonomyPostListHeader: HTML {
    let title: String
    let count: Int

    var body: some HTML {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.title1)
            Text("\(count) posts")
        }
    }
}
