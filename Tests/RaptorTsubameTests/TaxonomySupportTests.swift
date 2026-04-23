import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Taxonomy support", .serialized)
struct TaxonomySupportTests {
    @Test("normalizes taxonomy names into slugged routes")
    func normalizesTaxonomyTerms() {
        let tag = TaxonomyTerm(kind: .tag, name: "Raptor Notes")
        let category = TaxonomyTerm(kind: .category, name: "Site Updates")

        #expect(tag.slug == "raptor-notes")
        #expect(tag.path == SiteRoutes.tag("raptor-notes"))
        #expect(category.slug == "site-updates")
        #expect(category.path == SiteRoutes.category("site-updates"))
    }

    @Test("loader extracts category and tags from post front matter")
    func loaderExtractsTaxonomyMetadata() throws {
        let loader = SiteContentLoader()
        let descriptors = try loader.load(from: packageRoot())

        let raptorNotes = try #require(descriptors.first {
            $0.sourceURL.lastPathComponent == "raptor-notes.md"
        })

        #expect(raptorNotes.category == "Notes")
        #expect(raptorNotes.tags == ["Raptor", "Swift"])
    }
}
