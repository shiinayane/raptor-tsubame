import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Site publishing", .serialized)
struct SitePublishingTests {
    @Test("derives homepage pages from published posts with page size two")
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

    @Test("does not publish drafts and orders fixture posts newest first")
    func excludesDraftsAndOrdersHomepage() async throws {
        let harness = try await publishedSite()

        let homepage = try harness.contents(of: "index.html")
        let archive = try harness.contents(of: "archive/index.html")

        #expect(homepage.contains("Fuwari Study Notes"))
        #expect(!homepage.contains("Draft Hidden"))
        #expect(!archive.contains("Draft Hidden"))

        let newestFixture = try #require(archive.range(of: "Fuwari Study Notes"))
        let middleFixture = try #require(archive.range(of: "Raptor Notes"))
        let oldestFixture = try #require(archive.range(of: "Welcome To Tsubame"))
        #expect(newestFixture.lowerBound < middleFixture.lowerBound)
        #expect(middleFixture.lowerBound < oldestFixture.lowerBound)
    }

    @Test("renders second homepage page with paginated posts")
    func rendersSecondHomepagePage() async throws {
        let harness = try await publishedSite()

        let pageTwo = try harness.contents(of: "2/index.html")
        #expect(pageTwo.contains("data-post-card=\"true\""))
        #expect(!pageTwo.contains("Draft Hidden"))
    }

    @Test("homepage renders rich post card feed")
    func homepageRendersRichPostCardFeed() async throws {
        let harness = try await publishedSite()
        let homepage = try harness.contents(of: "index.html")
        let main = try mainSlice(of: homepage)
        let firstPostCard = try firstPostCardSlice(in: main)

        #expect(main.contains("data-home-feed=\"true\""))
        #expect(occurrenceCount(of: "data-post-card=\"true\"", in: main) == 2)
        #expect(main.contains("data-post-card-taxonomy=\"true\""))
        #expect(main.contains("data-post-card-stats=\"true\""))
        #expect(firstPostCard.contains("data-post-card-taxonomy=\"true\""))
        #expect(firstPostCard.contains("data-post-card-stats=\"true\""))
        #expect(!firstPostCard.contains("data-post-card-title=\"true\""))
        #expect(!firstPostCard.contains("data-post-card-meta=\"true\""))
        #expect(!firstPostCard.contains("data-post-card-description=\"true\""))
        #expect(main.contains("Building a Personal Website in Swift"))
        #expect(main.contains("Fuwari Study Notes"))
        #expect(main.contains("The first published post in the fixture set."))
        #expect(main.contains("Structural notes from studying the Fuwari theme."))
        #expect(main.contains("datetime=\"2026-04-21T00:00:00Z\""))
        #expect(main.contains("datetime=\"2026-03-01T00:00:00Z\""))
    }

