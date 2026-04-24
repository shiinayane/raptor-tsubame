import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Sidebar rendering", .serialized)
struct SidebarRenderingTests {
    @Test("homepage renders persistent sidebar blocks")
    func homepageRendersSidebarBlocks() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let homepage = try harness.contents(of: "index.html")
        try expectSidebarShell(in: homepage)
        try expectSidebarSection(
            in: homepage,
            marker: "data-sidebar-profile",
            contains: ["Raptor Tsubame"]
        )
        try expectSidebarSection(
            in: homepage,
            marker: "data-sidebar-categories",
            contains: ["Categories"]
        )
        try expectSidebarSection(
            in: homepage,
            marker: "data-sidebar-tags",
            contains: ["Tags"]
        )
    }

    @Test("article page renders shared shell and sidebar taxonomy blocks")
    func articlePageRendersSharedShellAndSidebar() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        try expectSidebarShell(in: article)
        try expectSidebarSection(
            in: article,
            marker: "data-sidebar-categories",
            contains: ["Categories", "href=\"/categories/updates/\"", "Updates"]
        )
        try expectSidebarSection(
            in: article,
            marker: "data-sidebar-tags",
            contains: ["Tags", "href=\"/tags/intro/\"", "Intro"]
        )
    }

    @Test("about page also renders inside the shared shell")
    func aboutPageRendersSharedShell() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let about = try harness.contents(of: "about/index.html")
        try expectSidebarShell(in: about)
        #expect(about.contains("About This Site"))
    }

    @Test("taxonomy detail pages inherit the shared shell")
    func taxonomyDetailPagesRenderSharedShell() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let category = try harness.contents(of: "categories/updates/index.html")
        try expectSidebarShell(in: category)
        #expect(category.contains("Category: Updates"))

        let tag = try harness.contents(of: "tags/intro/index.html")
        try expectSidebarShell(in: tag)
        #expect(tag.contains("Tag: Intro"))
    }
}

private func expectSidebarShell(in html: String) throws {
    let main = try mainSlice(of: html)

    #expect(occurrenceCount(of: "data-sidebar-shell=\"true\"", in: main) == 1)
    #expect(main.contains("data-sidebar-container=\"true\""))
    #expect(main.contains("data-sidebar-profile"))
    #expect(main.contains("data-sidebar-categories"))
    #expect(main.contains("data-sidebar-tags"))
    #expect(main.contains("data-sidebar-position=\"leading\""))

    try expectSidebarMarkerOwnership(in: main)
}

private func expectSidebarSection(
    in html: String,
    marker: String,
    contains needles: [String]
) throws {
    let markerRange = try #require(html.range(of: marker))
    let window = html[markerRange.lowerBound...].prefix(768)

    for needle in needles {
        #expect(window.contains(needle))
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
