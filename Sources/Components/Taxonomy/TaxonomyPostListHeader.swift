import Foundation
import Raptor

struct TaxonomyPostListHeader: HTML {
    let kind: TaxonomyKind
    let termName: String
    let count: Int

    var body: some HTML {
        VStack(alignment: .leading, spacing: 6) {
            Text(kind.displayName)
                .style(TaxonomyDetailContextStyle())
            Text("\(kind.displayName): \(termName)").font(.title1)
            Text("\(count) \(count == 1 ? "post" : "posts")")
        }
        .style(TaxonomyPostListHeaderStyle())
        .data("taxonomy-detail-header", "true")
    }
}