    @Test("paginated homepage keeps rich feed and pagination markers")
    func paginatedHomepageKeepsRichFeedAndPaginationMarkers() async throws {
        let harness = try await publishedSite()
        let pageTwo = try harness.contents(of: "2/index.html")
        let main = try mainSlice(of: pageTwo)

        #expect(main.contains("data-home-feed=\"true\""))
        #expect(main.contains("data-post-card=\"true\""))
        #expect(main.contains("data-pagination=\"true\""))
        #expect(main.contains("data-pagination-page=\"true\""))
        #expect(main.contains("data-pagination-link=\"newer\""))
        #expect(!main.contains("data-pagination-link=\"older\""))
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

    @Test("archive renders grouped discovery entries")
    func archiveRendersGroupedDiscoveryEntries() async throws {
        let harness = try await publishedSite()

        let archive = try mainSlice(of: harness.contents(of: "archive/index.html"))
        let firstEntry = try archiveEntrySlice(containing: "Building a Personal Website in Swift", in: archive)

        #expect(archive.contains("data-archive-page=\"true\""))
        #expect(archive.contains("data-archive-year-group=\"true\""))
        #expect(archive.contains("data-archive-entry=\"true\""))
        #expect(firstEntry.contains("datetime=\"2026-04-21T00:00:00Z\""))
        #expect(firstEntry.contains("href=\"/posts/build-website-in-swift\""))
        #expect(firstEntry.contains("Building a Personal Website in Swift"))
        #expect(firstEntry.contains("The first published post in the fixture set."))
        #expect(firstEntry.contains("href=\"/categories/tech/\""))
        #expect(firstEntry.contains("href=\"/tags/swift/\""))
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
            contentNeedles: ["data-post-card=\"true\""]
        )
        try expectSharedSidebarShell(
            in: about,
            contentNeedles: ["This page is authored in Markdown."]
        )
        try expectSharedSidebarShell(
            in: tags,
            contentNeedles: ["Tags", "Design", "Raptor"]
        )
        try expectSharedSidebarShell(
            in: categories,
            contentNeedles: ["Categories", "Notes", "Updates"]
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

        let newestFixture = try mainSlice(of: harness.contents(of: "posts/fuwari-study/index.html"))
        let middle = try mainSlice(of: harness.contents(of: "posts/raptor-notes/index.html"))
        let oldest = try mainSlice(of: harness.contents(of: "posts/welcome-to-tsubame/index.html"))

        #expect(oldest.contains("data-reading-stats=\"true\""))
        #expect(oldest.contains("1 min read"))
        #expect(oldest.contains("8 words"))

        #expect(newestFixture.contains("data-article-navigation=\"true\""))
        #expect(newestFixture.contains("Older"))
        #expect(newestFixture.contains("href=\"/posts/raptor-notes\""))

        #expect(middle.contains("data-article-navigation=\"true\""))
        #expect(middle.contains("Newer"))
        #expect(middle.contains("href=\"/posts/fuwari-study\""))
        #expect(middle.contains("Older"))
        #expect(middle.contains("href=\"/posts/welcome-to-tsubame\""))
        #expect(middle.contains("data-article-navigation-link=\"newer\""))
        #expect(middle.contains("data-article-navigation-link=\"older\""))
        #expect(middle.contains("article-navigation-style"))
        #expect(middle.contains("article-navigation-row-style"))
        #expect(middle.contains("article-navigation-link-style"))

        #expect(oldest.contains("data-article-navigation=\"true\""))
        #expect(oldest.contains("Newer"))
        #expect(oldest.contains("href=\"/posts/raptor-notes\""))
        #expect(!oldest.contains("Older"))
    }

    @Test("markdown reading lab renders inline TOC")
    func articlePageRendersInlineTOC() async throws {
        let harness = try await publishedSite()

        let page = try harness.contents(of: "posts/markdown-reading-lab/index.html")
        let main = try mainSlice(of: page)
        let markdown = try markdownSlice(of: main)
        let toc = try articleTOCSlice(of: main)

        #expect(toc.contains("data-article-toc=\"true\""))
        #expect(toc.contains("data-article-toc-title=\"true\""))
        #expect(toc.contains("data-article-toc-list=\"true\""))
        #expect(toc.contains("data-article-toc-item=\"true\""))
        #expect(toc.contains("data-article-toc-level=\"h2\""))
        #expect(toc.contains("data-article-toc-level=\"h3\""))
        #expect(toc.contains("data-article-toc-link=\"true\""))
        #expect(toc.contains(#"aria-label="Contents""#))
        #expect(toc.contains("href=\"#heading-level-two\""))
        #expect(toc.contains("href=\"#heading-level-three\""))
        #expect(markdown.contains(#"<h2 id="heading-level-two" data-article-heading-anchor="true">Heading Level Two</h2>"#))
        #expect(markdown.contains(#"<h3 id="heading-level-three" data-article-heading-anchor="true">Heading Level Three</h3>"#))
    }

    @Test("short article does not render TOC chrome")
    func shortArticleDoesNotRenderTOC() async throws {
        let harness = try await publishedSite()

        let page = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        let main = try mainSlice(of: page)

        #expect(!main.contains("data-article-toc=\"true\""))
        #expect(!main.contains("article-toc-style"))
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

    @Test("shared footer renders site identity and publishing links")
    func sharedFooterRendersSiteIdentityAndPublishingLinks() async throws {
        let harness = try await publishedSite()

        let homepage = try harness.contents(of: "index.html")
        let footer = try footerSlice(of: homepage)
        let rssLink = try openingTag(containing: "data-footer-link=\"rss\"", in: footer)
        let sitemapLink = try openingTag(containing: "data-footer-link=\"sitemap\"", in: footer)
        let raptorLink = try openingTag(containing: "data-footer-link=\"raptor\"", in: footer)

        #expect(footer.contains("data-site-footer=\"true\""))
        #expect(footer.contains("Copyright 2026 Raptor Tsubame. All Rights Reserved."))
        #expect(rssLink.contains("href=\"/feed.rss\""))
        #expect(sitemapLink.contains("href=\"/sitemap.xml\""))
        #expect(raptorLink.contains("href=\"https://raptor.build\""))
        #expect(footer.contains("page-footer-style"))
        #expect(footer.contains("page-footer-links-style"))
        #expect(harness.fileExists("feed.rss"))
        #expect(harness.fileExists("sitemap.xml"))
    }

    @Test("top navigation marks active primary routes")
    func topNavigationMarksActivePrimaryRoutes() async throws {
        let harness = try await publishedSite()

        let homepage = try topNavigationSlice(of: harness.contents(of: "index.html"))
        let pageTwo = try topNavigationSlice(of: harness.contents(of: "2/index.html"))
        let archive = try topNavigationSlice(of: harness.contents(of: "archive/index.html"))
        let about = try topNavigationSlice(of: harness.contents(of: "about/index.html"))
        let post = try topNavigationSlice(of: harness.contents(of: "posts/welcome-to-tsubame/index.html"))
        let category = try topNavigationSlice(of: harness.contents(of: "categories/updates/index.html"))
        let tag = try topNavigationSlice(of: harness.contents(of: "tags/intro/index.html"))

        try expectActiveNavItem(in: homepage, item: "home", href: "/")
        try expectActiveNavItem(in: pageTwo, item: "home", href: "/")
        try expectActiveNavItem(in: archive, item: "archive", href: "/archive/")
        try expectActiveNavItem(in: about, item: "about", href: "/about/")
        #expect(occurrenceCount(of: "data-nav-current=\"true\"", in: homepage) == 1)
        #expect(occurrenceCount(of: "data-nav-current=\"true\"", in: pageTwo) == 1)
        #expect(occurrenceCount(of: "data-nav-current=\"true\"", in: archive) == 1)
        #expect(occurrenceCount(of: "data-nav-current=\"true\"", in: about) == 1)
        #expect(occurrenceCount(of: "aria-current=\"page\"", in: homepage) == 1)
        #expect(occurrenceCount(of: "aria-current=\"page\"", in: pageTwo) == 1)
        #expect(occurrenceCount(of: "aria-current=\"page\"", in: archive) == 1)
        #expect(occurrenceCount(of: "aria-current=\"page\"", in: about) == 1)
        try expectNoActivePrimaryNav(in: post)
        try expectNoActivePrimaryNav(in: category)
        try expectNoActivePrimaryNav(in: tag)
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
        let markdownReadingLab = try mainSlice(of: harness.contents(of: "posts/markdown-reading-lab/index.html"))
        let tocTag = try openingTag(containing: "data-article-toc=\"true\"", in: markdownReadingLab)

        try expectBlueThemeVisualHTML(in: homepage)
        try expectBlueThemeArchiveHTML(in: archive)
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
        #expect(tocTag.contains("article-toc-style"))
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
        #expect(markdown.contains("<ul>"))
        #expect(markdown.contains("<ol>"))
        #expect(markdown.contains("<blockquote>"))
        #expect(markdown.contains("<table>"))
        #expect(markdown.contains("<hr"))
        #expect(markdown.contains("<img src=\"/images/tsubame-cover.svg\""))
        #expect(markdown.contains("href=\"https://example.com\""))
        #expect(markdown.contains("<pre"))
        #expect(markdown.contains("language-swift"))
        #expect(markdown.contains("language-xml"))
        #expect(!markdown.contains("language-html"))
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
        #expect(htmlCodeWindow.contains("language-xml"))
        #expect(!htmlCodeWindow.contains("language-html"))
        #expect(htmlCodeWindow.contains("html-code-sample"))
        #expect(htmlCodeWindow.contains("Hello HTML"))
        #expect(htmlCodeWindow.contains("&lt;div"))
        #expect(htmlCodeWindow.contains("&lt;/div&gt;"))
        #expect(!htmlCodeWindow.contains("<div"))
        #expect(!htmlCodeWindow.contains("</div>"))
    }

    @Test("generated output includes Prism assets and syntax theme CSS")
    func generatedOutputIncludesPrismAssetsAndSyntaxThemeCSS() async throws {
        let harness = try await publishedSite()

        #expect(harness.fileExists("js/prism.js"))
        #expect(harness.fileExists("css/prism.css"))
        #expect(harness.fileExists("css/prism-themes.css"))

        let prismJS = try harness.contents(of: "js/prism.js")
        let prismCSS = try harness.contents(of: "css/prism.css")
        let prismThemeCSS = try harness.contents(of: "css/prism-themes.css")
        let markdownReadingLab = try harness.contents(of: "posts/markdown-reading-lab/index.html")

        #expect(prismJS.contains("Prism.languages.markup"))
        #expect(prismJS.contains("Prism.languages.swift"))
        #expect(prismJS.contains("languages.css"))
        #expect(prismCSS.contains("[data-highlighter-theme] pre[class*=\"language-\"]"))
        #expect(prismThemeCSS.contains(#"[data-highlighter-theme="xcode"]"#))
        #expect(prismThemeCSS.contains(#"[data-inline-highlighter-theme="xcode"]"#))
        #expect(prismThemeCSS.contains("--hl-keyword:"))
        #expect(markdownReadingLab.contains("href=\"/css/prism.css\""))
        #expect(markdownReadingLab.contains("src=\"/js/prism.js\""))
    }

    @Test("generated CSS includes scoped markdown reading rules")
    func generatedCSSIncludesMarkdownReadingRules() async throws {
        let harness = try await publishedSite()

        let css = try harness.contents(of: "css/markdown-reading.css")
        let article = try harness.contents(of: "posts/markdown-reading-lab/index.html")
        let head = try headSlice(of: article)
        let main = try mainSlice(of: article)

        #expect(head.contains("href=\"/css/markdown-reading.css\""))
        #expect(!main.contains("href=\"/css/markdown-reading.css\""))
        #expect(css.contains("[data-markdown-content=\"true\"]"))
        #expect(css.contains("--markdown-text"))
        #expect(css.contains("[data-color-scheme=\"dark\"] [data-markdown-content=\"true\"]"))
        #expect(css.contains("[data-markdown-content=\"true\"] pre"))
        #expect(css.contains("[data-markdown-content=\"true\"] :not(pre) > code"))
        #expect(css.contains("[data-markdown-content=\"true\"] table"))
    }

    @Test("generated CSS includes sidebar navigation treatments")
    func generatedCSSIncludesSidebarNavigationTreatments() async throws {
        let harness = try await publishedSite()
        let css = try harness.contents(of: "css/raptor-core.css")

        #expect(css.contains(".sidebar-section-title-style"))
        #expect(css.contains(".sidebar-nav-item-style"))
        #expect(css.contains(".sidebar-nav-label-style"))
        #expect(css.contains(".sidebar-count-badge-style"))
        #expect(css.contains(".sidebar-tag-label-style"))
        #expect(css.contains(".sidebar-tag-chip-style"))
        #expect(css.contains(".sidebar-tag-cloud-style"))

        let navItemRule = try cssRule(in: css, containing: ".sidebar-nav-item-style")
        #expect(navItemRule.contains("display: flex;"))
        #expect(navItemRule.contains("justify-content: space-between;"))
        #expect(navItemRule.contains("rgb(251 253 255 / 100%)") || navItemRule.contains("rgb(255 255 255 / 100%)"))
        #expect(navItemRule.contains("rgb(200 221 242 / 100%)") || navItemRule.contains("rgb(74 139 203 / 100%)"))

        let countBadgeRule = try cssRule(in: css, containing: ".sidebar-count-badge-style")
        #expect(countBadgeRule.contains("border-radius: 999px;"))
        #expect(countBadgeRule.contains("rgb(200 221 242 / 100%)") || countBadgeRule.contains("rgb(74 139 203 / 100%)"))

        let tagChipRule = try cssRule(in: css, containing: ".sidebar-tag-chip-style")
        #expect(tagChipRule.contains("display: inline-flex;"))
        #expect(tagChipRule.contains("border-radius: 999px;"))
        #expect(tagChipRule.contains("rgb(251 253 255 / 100%)") || tagChipRule.contains("rgb(255 255 255 / 100%)"))
        #expect(tagChipRule.contains("rgb(200 221 242 / 100%)") || tagChipRule.contains("rgb(74 139 203 / 100%)"))

        let tagCloudRule = try cssRule(in: css, containing: ".sidebar-tag-cloud-style")
        #expect(tagCloudRule.contains("display: flex;"))
        #expect(tagCloudRule.contains("flex-wrap: wrap;"))
        #expect(tagCloudRule.contains("gap: 8px;"))

        try expectDarkBlueThemeRule(in: css, containing: ".sidebar-nav-item-style") { rule in
            #expect(
                rule.contains("rgb(16 34 54 / 100%)")
                    || rule.contains("rgb(36 71 98 / 100%)")
                    || rule.contains("rgb(120 184 245 / 100%)")
            )
        }
    }

    @Test("generated CSS includes discovery styles")
    func generatedCSSIncludesDiscoveryStyles() async throws {
        let harness = try await publishedSite()
        let css = try harness.contents(of: "css/raptor-core.css")

        #expect(css.contains(".archive-discovery-page-style"))
        #expect(css.contains(".archive-year-group-style"))
        #expect(css.contains(".archive-entry-style"))
        #expect(css.contains(".archive-entry-title-style"))
        #expect(css.contains(".taxonomy-index-list-style"))
        #expect(css.contains(".taxonomy-index-summary-style"))
        #expect(css.contains(".taxonomy-index-item-style"))
        #expect(css.contains(".taxonomy-index-item-context-style"))
        #expect(css.contains(".taxonomy-detail-style"))
        #expect(css.contains(".taxonomy-detail-context-style"))
        #expect(css.contains(".taxonomy-post-list-header-style"))

        let archiveEntryRule = try cssRule(in: css, containing: ".archive-entry-style")
        #expect(archiveEntryRule.contains("border-radius: 16px;"))
        #expect(archiveEntryRule.contains("rgb(255 255 255 / 100%)"))

        let taxonomyItemRule = try cssRule(in: css, containing: ".taxonomy-index-item-style")
        #expect(taxonomyItemRule.contains("display: flex;"))
        #expect(taxonomyItemRule.contains("justify-content: space-between;"))

        try expectDarkBlueThemeRule(in: css, containing: ".archive-entry-style") { rule in
            #expect(rule.contains("rgb(16 34 54 / 100%)"))
        }
    }

    @Test("generated CSS includes chrome primitive styles")
    func generatedCSSIncludesChromePrimitiveStyles() async throws {
        let harness = try await publishedSite()
        let css = try harness.contents(of: "css/raptor-core.css")

        #expect(css.contains(".chrome-surface-style"))
        #expect(css.contains(".chrome-button-link-style"))
        #expect(css.contains(".chrome-badge-style"))
        #expect(css.contains(".chrome-section-title-style"))
        #expect(css.contains(".chrome-icon-box-style"))
        #expect(css.contains(".chrome-muted-text-style"))

        let surfaceRule = try cssRule(in: css, containing: ".chrome-surface-style")
        #expect(surfaceRule.contains("rgb(251 253 255 / 100%)"))
        #expect(surfaceRule.contains("rgb(200 221 242 / 100%)"))

        let buttonRule = try cssRule(in: css, containing: ".chrome-button-link-style")
        #expect(buttonRule.contains("text-decoration: none;"))
        #expect(buttonRule.contains("border-radius:"))

        let badgeRule = try cssRule(in: css, containing: ".chrome-badge-style")
        #expect(badgeRule.contains("border-radius: 999px;"))

        try expectDarkBlueThemeRule(in: css, containing: ".chrome-surface-style") { rule in
            #expect(rule.contains("rgb(11 23 38 / 100%)"))
            #expect(rule.contains("rgb(36 71 98 / 100%)"))
        }
    }

    @Test("generated CSS includes post card feed styles")
    func generatedCSSIncludesPostCardFeedStyles() async throws {
        let harness = try await publishedSite()
        let css = try harness.contents(of: "css/raptor-core.css")
        let paginatedHomepage = try harness.contents(of: "2/index.html")

        #expect(css.contains(".post-card-style"))
        #expect(css.contains(".post-card-taxonomy-style"))
        #expect(css.contains(".post-card-stats-style"))
        #expect(css.contains(".chrome-button-link-style"))

        if paginatedHomepage.contains("data-post-card-cover=\"true\"") {
            #expect(css.contains(".post-card-cover-style"))
            #expect(css.contains(".post-card-cover-image-style"))
        }

        try expectDarkBlueThemeRule(in: css, containing: ".post-card-stats-style") { rule in
            #expect(rule.contains("rgb(142 169 197 / 100%)"))
        }
    }

    @Test("generated CSS includes top navigation and footer chrome")
    func generatedCSSIncludesTopNavigationAndFooterChrome() async throws {
        let harness = try await publishedSite()
        let css = try harness.contents(of: "css/raptor-core.css")

        #expect(css.contains(".top-navigation-brand-style"))
        #expect(css.contains(".chrome-button-link-style"))
        #expect(css.contains(".page-footer-style"))
        #expect(css.contains(".page-footer-links-style"))
        #expect(css.contains(".page-footer-link-style"))

        let brandRule = try cssRule(in: css, containing: ".top-navigation-brand-style")
        #expect(brandRule.contains("display: inline-flex;"))
        #expect(brandRule.contains("text-decoration: none;"))
        #expect(brandRule.contains("rgb(19 40 62 / 100%)"))

        let footerRule = try cssRule(in: css, containing: ".page-footer-style")
        #expect(footerRule.contains("display: flex;"))
        #expect(footerRule.contains("border-top:"))
        #expect(footerRule.contains("rgb(88 113 139 / 100%)"))
        #expect(footerRule.contains("rgb(200 221 242 / 100%)"))

        let footerLinksRule = try cssRule(in: css, containing: ".page-footer-links-style")
        #expect(footerLinksRule.contains("justify-content: center;"))
        #expect(footerLinksRule.contains("flex-wrap: wrap;"))

        let footerLinkRule = try cssRule(in: css, containing: ".page-footer-link-style")
        #expect(footerLinkRule.contains("text-decoration: none;"))
        #expect(footerLinkRule.contains("rgb(74 139 203 / 100%)"))

        try expectDarkBlueThemeRule(in: css, containing: ".top-navigation-brand-style") { rule in
            #expect(rule.contains("rgb(220 236 255 / 100%)"))
        }

        try expectDarkBlueThemeRule(in: css, containing: ".page-footer-style") { rule in
            #expect(rule.contains("rgb(142 169 197 / 100%)"))
            #expect(rule.contains("rgb(36 71 98 / 100%)"))
        }
    }
}

private func headSlice(of html: String) throws -> String {
    let headOpen = try #require(html.range(of: "<head"))
    let headClose = try #require(html.range(of: "</head>"))
    return String(html[headOpen.lowerBound..<headClose.upperBound])
}

private func markdownSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-markdown-content=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let end = html[marker.upperBound...].range(of: "data-article-navigation")?.lowerBound ?? html.endIndex
    return String(html[openStart.lowerBound..<end])
}

