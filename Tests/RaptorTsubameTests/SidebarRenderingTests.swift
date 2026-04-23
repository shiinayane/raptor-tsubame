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
        #expect(homepage.contains("Raptor Tsubame"))
        #expect(homepage.contains("Categories"))
        #expect(homepage.contains("Tags"))
    }

    @Test("article page renders shared shell and sidebar taxonomy blocks")
    func articlePageRendersSharedShellAndSidebar() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        try expectSidebarShell(in: article)
        #expect(article.contains("Categories"))
        #expect(article.contains("Updates"))
        #expect(article.contains("Tags"))
        #expect(article.contains("Intro"))
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
