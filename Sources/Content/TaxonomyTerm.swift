import Foundation
import Raptor

enum TaxonomyKind: String, Sendable {
    case tag
    case category
}

struct TaxonomyTerm: Hashable, Sendable, Identifiable {
    let kind: TaxonomyKind
    let name: String

    var slug: String {
        name.convertedToSlug()
    }

    var id: String {
        "\(kind.rawValue):\(slug)"
    }

    var path: String {
        switch kind {
        case .tag:
            SiteRoutes.tag(slug)
        case .category:
            SiteRoutes.category(slug)
        }
    }
}
