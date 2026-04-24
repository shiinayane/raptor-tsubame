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
            contentNeedles: ["Tags", "Design (1)", "Raptor (2)"]
        )
        #expect(tags.contains("Design (1)"))
        #expect(tags.contains("Raptor (2)"))

        let raptor = try harness.contents(of: "tags/raptor/index.html")
        try expectSharedSidebarShell(
            in: raptor,
            contentNeedles: ["Tag: Raptor", "Raptor Notes", "Fuwari Study Notes"]
        )
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
            contentNeedles: ["Categories", "Notes (2)", "Updates (1)"]
        )
        #expect(categories.contains("Notes (2)"))
        #expect(categories.contains("Updates (1)"))

        let notes = try harness.contents(of: "categories/notes/index.html")
        try expectSharedSidebarShell(
            in: notes,
            contentNeedles: ["Category: Notes", "Raptor Notes", "Fuwari Study Notes"]
        )
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

private func mainSlice(of html: String) throws -> String {
    let mainOpen = try #require(html.range(of: "<main"))
    let mainClose = try #require(html.range(of: "</main>"))
    return String(html[mainOpen.lowerBound..<mainClose.upperBound])
}

private func expectSidebarMarkerOwnership(in main: String) throws {
    let siteShellTag = try openingTag(containingClass: "site-shell", in: main)
    let sidebarContainerTag = try sidebarContainerOpeningTag(in: main)

    #expect(siteShellTag.contains("data-sidebar-shell=\"true\""))
    #expect(sidebarContainerTag.contains("data-sidebar-container=\"true\""))
    #expect(!sidebarContainerTag.contains("data-sidebar-shell=\"true\""))
}

private func sidebarContainerOpeningTag(in html: String) throws -> String {
    if let containerRange = html.range(of: "data-sidebar-container=\"true\"") {
        return try openingTag(containing: containerRange.lowerBound, in: html)
    }

    return try openingTag(startingWith: "<aside", in: html)
}

private func openingTag(containing needle: String, in html: String) throws -> String {
    let needleRange = try #require(html.range(of: needle))
    return try openingTag(containing: needleRange.lowerBound, in: html)
}

private func openingTag(containingClass className: String, in html: String) throws -> String {
    var searchStart = html.startIndex

    while let classRange = html.range(of: className, range: searchStart..<html.endIndex) {
        let tag = try openingTag(containing: classRange.lowerBound, in: html)

        if openingTag(tag, containsClass: className) {
            return tag
        }

        searchStart = classRange.upperBound
    }

    let missingTag: String? = nil
    return try #require(missingTag)
}

private func openingTag(_ tag: String, containsClass className: String) -> Bool {
    guard let attributeStart = tag.range(of: "class=\"") else { return false }
    let classStart = attributeStart.upperBound
    guard let classEnd = tag[classStart...].firstIndex(of: "\"") else { return false }
    let classes = tag[classStart..<classEnd].split(separator: " ")
    return classes.contains(Substring(className))
}

private func openingTag(containing index: String.Index, in html: String) throws -> String {
    let beforeNeedle = html[..<index]
    let afterNeedle = html[index...]
    let open = try #require(beforeNeedle.lastIndex(of: "<"))
    let close = try #require(afterNeedle.firstIndex(of: ">"))
    return String(html[open...close])
}

private func openingTag(startingWith prefix: String, in html: String) throws -> String {
    let open = try #require(html.range(of: prefix))
    let afterOpen = html[open.lowerBound...]
    let close = try #require(afterOpen.firstIndex(of: ">"))
    return String(html[open.lowerBound...close])
}

private func occurrenceCount(of needle: String, in haystack: String) -> Int {
    guard !needle.isEmpty else { return 0 }
    return haystack.components(separatedBy: needle).count - 1
}
