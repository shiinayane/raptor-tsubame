import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Site publishing", .serialized)
struct SitePublishingTests {
    @Test("derives two homepage pages from three published posts with page size two")
    func derivesHomepagePageCount() async throws {
        var site = ExampleSite()
        try await site.prepare()

        #expect(site.homePage.totalPages == 2)
        #expect(site.generatedPages.contains { $0.path == "/2/" })
    }

    @Test("publishes homepage pagination, archive, about, and post routes")
    func publishesPrimaryRoutes() async throws {
        let harness = try await publishedSite()

        #expect(harness.fileExists("index.html"))
        #expect(harness.fileExists("2/index.html"))
        #expect(harness.fileExists("archive/index.html"))
        #expect(harness.fileExists("about/index.html"))
        #expect(harness.fileExists("posts/welcome-to-tsubame/index.html"))
    }

    @Test("does not publish drafts and orders homepage newest first")
    func excludesDraftsAndOrdersHomepage() async throws {
        let harness = try await publishedSite()

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
        let harness = try await publishedSite()

        let pageTwo = try harness.contents(of: "2/index.html")
        #expect(pageTwo.contains("Welcome To Tsubame"))
        #expect(!pageTwo.contains("Raptor Notes"))
    }

    @Test("archive contains all published posts")
    func archiveContainsAllPublishedPosts() async throws {
        let harness = try await publishedSite()

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
        let harness = try await publishedSite()

        let about = try harness.contents(of: "about/index.html")
        #expect(about.contains("About This Site"))
        #expect(about.contains("This page is authored in Markdown."))
    }

    @Test("homepage about tags and categories render inside the shared sidebar shell")
    func rendersSharedSidebarShellAcrossMajorRoutes() async throws {
        let harness = try await publishedSite()

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
        let harness = try await publishedSite()

        let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        let main = try mainSlice(of: article)
        #expect(main.contains("data-article-page=\"true\""))
        #expect(main.contains("data-article-header=\"true\""))
        #expect(main.contains("data-article-title=\"true\""))
        #expect(main.contains("data-article-title-accent=\"true\""))
        #expect(main.contains("<span class=\"article-title-accent-style"))
        #expect(!main.contains("<p class=\"article-title-accent-style"))
        #expect(main.contains("data-article-metadata-row=\"true\""))
        #expect(main.contains("data-article-meta-item=\"reading-words\""))
        #expect(main.contains("data-article-meta-item=\"reading-minutes\""))
        #expect(main.contains("data-article-meta-item=\"published\""))
        #expect(main.contains("data-article-meta-item=\"updated\""))
        #expect(main.contains("data-article-meta-item=\"lang\""))
        #expect(main.contains("data-article-meta-item=\"category\""))
        #expect(main.contains("data-article-meta-item=\"tags\""))
        #expect(main.contains("2026-02-01"))
        #expect(main.contains("data-article-meta-content=\"lang\""))
        #expect(main.contains(">en<"))
        #expect(main.contains("data-article-cover=\"true\""))
        #expect(main.contains("tsubame-cover"))
        #expect(main.contains("data-article-body=\"true\""))
        #expect(main.contains("data-markdown-content=\"true\""))
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
        #expect(occurrenceCount(of: "datetime=\"2026-01-01T00:00:00Z\"", in: main) == 1)
        #expect(main.contains("The first published post in the fixture set."))
        #expect(main.contains("data-article-description=\"true\""))
        #expect(main.contains("data-reading-stats=\"true\""))
        #expect(!main.contains("data-post-meta=\"true\""))
        #expect(main.contains("href=\"/categories/updates/\""))
        #expect(main.contains("href=\"/tags/intro/\""))

        // Site chrome should still include the site name.
        #expect(article.contains("Raptor Tsubame"))

        let articleWithoutCover = try mainSlice(of: harness.contents(of: "posts/raptor-notes/index.html"))
        #expect(!articleWithoutCover.contains("data-article-cover=\"true\""))
    }

    @Test("article page renders reading stats and adjacent post navigation")
    func rendersArticleReadingStatsAndAdjacentNavigation() async throws {
        let harness = try await publishedSite()

        let newest = try mainSlice(of: harness.contents(of: "posts/fuwari-study/index.html"))
        let middle = try mainSlice(of: harness.contents(of: "posts/raptor-notes/index.html"))
        let oldest = try mainSlice(of: harness.contents(of: "posts/welcome-to-tsubame/index.html"))

        #expect(oldest.contains("data-reading-stats=\"true\""))
        #expect(oldest.contains("1 min read"))
        #expect(oldest.contains("8 words"))

        #expect(newest.contains("data-article-navigation=\"true\""))
        #expect(newest.contains("Older"))
        #expect(newest.contains("href=\"/posts/raptor-notes\""))
        #expect(!newest.contains("Newer"))

        #expect(middle.contains("data-article-navigation=\"true\""))
        #expect(middle.contains("Newer"))
        #expect(middle.contains("href=\"/posts/fuwari-study\""))
        #expect(middle.contains("Older"))
        #expect(middle.contains("href=\"/posts/welcome-to-tsubame\""))

        #expect(oldest.contains("data-article-navigation=\"true\""))
        #expect(oldest.contains("Newer"))
        #expect(oldest.contains("href=\"/posts/raptor-notes\""))
        #expect(!oldest.contains("Older"))
    }

