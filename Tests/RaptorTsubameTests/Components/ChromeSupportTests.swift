import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Chrome support")
struct ChromeSupportTests {
    @Test("navigation selection marks home routes")
    func navigationSelectionMarksHomeRoutes() {
        #expect(NavigationSelection(path: "/").activeItem == .home)
        #expect(NavigationSelection(path: "/2/").activeItem == .home)
        #expect(NavigationSelection(path: "/12").activeItem == .home)
    }

    @Test("navigation selection marks archive and about routes")
    func navigationSelectionMarksArchiveAndAboutRoutes() {
        #expect(NavigationSelection(path: "/archive/").activeItem == .archive)
        #expect(NavigationSelection(path: "/archive").activeItem == .archive)
        #expect(NavigationSelection(path: "/about/").activeItem == .about)
        #expect(NavigationSelection(path: "/about").activeItem == .about)
    }

    @Test("navigation selection ignores content and taxonomy routes")
    func navigationSelectionIgnoresContentAndTaxonomyRoutes() {
        #expect(NavigationSelection(path: "/posts/welcome-to-tsubame/").activeItem == nil)
        #expect(NavigationSelection(path: "/categories/tech/").activeItem == nil)
        #expect(NavigationSelection(path: "/tags/swift/").activeItem == nil)
    }

    @Test("navigation item exposes stable primary links")
    func navigationItemExposesStablePrimaryLinks() {
        #expect(NavigationItem.primary.map(\.id) == [.home, .archive, .about])
        #expect(NavigationItem.primary.map(\.label) == ["Home", "Archive", "About"])
        #expect(NavigationItem.primary.map(\.path) == ["/", "/archive/", "/about/"])
    }
}