private func articleTOCSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-article-toc=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let closeRange = try #require(html[marker.upperBound...].range(of: "</nav>"))
    return String(html[openStart.lowerBound..<closeRange.upperBound])
}

private func archiveEntrySlice(containing title: String, in html: String) throws -> String {
    let titleRange = try #require(html.range(of: title))
    let entryStart = try #require(html[..<titleRange.lowerBound].range(of: "data-archive-entry=\"true\"", options: .backwards))
    let openStart = try #require(html[..<entryStart.lowerBound].range(of: "<", options: .backwards))
    let afterTitle = html[titleRange.upperBound...]
    let nextEntry = afterTitle.range(of: "data-archive-entry=\"true\"")?.lowerBound
    let groupEnd = afterTitle.range(of: "data-archive-year-group=\"true\"")?.lowerBound
    let sliceEnd = nextEntry ?? groupEnd ?? html.endIndex

    return String(html[openStart.lowerBound..<sliceEnd])
}

private func firstPostCardSlice(in html: String) throws -> String {
    let marker = try #require(html.range(of: "data-post-card=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let afterMarker = html[marker.upperBound...]
    let nextCard = afterMarker.range(of: "data-post-card=\"true\"")?.lowerBound
    let feedEnd = afterMarker.range(of: "data-pagination=\"true\"")?.lowerBound
        ?? afterMarker.range(of: "</main>")?.lowerBound
        ?? html.endIndex
    let sliceEnd = nextCard ?? feedEnd

    return String(html[openStart.lowerBound..<sliceEnd])
}

