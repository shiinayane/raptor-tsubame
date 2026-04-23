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

    @Test("deduplicates taxonomy terms by normalized slug within a kind")
    func deduplicatesTermsByNormalizedSlug() {
        let mixedCaseTag = TaxonomyTerm(kind: .tag, name: "Raptor")
        let lowercasedTag = TaxonomyTerm(kind: .tag, name: "raptor")
        let category = TaxonomyTerm(kind: .category, name: "Raptor")

        #expect(mixedCaseTag == lowercasedTag)
        #expect(Set([mixedCaseTag, lowercasedTag]).count == 1)
        #expect(mixedCaseTag != category)
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

    @Test("loader deduplicates published terms by normalized slug")
    func loaderDeduplicatesPublishedTermsByNormalizedSlug() {
        let loader = SiteContentLoader()
        let content = [
            SiteContentDescriptor(
                sourceURL: URL(filePath: "/tmp/a.md"),
                path: nil,
                kind: .post,
                isPublished: true,
                category: "Notes",
                tags: ["Raptor", "raptor", " Swift "]
            ),
            SiteContentDescriptor(
                sourceURL: URL(filePath: "/tmp/b.md"),
                path: nil,
                kind: .post,
                isPublished: true,
                category: "notes",
                tags: ["swift", "Design"]
            ),
            SiteContentDescriptor(
                sourceURL: URL(filePath: "/tmp/c.md"),
                path: nil,
                kind: .page,
                isPublished: true,
                category: "Ignored",
                tags: ["Ignored"]
            ),
            SiteContentDescriptor(
                sourceURL: URL(filePath: "/tmp/d.md"),
                path: nil,
                kind: .post,
                isPublished: false,
                category: "Hidden",
                tags: ["Hidden"]
            )
        ]

        #expect(loader.publishedTagTerms(in: content).map(\.slug) == ["design", "raptor", "swift"])
        #expect(loader.publishedCategoryTerms(in: content).map(\.slug) == ["notes"])
    }
}
