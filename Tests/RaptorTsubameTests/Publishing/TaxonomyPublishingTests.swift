import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Taxonomy publishing", .serialized)
struct TaxonomyPublishingTests {
    @Test("publishes tag routes")
    func publishesTagRoutes() async throws {
        let harness = try await publishedSite()

        #expect(harness.fileExists("tags/index.html"))
        #expect(harness.fileExists("tags/raptor/index.html"))
        #expect(harness.fileExists("tags/design/index.html"))
    }

    @Test("publishes category routes")
    func publishesCategoryRoutes() async throws {
        let harness = try await publishedSite()

        #expect(harness.fileExists("categories/index.html"))
        #expect(harness.fileExists("categories/notes/index.html"))
        #expect(harness.fileExists("categories/updates/index.html"))
    }

    @Test("renders tag index and detail pages")
    func rendersTagIndexAndDetailPages() async throws {
        let harness = try await publishedSite()

        let tags = try harness.contents(of: "tags/index.html")
        try expectSharedSidebarShell(
            in: tags,
            contentNeedles: ["Tags", "Design", "Raptor"]
        )
        #expect(tags.contains("data-taxonomy-index=\"tag\""))
        #expect(tags.contains("data-taxonomy-index-item=\"tag\""))
        #expect(tags.contains("10 tags"))
        #expect(tags.contains(">Tag<"))
        #expect(tags.contains(">Design<"))
        #expect(tags.contains(">Raptor<"))
        #expect(tags.contains("href=\"/tags/design/\""))
        #expect(tags.contains("href=\"/tags/raptor/\""))
        #expect(tags.contains(">1 post<"))
        #expect(tags.contains(">2 posts<"))

        let raptor = try harness.contents(of: "tags/raptor/index.html")
        try expectSharedSidebarShell(
            in: raptor,
            contentNeedles: ["Tag: Raptor", "Raptor Notes", "Fuwari Study Notes"]
        )
        #expect(raptor.contains("data-taxonomy-detail=\"tag\""))
        #expect(raptor.contains("data-taxonomy-detail-header=\"true\""))
        #expect(raptor.contains("Raptor Notes"))
        #expect(raptor.contains("Fuwari Study Notes"))
        #expect(!raptor.contains("Welcome To Tsubame"))
    }

    @Test("renders category index and detail pages")
    func rendersCategoryIndexAndDetailPages() async throws {
        let harness = try await publishedSite()

        let categories = try harness.contents(of: "categories/index.html")
        try expectSharedSidebarShell(
            in: categories,
            contentNeedles: ["Categories", "Notes", "Updates"]
        )
        #expect(categories.contains("data-taxonomy-index=\"category\""))
        #expect(categories.contains("data-taxonomy-index-item=\"category\""))
        #expect(categories.contains("3 categories"))
        #expect(categories.contains(">Category<"))
        #expect(categories.contains(">Notes<"))
        #expect(categories.contains(">Updates<"))
        #expect(categories.contains("href=\"/categories/notes/\""))
        #expect(categories.contains("href=\"/categories/updates/\""))
        #expect(categories.contains(">1 post<"))
        #expect(categories.contains(">2 posts<"))

        let notes = try harness.contents(of: "categories/notes/index.html")
        try expectSharedSidebarShell(
            in: notes,
            contentNeedles: ["Category: Notes", "Raptor Notes", "Fuwari Study Notes"]
        )
        #expect(notes.contains("data-taxonomy-detail=\"category\""))
        #expect(notes.contains("data-taxonomy-detail-header=\"true\""))
        #expect(notes.contains("Raptor Notes"))
        #expect(notes.contains("Fuwari Study Notes"))
        #expect(!notes.contains("Welcome To Tsubame"))
    }

    @Test("article page shows category and tag links")
    func articlePageShowsTaxonomyLinks() async throws {
        let harness = try await publishedSite()

        let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        #expect(article.contains("href=\"/categories/updates/\""))
        #expect(article.contains("href=\"/tags/intro/\""))
        #expect(article.contains("href=\"/tags/site/\""))
        #expect(article.contains(">Updates<"))
        #expect(article.contains(">Intro<"))
        #expect(article.contains(">Site<"))
    }
}

private func expectSharedSidebarShell(
    in html: String,
    contentNeedles: [String]
) throws {
    let main = try mainSlice(of: html)

    #expect(occurrenceCount(of: "data-sidebar-shell=\"true\"", in: main) == 1)
    #expect(try openingTag(containingClass: "site-shell", in: main).contains("site-shell"))
    #expect(main.contains("data-shell-layout=\"two-column\""))
    #expect(main.contains("data-sidebar-position=\"leading\""))
    #expect(main.contains("data-sidebar-container=\"true\""))
    #expect(main.contains("data-sidebar-profile"))
    #expect(main.contains("data-sidebar-categories"))
    #expect(main.contains("data-sidebar-tags"))

    try expectSidebarMarkerOwnership(in: main)

    for needle in contentNeedles {
        #expect(main.contains(needle))
    }
}
