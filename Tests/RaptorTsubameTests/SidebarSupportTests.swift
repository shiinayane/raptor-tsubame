import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Sidebar support", .serialized)
struct SidebarSupportTests {
    @Test("site profile provides stable default sidebar content")
    func siteProfileDefaults() {
        let profile = SiteProfile.default

        #expect(profile.name == "Raptor Tsubame")
        #expect(!profile.description.isEmpty)
        #expect(profile.avatarText == "TS")
    }

    @Test("sidebar taxonomy items preserve name count and path")
    func sidebarTaxonomyItems() {
        let term = TaxonomyTerm(kind: .category, name: "Notes")
        let item = SidebarTaxonomyItem(term: term, count: 2)

        #expect(item.name == "Notes")
        #expect(item.count == 2)
        #expect(item.path == "/categories/notes/")
    }
}
