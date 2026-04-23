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
}

private func expectSidebarShell(in html: String) throws {
    #expect(html.contains("data-sidebar-shell"))
    #expect(html.contains("data-sidebar-profile"))
    #expect(html.contains("data-sidebar-categories"))
    #expect(html.contains("data-sidebar-tags"))
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
