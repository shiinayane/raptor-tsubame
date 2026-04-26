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

        #expect(sidebar.contains("data-sidebar-nav-item=\"category\""))
        #expect(sidebar.contains("data-sidebar-term-slug=\"updates\""))
        #expect(sidebar.contains("data-sidebar-current=\"true\""))
        #expect(sidebar.contains("aria-current=\"page\""))
        #expect(!sidebar.contains("data-sidebar-tag-chip=\"true\" aria-current=\"page\""))
    }

    @Test("tag detail page marks the active sidebar tag")
    func tagDetailPageMarksActiveSidebarTag() async throws {
        let harness = try await publishedSite()
        let tag = try harness.contents(of: "tags/intro/index.html")
        let sidebar = try sidebarSlice(of: tag)

        #expect(sidebar.contains("data-sidebar-tag-chip=\"true\""))
        #expect(sidebar.contains("data-sidebar-term-slug=\"intro\""))
        #expect(sidebar.contains("data-sidebar-current=\"true\""))
        #expect(sidebar.contains("aria-current=\"page\""))
        #expect(!sidebar.contains("data-sidebar-nav-item=\"category\" aria-current=\"page\""))
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
    let window = html[markerRange.lowerBound...].prefix(768)

    for needle in needles {
        #expect(window.contains(needle))
    }
}

private func sidebarSlice(of html: String) throws -> Substring {
    let markerRange = try #require(html.range(of: "data-sidebar-container=\"true\""))
    let closeRange = try #require(html[markerRange.lowerBound...].range(of: "</aside>"))

    return html[markerRange.lowerBound..<closeRange.upperBound]
}