    @Test("homepage and about include shared navigation")
    func includesSharedNavigation() async throws {
        let harness = try await publishedSite()

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
        let harness = try await publishedSite()

        let css = try harness.contents(of: "css/raptor-core.css")
        try expectResponsiveShellCSS(in: css)
        try expectBlueThemeVisualCSS(in: css)
    }

    @Test("published pages include blue theme visual styles")
    func publishedPagesIncludeBlueThemeVisualStyles() async throws {
        let harness = try await publishedSite()

        let homepage = try harness.contents(of: "index.html")
        let archive = try harness.contents(of: "archive/index.html")
        let about = try harness.contents(of: "about/index.html")
        let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")

        try expectBlueThemeVisualHTML(in: homepage)
        try expectBlueThemeVisualHTML(in: archive)
        try expectBlueThemeShellHTML(in: about)
        try expectBlueThemeShellHTML(in: article)
        #expect(article.contains("page-canvas-style"))
        #expect(article.contains("sidebar-panel-style"))
        #expect(article.contains("metadata-text-style"))
        #expect(article.contains("article-surface-style"))
        #expect(article.contains("article-header-style"))
        #expect(article.contains("article-title-block-style"))
        #expect(article.contains("article-title-accent-style"))
        #expect(article.contains("article-metadata-item-style"))
        #expect(article.contains("article-reading-icon-style"))
        #expect(article.contains("article-metadata-icon-style"))
        #expect(article.contains("article-cover-style"))
        #expect(article.contains("article-body-style"))
        #expect(article.contains("data-article-page=\"true\""))
        #expect(article.contains("data-article-header=\"true\""))
        #expect(article.contains("data-article-body=\"true\""))
        #expect(article.contains("data-markdown-content=\"true\""))
        #expect(article.contains("data-article-description=\"true\""))
        #expect(article.contains("data-article-meta-icon=\"true\""))
    }

    @Test("article markdown lab publishes scoped reading markup")
    func publishesMarkdownReadingLab() async throws {
        let harness = try await publishedSite()

        #expect(harness.fileExists("posts/markdown-reading-lab/index.html"))

        let page = try harness.contents(of: "posts/markdown-reading-lab/index.html")
        let main = try mainSlice(of: page)
        let markdown = try markdownSlice(of: main)

        #expect(main.contains("data-article-page=\"true\""))
        #expect(markdown.contains("data-markdown-content=\"true\""))
        #expect(markdown.contains("<h2>Heading Level Two</h2>"))
        #expect(markdown.contains("<h3>Heading Level Three</h3>"))
        #expect(markdown.contains("<ul>"))
        #expect(markdown.contains("<ol>"))
        #expect(markdown.contains("<blockquote>"))
        #expect(markdown.contains("<table>"))
        #expect(markdown.contains("<hr"))
        #expect(markdown.contains("<img src=\"/images/tsubame-cover.svg\""))
        #expect(markdown.contains("href=\"https://example.com\""))
        #expect(markdown.contains("<pre"))
        #expect(markdown.contains("language-swift"))
        #expect(markdown.contains("language-html"))
    }

    @Test("markdown HTML code remains visible while raw HTML stays raw")
    func keepsMarkdownHTMLCodeVisible() async throws {
        let harness = try await publishedSite()

        let page = try harness.contents(of: "posts/markdown-reading-lab/index.html")
        let markdown = try markdownSlice(of: try mainSlice(of: page))

        #expect(markdown.contains("data-raw-html-fixture=\"true\""))
        #expect(markdown.contains("&lt;span"))
        #expect(markdown.contains("inline-html-code"))
        #expect(markdown.contains("inline&lt;/span&gt;"))

        let htmlCodeWindow = try htmlCodeBlockWindow(in: markdown)
        #expect(htmlCodeWindow.contains("language-html"))
        #expect(htmlCodeWindow.contains("html-code-sample"))
        #expect(htmlCodeWindow.contains("Hello HTML"))
        #expect(htmlCodeWindow.contains("&lt;div"))
        #expect(htmlCodeWindow.contains("&lt;/div&gt;"))
        #expect(!htmlCodeWindow.contains("<div"))
        #expect(!htmlCodeWindow.contains("</div>"))
    }

