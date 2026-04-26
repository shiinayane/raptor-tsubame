import Foundation

struct NavigationSelection: Equatable, Sendable {
    enum Item: String, Sendable {
        case home
        case archive
        case about
    }

    let activeItem: Item?

    init(path: String) {
        let normalizedPath = Self.normalized(path)

        if normalizedPath == SiteRoutes.archive {
            self.activeItem = .archive
        } else if normalizedPath == SiteRoutes.about {
            self.activeItem = .about
        } else if normalizedPath == SiteRoutes.home || Self.isPaginatedHome(normalizedPath) {
            self.activeItem = .home
        } else {
            self.activeItem = nil
        }
    }

    func isActive(_ item: NavigationItem) -> Bool {
        activeItem == item.id
    }

    private static func normalized(_ path: String) -> String {
        guard path.hasSuffix("/") else {
            return path + "/"
        }

        return path
    }

    private static func isPaginatedHome(_ path: String) -> Bool {
        let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return !trimmed.isEmpty && trimmed.allSatisfy(\.isNumber)
    }
}