private func htmlCodeBlockWindow(in markdown: String) throws -> String {
    let language = try #require(markdown.range(of: "language-xml"))
    let preStart = try #require(markdown[..<language.lowerBound].range(of: "<pre", options: .backwards))
    let preEnd = try #require(markdown[language.upperBound...].range(of: "</pre>"))
    return String(markdown[preStart.lowerBound..<preEnd.upperBound])
}

private func expectSharedNavigation(in html: String) throws {
    let nav = try topNavigationSlice(of: html)
    let navTag = try openingTag(startingWith: "<nav", in: nav)
    let brand = try openingTag(containing: "data-nav-brand=\"true\"", in: nav)

    #expect(nav.contains("data-top-navigation=\"true\""))
    #expect(openingTag(navTag, containsClass: "navbar"))
    #expect(occurrenceCount(of: "<nav", in: nav) == 1)
    try expectTopNavigationListStructure(in: nav)
    #expect(brand.contains("href=\"/\""))
    #expect(brand.contains("aria-label=\"Raptor Tsubame home\""))
    #expect(brand.contains("top-navigation-brand-style"))

    try expectLink(in: nav, label: "Home", href: "/")
    try expectLink(in: nav, label: "Archive", href: "/archive/")
    try expectLink(in: nav, label: "About", href: "/about/")
    #expect(nav.contains("data-nav-item=\"home\""))
    #expect(nav.contains("data-nav-item=\"archive\""))
    #expect(nav.contains("data-nav-item=\"about\""))
}

