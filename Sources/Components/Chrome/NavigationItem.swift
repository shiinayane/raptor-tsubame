import Foundation

struct NavigationItem: Equatable, Identifiable, Sendable {
    let id: NavigationSelection.Item
    let label: String
    let path: String

    static let primary: [NavigationItem] = [
        NavigationItem(id: .home, label: "Home", path: SiteRoutes.home),
        NavigationItem(id: .archive, label: "Archive", path: SiteRoutes.archive),
        NavigationItem(id: .about, label: "About", path: SiteRoutes.about)
    ]
}
