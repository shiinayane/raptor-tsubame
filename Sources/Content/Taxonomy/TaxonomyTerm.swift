import Foundation
import Raptor

enum TaxonomyKind: String, Sendable {
    case tag
    case category

    var displayName: String {
        switch self {
        case .tag:
            "Tag"
        case .category:
            "Category"
        }
    }

    var pluralName: String {
        switch self {
        case .tag:
            "Tags"
        case .category:
            "Categories"
        }
    }
}

struct TaxonomyTerm: Sendable, Identifiable {
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

extension TaxonomyTerm: Hashable {
    static func == (lhs: TaxonomyTerm, rhs: TaxonomyTerm) -> Bool {
        lhs.kind == rhs.kind && lhs.slug == rhs.slug
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(kind)
        hasher.combine(slug)
    }
}
