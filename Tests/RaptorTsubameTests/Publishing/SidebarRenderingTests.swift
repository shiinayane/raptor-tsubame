import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Sidebar rendering", .serialized)
struct SidebarRenderingTests {
    @Test("homepage renders persistent sidebar blocks")
    func homepageRendersSidebarBlocks() async throws {
        let harness = try await publishedSite()

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
        let harness = try await publishedSite()

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
        let harness = try await publishedSite()

        let about = try harness.contents(of: "about/index.html")
        try expectSidebarShell(in: about)
        #expect(about.contains("About This Site"))
    }

    @Test("taxonomy detail pages inherit the shared shell")
    func taxonomyDetailPagesRenderSharedShell() async throws {
        let harness = try await publishedSite()

        let category = try harness.contents(of: "categories/updates/index.html")
        try expectSidebarShell(in: category)
        #expect(category.contains("Category: Updates"))

        let tag = try harness.contents(of: "tags/intro/index.html")
        try expectSidebarShell(in: tag)
        #expect(tag.contains("Tag: Intro"))
    }

    @Test("category detail page marks the active sidebar category")
    func categoryDetailPageMarksActiveSidebarCategory() async throws {
        let harness = try await publishedSite()
        let category = try harness.contents(of: "categories/updates/index.html")
        let sidebar = try sidebarSlice(of: category)
        let updatesCategory = try openingTag(
            containing: "data-sidebar-term-slug=\"updates\"",
            in: sidebar
        )
        let notesCategory = try openingTag(
            containing: "data-sidebar-term-slug=\"notes\"",
            in: sidebar
        )

        #expect(updatesCategory.contains("data-sidebar-nav-item=\"category\""))
        #expect(updatesCategory.contains("data-sidebar-current=\"true\""))
        #expect(updatesCategory.contains("aria-current=\"page\""))
        #expect(updatesCategory.contains("aria-label=\"Updates (1)\""))
        #expect(notesCategory.contains("data-sidebar-nav-item=\"category\""))
        #expect(notesCategory.contains("aria-label=\"Notes (2)\""))
        #expect(!notesCategory.contains("data-sidebar-current=\"true\""))
        #expect(!notesCategory.contains("aria-current=\"page\""))
    }

    @Test("tag detail page marks the active sidebar tag")
    func tagDetailPageMarksActiveSidebarTag() async throws {
        let harness = try await publishedSite()
        let tag = try harness.contents(of: "tags/intro/index.html")
        let sidebar = try sidebarSlice(of: tag)
        let introTag = try openingTag(
            containing: "data-sidebar-term-slug=\"intro\"",
            in: sidebar
        )
        let introChip = try elementSlice(
            containing: "data-sidebar-term-slug=\"intro\"",
            closingTag: "</a>",
            in: sidebar
        )
        let raptorTag = try openingTag(
            containing: "data-sidebar-term-slug=\"raptor\"",
            in: sidebar
        )

        #expect(introTag.contains("data-sidebar-tag-chip=\"true\""))
        #expect(introTag.contains("data-sidebar-current=\"true\""))
        #expect(introTag.contains("aria-current=\"page\""))
        #expect(introTag.contains("aria-label=\"Intro (1)\""))
        #expect(!introChip.contains("sidebar-count-badge-style"))
        #expect(!introChip.contains(">1</span>"))
        #expect(raptorTag.contains("data-sidebar-tag-chip=\"true\""))
        #expect(raptorTag.contains("aria-label=\"Raptor (2)\""))
        #expect(!raptorTag.contains("data-sidebar-current=\"true\""))
        #expect(!raptorTag.contains("aria-current=\"page\""))
    }

    @Test("non-taxonomy pages do not mark a sidebar current item")
    func nonTaxonomyPagesDoNotMarkSidebarCurrentItem() async throws {
        let harness = try await publishedSite()
        let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        let sidebar = try sidebarSlice(of: article)

        #expect(!sidebar.contains("data-sidebar-current=\"true\""))
        #expect(!sidebar.contains("aria-current=\"page\""))
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
    let window = html[markerRange.lowerBound...].prefix(2_048)

    for needle in needles {
        #expect(window.contains(needle))
    }
}

private func sidebarSlice(of html: String) throws -> Substring {
    let markerRange = try #require(html.range(of: "data-sidebar-container=\"true\""))
    let closeRange = try #require(html[markerRange.lowerBound...].range(of: "</aside>"))

    return html[markerRange.lowerBound..<closeRange.upperBound]
}

private func openingTag(containing marker: String, in html: Substring) throws -> Substring {
    let markerRange = try #require(html.range(of: marker))
    let openingBracket = try #require(html[..<markerRange.lowerBound].lastIndex(of: "<"))
    let closingBracket = try #require(html[markerRange.upperBound...].firstIndex(of: ">"))

    return html[openingBracket...closingBracket]
}

private func elementSlice(
    containing marker: String,
    closingTag: String,
    in html: Substring
) throws -> Substring {
    let markerRange = try #require(html.range(of: marker))
    let openingBracket = try #require(html[..<markerRange.lowerBound].lastIndex(of: "<"))
    let closingRange = try #require(html[markerRange.upperBound...].range(of: closingTag))

    return html[openingBracket..<closingRange.upperBound]
}