private func topNavigationSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-top-navigation=\"true\""))
    let navStart = try #require(html[..<marker.lowerBound].range(of: "<nav", options: .backwards))
    let navEnd = try #require(html[marker.upperBound...].range(of: "</nav>"))
    return String(html[navStart.lowerBound..<navEnd.upperBound])
}

private func footerSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-site-footer=\"true\""))
    let footerStart = try #require(html[..<marker.lowerBound].range(of: "<footer", options: .backwards))
    let closeRange = try #require(html[marker.upperBound...].range(of: "</footer>"))
    return String(html[footerStart.lowerBound..<closeRange.upperBound])
}

private func expectTopNavigationListStructure(in nav: String) throws {
    let items = listItemSlices(in: nav)
    #expect(items.count == 4)
    #expect(items.filter { $0.contains("data-nav-brand=\"true\"") }.count == 1)
    #expect(items.filter { $0.contains("data-nav-item=\"home\"") }.count == 1)
    #expect(items.filter { $0.contains("data-nav-item=\"archive\"") }.count == 1)
    #expect(items.filter { $0.contains("data-nav-item=\"about\"") }.count == 1)
}

private func listItemSlices(in html: String) -> [String] {
    html.components(separatedBy: "<li").dropFirst().compactMap { fragment in
        let candidate = "<li" + fragment
        guard let end = candidate.range(of: "</li>") else { return nil }
        return String(candidate[..<end.upperBound])
    }
}

