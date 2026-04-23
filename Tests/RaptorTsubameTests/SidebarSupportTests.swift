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

    @Test("taxonomy count items preserve name count and path")
    func taxonomyCountItems() {
        let term = TaxonomyTerm(kind: .category, name: "Notes")
        let item = TaxonomyCountItem(term: term, count: 2)

        #expect(item.name == "Notes")
        #expect(item.count == 2)
        #expect(item.path == "/categories/notes/")
    }

    @Test("taxonomy count items derive the correct route for each taxonomy kind")
    func taxonomyCountItemPaths() {
        let category = TaxonomyCountItem(term: TaxonomyTerm(kind: .category, name: "Site Updates"), count: 2)
        let tag = TaxonomyCountItem(term: TaxonomyTerm(kind: .tag, name: "Raptor Notes"), count: 3)

        #expect(category.path == SiteRoutes.category("site-updates"))
        #expect(tag.path == SiteRoutes.tag("raptor-notes"))
    }

    @Test("example site name and title suffix stay aligned with the sidebar profile")
    func exampleSiteUsesProfileIdentity() {
        let site = ExampleSite()

        #expect(site.name == site.profile.name)
        #expect(site.titleSuffix == " – \(site.profile.name)")
    }
}
