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
        try expectSharedSidebarShell(
            in: archive,
            contentNeedles: ["Welcome To Tsubame", "Raptor Notes", "Fuwari Study Notes"]
        )
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

    @Test("homepage about tags and categories render inside the shared sidebar shell")
    func rendersSharedSidebarShellAcrossMajorRoutes() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let homepage = try harness.contents(of: "index.html")
        let about = try harness.contents(of: "about/index.html")
        let tags = try harness.contents(of: "tags/index.html")
        let categories = try harness.contents(of: "categories/index.html")

        try expectSharedSidebarShell(
            in: homepage,
            contentNeedles: ["Fuwari Study Notes", "Raptor Notes"]
        )
        try expectSharedSidebarShell(
            in: about,
            contentNeedles: ["This page is authored in Markdown."]
        )
        try expectSharedSidebarShell(
            in: tags,
            contentNeedles: ["Tags", "Design (1)", "Raptor (2)"]
        )
        try expectSharedSidebarShell(
            in: categories,
            contentNeedles: ["Categories", "Notes (2)", "Updates (1)"]
        )
    }

    @Test("article page renders markdown body and metadata")
    func rendersArticlePage() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        let main = try mainSlice(of: article)
        try expectSharedSidebarShell(
            in: article,
            contentNeedles: ["Welcome To Tsubame", "The first published post in the fixture set."]
        )

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

    @Test("generated shell CSS keeps desktop layout behind regular breakpoint")
    func generatedShellCSSKeepsDesktopLayoutBehindRegularBreakpoint() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let css = try harness.contents(of: "css/raptor-core.css")
        try expectResponsiveShellCSS(in: css)
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

private func expectResponsiveShellCSS(in css: String) throws {
    #expect(!css.contains("@media (min-width: 0px) {\n    .site-shell-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .shell-main-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .shell-sidebar-style"))

    let regularShell = try cssWindow(
        in: css,
        from: "@media (min-width: 575px)",
        containing: ".site-shell-style"
    )
    #expect(regularShell.contains("flex-direction: row;"))
    #expect(regularShell.contains("max-width: 1120px;"))

    let regularSidebar = try cssWindow(
        in: css,
        from: "@media (min-width: 575px)",
        containing: ".shell-sidebar-style"
    )
    #expect(regularSidebar.contains("order: -1;"))
    #expect(regularSidebar.contains("flex-basis: 280px;"))
    #expect(regularSidebar.contains("width: 280px;"))

    let regularMain = try cssWindow(
        in: css,
        from: "@media (min-width: 575px)",
        containing: ".shell-main-style"
    )
    #expect(regularMain.contains("flex-basis: 0px;"))
    #expect(regularMain.contains("max-width: 760px;"))
}

private func cssWindow(
    in css: String,
    from mediaNeedle: String,
    containing selectorNeedle: String
) throws -> String {
    var searchStart = css.startIndex

    while let mediaRange = css.range(of: mediaNeedle, range: searchStart..<css.endIndex) {
        let window = try cssBlock(startingAt: mediaRange.lowerBound, in: css)

        if window.contains(selectorNeedle) {
            return window
        }

        searchStart = mediaRange.upperBound
    }

    let missingWindow: String? = nil
    return try #require(missingWindow)
}

private func cssBlock(startingAt start: String.Index, in css: String) throws -> String {
    let blockOpen = try #require(css[start...].firstIndex(of: "{"))
    var depth = 0
    var index = blockOpen

    while index < css.endIndex {
        if css[index] == "{" {
            depth += 1
        } else if css[index] == "}" {
            depth -= 1
            if depth == 0 {
                return String(css[start...index])
            }
        }

        index = css.index(after: index)
    }

    let missingBlock: String? = nil
    return try #require(missingBlock)
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