    @Test("generated CSS includes scoped markdown reading rules")
    func generatedCSSIncludesMarkdownReadingRules() async throws {
        let harness = try await publishedSite()

        let css = try harness.contents(of: "css/raptor-core.css")

        #expect(css.contains("[data-markdown-content=\"true\"]"))
        #expect(css.contains("--markdown-text"))
        #expect(css.contains("[data-color-scheme=\"dark\"] [data-markdown-content=\"true\"]"))
        #expect(css.contains("[data-markdown-content=\"true\"] pre"))
        #expect(css.contains("[data-markdown-content=\"true\"] :not(pre) > code"))
        #expect(css.contains("[data-markdown-content=\"true\"] table"))
    }
}

private func markdownSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-markdown-content=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let end = html[marker.upperBound...].range(of: "data-article-navigation")?.lowerBound ?? html.endIndex
    return String(html[openStart.lowerBound..<end])
}

private func htmlCodeBlockWindow(in markdown: String) throws -> String {
    let language = try #require(markdown.range(of: "language-html"))
    let preStart = try #require(markdown[..<language.lowerBound].range(of: "<pre", options: .backwards))
    let preEnd = try #require(markdown[language.upperBound...].range(of: "</pre>"))
    return String(markdown[preStart.lowerBound..<preEnd.upperBound])
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

private func expectBlueThemeVisualHTML(in html: String) throws {
    try expectBlueThemeShellHTML(in: html)

    let main = try mainSlice(of: html)

    #expect(main.contains("post-card-style"))
    #expect(main.contains("content-surface-style"))
    #expect(main.contains("metadata-text-style"))
    #expect(main.contains("data-post-card=\"true\""))
    #expect(main.contains("data-post-meta=\"true\""))
}

private func expectBlueThemeShellHTML(in html: String) throws {
    try expectBlueThemePageBackground(in: html)

    let main = try mainSlice(of: html)
    let pageCanvasTag = try openingTag(containingClass: "page-canvas-style", in: main)
    let siteShellTag = try openingTag(containingClass: "site-shell", in: main)
    let pageCanvasRange = try #require(main.range(of: pageCanvasTag))
    let siteShellRange = try #require(main.range(of: siteShellTag))

    #expect(pageCanvasTag.contains("page-canvas-style"))
    #expect(siteShellTag.contains("site-shell"))
    #expect(pageCanvasRange.lowerBound < siteShellRange.lowerBound)
    #expect(!siteShellTag.contains("page-canvas-style"))
    #expect(main.contains("sidebar-panel-style"))
}

private func expectBlueThemePageBackground(in html: String) throws {
    let htmlTag = try openingTag(startingWith: "<html", in: html)
    #expect(htmlTag.contains("data-theme=\"site-theme\""))
    #expect(!htmlTag.contains("--bg-page:"))
}

private func expectResponsiveShellCSS(in css: String) throws {
    #expect(!css.contains("@media (min-width: 0px) {\n    .site-shell-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .shell-main-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .shell-sidebar-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .sidebar-panel-style"))

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

    let regularPanel = try cssWindow(
        in: css,
        from: "@media (min-width: 575px)",
        containing: ".sidebar-panel-style"
    )
    #expect(regularPanel.contains("padding: 18px;"))
    #expect(regularPanel.contains("box-shadow:"))
}

private func expectBlueThemeVisualCSS(in css: String) throws {
    #expect(css.contains(".page-canvas-style"))
    #expect(css.contains(".post-card-style"))
    #expect(css.contains(".content-surface-style"))
    #expect(css.contains(".metadata-text-style"))
    #expect(css.contains(".sidebar-panel-style"))
    #expect(css.contains(".article-surface-style"))
    #expect(css.contains(".article-header-style"))
    #expect(css.contains(".article-title-block-style"))
    #expect(css.contains(".article-title-accent-style"))
    #expect(css.contains(".article-metadata-item-style"))
    #expect(css.contains(".article-reading-icon-style"))
    #expect(css.contains(".article-metadata-icon-style"))
    #expect(css.contains(".article-cover-style"))
    #expect(css.contains(".article-body-style"))

    #expect(css.contains("rgb(247 251 255 / 100%)"))
    #expect(css.contains("rgb(242 248 255 / 100%)"))
    #expect(css.contains("rgb(251 253 255 / 100%)"))
    #expect(css.contains("rgb(200 221 242 / 100%)"))
    #expect(css.contains("rgb(19 40 62 / 100%)"))
    #expect(css.contains("rgb(88 113 139 / 100%)"))
    #expect(css.contains("box-shadow:"))

    #expect(!css.contains("@media (min-width: 0px) {\n    .page-canvas-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .post-card-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .content-surface-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .metadata-text-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .sidebar-panel-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-surface-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-header-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-title-block-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-title-accent-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-metadata-item-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-reading-icon-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-metadata-icon-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-cover-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-body-style"))

    let sidebarPanelRule = try cssRule(in: css, containing: ".sidebar-panel-style")
    #expect(sidebarPanelRule.contains("rgb(251 253 255 / 100%)"))
    #expect(sidebarPanelRule.contains("rgb(200 221 242 / 100%)"))
    #expect(sidebarPanelRule.contains("rgb(19 40 62 / 100%)"))

    let articleSurfaceRule = try cssRule(in: css, containing: ".article-surface-style")
    #expect(articleSurfaceRule.contains("rgb(251 253 255 / 100%)"))
    #expect(articleSurfaceRule.contains("rgb(200 221 242 / 100%)"))
    #expect(articleSurfaceRule.contains("rgb(19 40 62 / 100%)"))

    let readingIconRule = try cssRule(in: css, containing: ".article-reading-icon-style")
    #expect(readingIconRule.contains("align-items: center;"))
    #expect(readingIconRule.contains("justify-content: center;"))
    #expect(readingIconRule.contains("width: 24px;"))
    #expect(readingIconRule.contains("height: 24px;"))

    let metadataIconRule = try cssRule(in: css, containing: ".article-metadata-icon-style")
    #expect(metadataIconRule.contains("align-items: center;"))
    #expect(metadataIconRule.contains("justify-content: center;"))
    #expect(metadataIconRule.contains("width: 32px;"))
    #expect(metadataIconRule.contains("height: 32px;"))
    #expect(metadataIconRule.contains("rgb(74 139 203 / 100%)"))

    try expectDarkBlueThemeRule(in: css, containing: ".page-canvas-style") { rule in
        #expect(rule.contains("rgb(7 17 29 / 100%)"))
    }
    try expectDarkBlueThemeRule(in: css, containing: ".content-surface-style") { rule in
        #expect(rule.contains("rgb(11 23 38 / 100%)"))
        #expect(rule.contains("rgb(36 71 98 / 100%)"))
    }
    try expectDarkBlueThemeRule(in: css, containing: ".post-card-style") { rule in
        #expect(rule.contains("rgb(220 236 255 / 100%)"))
    }
    try expectDarkBlueThemeRule(in: css, containing: ".metadata-text-style") { rule in
        #expect(rule.contains("rgb(142 169 197 / 100%)"))
    }
    try expectDarkBlueThemeRule(in: css, containing: ".sidebar-panel-style") { rule in
        #expect(rule.contains("rgb(11 23 38 / 100%)"))
        #expect(rule.contains("rgb(36 71 98 / 100%)"))
        #expect(rule.contains("rgb(220 236 255 / 100%)"))
    }
    try expectDarkBlueThemeRule(in: css, containing: ".article-surface-style") { rule in
        #expect(rule.contains("rgb(11 23 38 / 100%)"))
        #expect(rule.contains("rgb(36 71 98 / 100%)"))
        #expect(rule.contains("rgb(220 236 255 / 100%)"))
    }
    try expectDarkBlueThemeRule(in: css, containing: ".article-header-style") { rule in
        #expect(rule.contains("rgb(36 71 98 / 100%)"))
    }
    try expectDarkBlueThemeRule(in: css, containing: ".article-metadata-icon-style") { rule in
        #expect(rule.contains("rgb(120 184 245 / 100%)"))
    }
    try expectDarkBlueThemeRule(in: css, containing: ".article-body-style") { rule in
        #expect(rule.contains("rgb(220 236 255 / 100%)"))
    }
    try expectDarkThemeVariables(in: css)
}

private func expectDarkThemeVariables(in css: String) throws {
    let rule = try cssRule(in: css, containing: #"[data-theme="site-theme"][data-color-scheme="dark"]"#)
    #expect(rule.contains("--bg-page: rgb(7 17 29 / 100%);"))
}

private func expectDarkBlueThemeRule(
    in css: String,
    containing selectorNeedle: String,
    assertions: (String) throws -> Void
) throws {
    let rule = try cssRule(in: css, containing: "[data-color-scheme=\"dark\"] \(selectorNeedle)")
    try assertions(rule)
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

private func cssRule(in css: String, containing selectorNeedle: String) throws -> String {
    let selectorRange = try #require(css.range(of: selectorNeedle))
    let ruleOpen = try #require(css[selectorRange.lowerBound...].firstIndex(of: "{"))
    var depth = 0
    var index = ruleOpen

    while index < css.endIndex {
        if css[index] == "{" {
            depth += 1
        } else if css[index] == "}" {
            depth -= 1
            if depth == 0 {
                return String(css[selectorRange.lowerBound...index])
            }
        }

        index = css.index(after: index)
    }

    let missingRule: String? = nil
    return try #require(missingRule)
}