private func expectActiveNavItem(in nav: String, item: String, href: String) throws {
    let tag = try openingTag(containing: "data-nav-item=\"\(item)\"", in: nav)
    #expect(tag.contains("href=\"\(href)\""))
    #expect(tag.contains("data-nav-current=\"true\""))
    #expect(tag.contains("aria-current=\"page\""))
}

private func expectNoActivePrimaryNav(in nav: String) throws {
    #expect(!nav.contains("data-nav-current=\"true\""))
    #expect(!nav.contains("aria-current=\"page\""))
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

private func expectBlueThemeArchiveHTML(in html: String) throws {
    try expectBlueThemeShellHTML(in: html)

    let main = try mainSlice(of: html)

    #expect(main.contains("archive-discovery-page-style"))
    #expect(main.contains("archive-year-group-style"))
    #expect(main.contains("archive-entry-style"))
    #expect(main.contains("archive-entry-title-style"))
    #expect(main.contains("data-archive-page=\"true\""))
    #expect(main.contains("data-archive-entry=\"true\""))
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
    #expect(css.contains(".article-navigation-style"))
    #expect(css.contains(".article-navigation-row-style"))
    #expect(css.contains(".article-navigation-link-style"))
    #expect(css.contains(".article-toc-style"))
    #expect(css.contains(".article-toc-title-style"))
    #expect(css.contains(".article-toc-list-style"))
    #expect(css.contains(".article-toc-item-style"))
    #expect(css.contains(".article-toc-link-style"))

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
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-navigation-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-navigation-row-style"))
    #expect(!css.contains("@media (min-width: 0px) {\n    .article-navigation-link-style"))

    let sidebarPanelRule = try cssRule(in: css, containing: ".sidebar-panel-style")
    #expect(sidebarPanelRule.contains("rgb(251 253 255 / 100%)"))
    #expect(sidebarPanelRule.contains("rgb(200 221 242 / 100%)"))
    #expect(sidebarPanelRule.contains("rgb(19 40 62 / 100%)"))

    let pageCanvasRule = try cssRule(in: css, containing: ".page-canvas-style")
    #expect(pageCanvasRule.contains("rgb(247 251 255 / 100%)"))
    #expect(!pageCanvasRule.contains("rgb(242 248 255 / 100%)"))

    let articleSurfaceRule = try cssRule(in: css, containing: ".article-surface-style")
    #expect(articleSurfaceRule.contains("rgb(251 253 255 / 100%)"))
    #expect(articleSurfaceRule.contains("rgb(200 221 242 / 100%)"))
    #expect(articleSurfaceRule.contains("rgb(19 40 62 / 100%)"))

    let tocRule = try cssRule(in: css, containing: ".article-toc-style")
    #expect(tocRule.contains("rgb(251 253 255 / 100%)"))
    #expect(tocRule.contains("rgb(200 221 242 / 100%)"))
    #expect(tocRule.contains("border-radius:"))

    let tocTitleRule = try cssRule(in: css, containing: ".article-toc-title-style")
    #expect(tocTitleRule.contains("text-transform: uppercase;"))
    #expect(tocTitleRule.contains("letter-spacing: 0.12em;"))
    #expect(tocTitleRule.contains("rgb(74 139 203 / 100%)"))

    let tocListRule = try cssRule(in: css, containing: ".article-toc-list-style")
    #expect(tocListRule.contains("list-style: none;"))
    #expect(tocListRule.contains("padding: 0px;"))

    #expect(css.contains("border-left: 3px solid rgb(74 139 203 / 100%);"))
    #expect(css.contains("padding-left: 12px;"))
    #expect(css.contains("padding-left: 28px;"))
    #expect(css.contains("rgb(88 113 139 / 100%)"))
    #expect(css.contains("rgb(142 169 197 / 100%)"))

    let tocLinkRule = try cssRule(in: css, containing: ".article-toc-link-style")
    #expect(tocLinkRule.contains("display: block;"))
    #expect(tocLinkRule.contains("line-height: 1.45;"))

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

    let navigationRowRule = try cssRule(in: css, containing: ".article-navigation-row-style")
    #expect(navigationRowRule.contains("width: 100%;"))
    #expect(navigationRowRule.contains("gap: 12px;"))
    #expect(navigationRowRule.contains("align-items: center;"))
    #expect(navigationRowRule.contains("flex-wrap: wrap;"))

    let navigationLinkRule = try cssRule(in: css, containing: ".article-navigation-link-style")
    #expect(navigationLinkRule.contains("rgb(242 248 255 / 100%)"))
    #expect(navigationLinkRule.contains("rgb(200 221 242 / 100%)"))

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
    try expectDarkBlueThemeRule(in: css, containing: ".article-navigation-link-style") { rule in
        #expect(rule.contains("rgb(16 34 54 / 100%)"))
        #expect(rule.contains("rgb(36 71 98 / 100%)"))
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
