import Foundation

struct SidebarSelection: Equatable, Sendable {
    let activeCategorySlug: String?
    let activeTagSlug: String?

    init(path: String) {
        let normalizedPath = SidebarSelection.normalized(path)

        if let slug = SidebarSelection.slug(in: normalizedPath, after: "/categories/") {
            self.activeCategorySlug = slug
            self.activeTagSlug = nil
        } else if let slug = SidebarSelection.slug(in: normalizedPath, after: "/tags/") {
            self.activeCategorySlug = nil
            self.activeTagSlug = slug
        } else {
            self.activeCategorySlug = nil
            self.activeTagSlug = nil
        }
    }

    func isActive(_ item: TaxonomyCountItem) -> Bool {
        switch item.term.kind {
        case .category:
            item.term.slug == activeCategorySlug
        case .tag:
            item.term.slug == activeTagSlug
        }
    }

    private static func normalized(_ path: String) -> String {
        guard path.hasSuffix("/") else {
            return path + "/"
        }

        return path
    }

    private static func slug(in path: String, after prefix: String) -> String? {
        guard path.hasPrefix(prefix) else {
            return nil
        }

        let remainder = path.dropFirst(prefix.count)
        let slug = remainder.split(separator: "/", omittingEmptySubsequences: true).first

        return slug.map(String.init)
    }
}
