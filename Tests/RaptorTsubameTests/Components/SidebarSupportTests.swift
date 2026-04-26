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

    @Test("sidebar selection recognizes active category routes")
    func sidebarSelectionRecognizesCategoryRoutes() {
        let selection = SidebarSelection(path: "/categories/site-updates/")
        let active = TaxonomyCountItem(term: TaxonomyTerm(kind: .category, name: "Site Updates"), count: 2)
        let inactive = TaxonomyCountItem(term: TaxonomyTerm(kind: .category, name: "Notes"), count: 1)
        let tag = TaxonomyCountItem(term: TaxonomyTerm(kind: .tag, name: "Site Updates"), count: 3)

        #expect(selection.activeCategorySlug == "site-updates")
        #expect(selection.activeTagSlug == nil)
        #expect(selection.isActive(active))
        #expect(!selection.isActive(inactive))
        #expect(!selection.isActive(tag))
    }

    @Test("sidebar selection recognizes active tag routes")
    func sidebarSelectionRecognizesTagRoutes() {
        let selection = SidebarSelection(path: "/tags/raptor-notes/")
        let active = TaxonomyCountItem(term: TaxonomyTerm(kind: .tag, name: "Raptor Notes"), count: 3)
        let inactive = TaxonomyCountItem(term: TaxonomyTerm(kind: .tag, name: "Swift"), count: 1)
        let category = TaxonomyCountItem(term: TaxonomyTerm(kind: .category, name: "Raptor Notes"), count: 2)

        #expect(selection.activeCategorySlug == nil)
        #expect(selection.activeTagSlug == "raptor-notes")
        #expect(selection.isActive(active))
        #expect(!selection.isActive(inactive))
        #expect(!selection.isActive(category))
    }

    @Test("sidebar selection ignores non-taxonomy routes")
    func sidebarSelectionIgnoresNonTaxonomyRoutes() {
        let selection = SidebarSelection(path: "/posts/welcome-to-tsubame/")
        let category = TaxonomyCountItem(term: TaxonomyTerm(kind: .category, name: "Updates"), count: 2)
        let tag = TaxonomyCountItem(term: TaxonomyTerm(kind: .tag, name: "Intro"), count: 1)

        #expect(selection.activeCategorySlug == nil)
        #expect(selection.activeTagSlug == nil)
        #expect(!selection.isActive(category))
        #expect(!selection.isActive(tag))
    }

    @Test("example site name and title suffix stay aligned with the sidebar profile")
    func exampleSiteUsesProfileIdentity() {
        var site = ExampleSite()
        site.profile = SiteProfile(
            name: "Custom Tsubame",
            description: "Custom description.",
            avatarText: "CT"
        )

        #expect(site.name == site.profile.name)
        #expect(site.titleSuffix == " – \(site.profile.name)")
    }
}
