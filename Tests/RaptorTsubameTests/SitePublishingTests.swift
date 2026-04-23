import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Site publishing", .serialized)
struct SitePublishingTests {
    @Test("derives two homepage pages from three published posts with page size two")
    func derivesHomepagePageCount() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        var site = ExampleSite()
        try await site.prepare()

        #expect(site.homePage.totalPages == 2)
        #expect(site.generatedPages.contains { $0.path == "/2/" })
    }

    @Test("publishes homepage pagination, archive, about, and post routes")
    func publishesPrimaryRoutes() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        #expect(harness.fileExists("index.html"))
        #expect(harness.fileExists("2/index.html"))
        #expect(harness.fileExists("archive/index.html"))
        #expect(harness.fileExists("about/index.html"))
        #expect(harness.fileExists("posts/welcome-to-tsubame/index.html"))
    }

    @Test("does not publish drafts and orders homepage newest first")
    func excludesDraftsAndOrdersHomepage() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let homepage = try harness.contents(of: "index.html")
        let pageTwo = try harness.contents(of: "2/index.html")

        #expect(homepage.contains("Fuwari Study Notes"))
        #expect(homepage.contains("Raptor Notes"))
        #expect(!homepage.contains("Draft Hidden"))
        #expect(pageTwo.contains("Welcome To Tsubame"))

        let first = try #require(homepage.range(of: "Fuwari Study Notes"))
        let second = try #require(homepage.range(of: "Raptor Notes"))
        #expect(first.lowerBound < second.lowerBound)
    }

    @Test("renders second homepage page with only the remaining posts")
    func rendersSecondHomepagePage() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let pageTwo = try harness.contents(of: "2/index.html")
        #expect(pageTwo.contains("Welcome To Tsubame"))
        #expect(!pageTwo.contains("Raptor Notes"))
    }

    @Test("archive contains all published posts")
    func archiveContainsAllPublishedPosts() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let archive = try harness.contents(of: "archive/index.html")
        #expect(archive.contains("data-sidebar-shell"))
        #expect(archive.contains("data-sidebar-profile"))
        #expect(archive.contains("data-sidebar-categories"))
        #expect(archive.contains("data-sidebar-tags"))
        #expect(archive.contains("Welcome To Tsubame"))
        #expect(archive.contains("Raptor Notes"))
        #expect(archive.contains("Fuwari Study Notes"))
    }

    @Test("renders about from markdown content")
    func rendersAboutFromMarkdown() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let about = try harness.contents(of: "about/index.html")
        #expect(about.contains("About This Site"))
        #expect(about.contains("This page is authored in Markdown."))
    }

    @Test("article page renders markdown body and metadata")
    func rendersArticlePage() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        let main = try mainSlice(of: article)

        // Avoid duplicated title from both the page chrome and the markdown body.
        #expect(occurrenceCount(of: "Welcome To Tsubame", in: main) == 1)

        // Body content comes from the markdown fixture.
        #expect(main.contains("This is the first published post."))

        // PostMeta should render visible metadata in the page body.
        #expect(main.contains("<time"))
        #expect(main.contains("The first published post in the fixture set."))

        // Site chrome should still include the site name.
        #expect(article.contains("Raptor Tsubame"))
    }

    @Test("homepage and about include shared navigation")
    func includesSharedNavigation() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let homepage = try harness.contents(of: "index.html")
        let pageTwo = try harness.contents(of: "2/index.html")
        let archive = try harness.contents(of: "archive/index.html")
        let about = try harness.contents(of: "about/index.html")
        let post = try harness.contents(of: "posts/welcome-to-tsubame/index.html")

        try expectSharedNavigation(in: homepage)
        try expectSharedNavigation(in: pageTwo)
        try expectSharedNavigation(in: archive)
        try expectSharedNavigation(in: about)
        try expectSharedNavigation(in: post)

        try expectFooterOutsideMain(in: homepage)
    }
}

private func expectSharedNavigation(in html: String) throws {
    try expectLink(in: html, label: "Home", href: "/")
    try expectLink(in: html, label: "Archive", href: "/archive/")
    try expectLink(in: html, label: "About", href: "/about/")
    try expectOneNavLinkPerListItem(in: html)
}

private func expectOneNavLinkPerListItem(in html: String) throws {
    let navStart = try #require(html.range(of: "<nav"))
    let navEnd = try #require(html.range(of: "</nav>"))
    let nav = String(html[navStart.lowerBound..<navEnd.upperBound])

    let listItemFragments = nav.components(separatedBy: "<li").dropFirst()
    var listItems: [String] = []
    listItems.reserveCapacity(listItemFragments.count)

    for fragment in listItemFragments {
        let candidate = "<li" + fragment
        guard let end = candidate.range(of: "</li>") else { continue }
        listItems.append(String(candidate[..<end.upperBound]))
    }

    #expect(listItems.count == 3)

    let expectedHrefs = ["/", "/archive/", "/about/"]
    for href in expectedHrefs {
        let matches = listItems.filter { $0.contains("href=\"\(href)\"") }
        #expect(matches.count == 1)
    }

    // Ensure each item doesn't contain multiple nav destinations.
    for item in listItems {
        let hrefCount = expectedHrefs.reduce(into: 0) { count, href in
            if item.contains("href=\"\(href)\"") { count += 1 }
        }
        #expect(hrefCount == 1)
    }
}

private func expectLink(
    in html: String,
    label: String,
    href: String
) throws {
    let hrefNeedle = "href=\"\(href)\""
    let labelNeedle = ">\(label)<"

    let hrefRange = try #require(html.range(of: hrefNeedle))

    // Tighten enough to avoid unrelated text matches without depending on exact HTML formatting.
    let window = html[hrefRange.upperBound...].prefix(512)
    #expect(window.contains(labelNeedle))
}

private func expectFooterOutsideMain(in html: String) throws {
    let mainOpen = try #require(html.range(of: "<main"))
    let mainClose = try #require(html.range(of: "</main>"))

    let footer = try #require(html.range(of: "<footer"))
    #expect(footer.lowerBound > mainClose.upperBound)

    let mainSlice = html[mainOpen.lowerBound..<mainClose.upperBound]
    #expect(!mainSlice.contains("<footer"))
}

private func mainSlice(of html: String) throws -> String {
    let mainOpen = try #require(html.range(of: "<main"))
    let mainClose = try #require(html.range(of: "</main>"))
    return String(html[mainOpen.lowerBound..<mainClose.upperBound])
}

private func occurrenceCount(of needle: String, in haystack: String) -> Int {
    guard !needle.isEmpty else { return 0 }
    return haystack.components(separatedBy: needle).count - 1
}
