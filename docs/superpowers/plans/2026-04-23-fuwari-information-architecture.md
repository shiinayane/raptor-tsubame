# Fuwari Information Architecture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first-pass Fuwari-inspired information architecture in Raptor with Markdown-backed posts, paginated homepage routes, article pages, archive, about, and a shared top-level navigation layout.

**Architecture:** Keep Markdown in `Posts/` as the single content source, split content filtering/aggregation into focused helpers under `Sources/Content`, generate homepage pagination state in `ExampleSite.prepare()`, and render all views through reusable layout/components rather than page-level styling logic. The site stays intentionally narrow: one main layout, one post template, three static aggregate pages, and integration tests that verify published output paths and content.

**Tech Stack:** Swift 6.2, Raptor 0.1.2, Swift Testing (`Testing`), Markdown front matter under `Posts/`

---

## File Structure

### Existing files to modify

- `Package.swift`
  Adds the package test target.
- `Sources/Site.swift`
  Replaces the starter site with the real site configuration, generated pagination state, and `prepare()` orchestration.
- `Sources/Layouts/MainLayout.swift`
  Evolves from the starter shell into the shared site layout.
- `Posts/Posts.txt`
  Remove the starter placeholder once real Markdown fixtures exist.

### New source files

- `Sources/Content/SiteContentKind.swift`
  Declares semantic content kinds and metadata keys.
- `Sources/Content/SiteContentLoader.swift`
  Lightweight front-matter scanner used during `prepare()` to derive pagination state without page-level parsing.
- `Sources/Content/PostQueries.swift`
  Render-time helpers for filtering `Environment.posts`, building archive groups, and resolving standalone pages.
- `Sources/Components/TopNavigation.swift`
  Shared top navigation used by all first-pass pages.
- `Sources/Components/PageFooter.swift`
  Shared footer block.
- `Sources/Components/PostMeta.swift`
  Reusable article metadata block.
- `Sources/Components/PostList.swift`
  Homepage/archive list wrapper.
- `Sources/Components/PostListItem.swift`
  Individual post summary item.
- `Sources/Components/PaginationControls.swift`
  Homepage pagination UI.
- `Sources/Components/ArchiveList.swift`
  Archive grouped list renderer.
- `Sources/Components/MarkdownContent.swift`
  Shared wrapper for rendering Markdown-backed standalone page content.
- `Sources/Pages/HomePage.swift`
  Paginated homepage page type.
- `Sources/Pages/ArchivePage.swift`
  Archive page.
- `Sources/Pages/AboutPage.swift`
  Markdown-backed about page.
- `Sources/Pages/ArticlePage.swift`
  The site-wide `PostPage` implementation.

### New tests

- `Tests/RaptorTsubameTests/TestSupport.swift`
  Helpers for publishing the site into a test build directory and reading generated files.
- `Tests/RaptorTsubameTests/SitePublishingTests.swift`
  Integration tests for routes, filtering, ordering, and Markdown-backed pages.

### New Markdown content

- `Posts/posts/welcome-to-tsubame.md`
- `Posts/posts/raptor-notes.md`
- `Posts/posts/fuwari-study.md`
- `Posts/pages/about.md`
- `Posts/pages/draft-hidden.md`

These fixtures seed enough content to exercise homepage pagination, archive completeness, About page resolution, and `published: false` exclusion.

---

### Task 1: Add Test Harness And Real Markdown Fixtures

**Files:**
- Modify: `Package.swift`
- Modify: `Posts/Posts.txt`
- Create: `Posts/posts/welcome-to-tsubame.md`
- Create: `Posts/posts/raptor-notes.md`
- Create: `Posts/posts/fuwari-study.md`
- Create: `Posts/pages/about.md`
- Create: `Posts/pages/draft-hidden.md`
- Create: `Tests/RaptorTsubameTests/TestSupport.swift`
- Create: `Tests/RaptorTsubameTests/SitePublishingTests.swift`

- [ ] **Step 1: Write the failing integration tests**

```swift
import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Site publishing")
struct SitePublishingTests {
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

    @Test("renders about from markdown content")
    func rendersAboutFromMarkdown() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let about = try harness.contents(of: "about/index.html")
        #expect(about.contains("About This Site"))
        #expect(about.contains("This page is authored in Markdown."))
    }
}
```

- [ ] **Step 2: Add the test target and support harness**

```swift
// Package.swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RaptorTsubame",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(
            url: "https://github.com/raptor-build/raptor.git",
            from: "0.1.2"
        )
    ],
    targets: [
        .executableTarget(
            name: "RaptorTsubame",
            dependencies: [
                .product(name: "Raptor", package: "Raptor")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "RaptorTsubameTests",
            dependencies: ["RaptorTsubame"]
        )
    ]
)
```

```swift
// Tests/RaptorTsubameTests/TestSupport.swift
import Foundation
@testable import RaptorTsubame

struct TestPublishHarness {
    let buildDirectory: URL

    init() throws {
        let root = URL(filePath: FileManager.default.currentDirectoryPath)
        self.buildDirectory = root
            .appending(path: ".build")
            .appending(path: "raptor-tsubame-test-site")

        cleanup()
    }

    func publish() async throws {
        var site = ExampleSite()
        try await site.publish(buildDirectoryPath: ".build/raptor-tsubame-test-site")
    }

    func fileExists(_ relativePath: String) -> Bool {
        FileManager.default.fileExists(atPath: buildDirectory.appending(path: relativePath).path())
    }

    func contents(of relativePath: String) throws -> String {
        try String(contentsOf: buildDirectory.appending(path: relativePath), encoding: .utf8)
    }

    func cleanup() {
        try? FileManager.default.removeItem(at: buildDirectory)
    }
}
```

- [ ] **Step 3: Replace the starter placeholder with real Markdown fixtures**

```markdown
<!-- Posts/posts/welcome-to-tsubame.md -->
---
title: Welcome To Tsubame
date: 2026-01-01
description: The first published post in the fixture set.
kind: post
published: true
---

# Welcome To Tsubame

This is the first published post.
```

```markdown
<!-- Posts/posts/raptor-notes.md -->
---
title: Raptor Notes
date: 2026-02-01
description: Notes collected while studying Raptor.
kind: post
published: true
---

# Raptor Notes

Second post used for homepage ordering and archive output.
```

```markdown
<!-- Posts/posts/fuwari-study.md -->
---
title: Fuwari Study Notes
date: 2026-03-01
description: Structural notes from studying the Fuwari theme.
kind: post
published: true
---

# Fuwari Study Notes

Newest post used to verify descending homepage ordering.
```

```markdown
<!-- Posts/pages/about.md -->
---
title: About This Site
date: 2026-01-15
description: About page rendered from Markdown.
kind: page
path: /about/
published: true
---

# About This Site

This page is authored in Markdown.
```

```markdown
<!-- Posts/pages/draft-hidden.md -->
---
title: Draft Hidden
date: 2026-04-01
description: Draft content should never be published.
kind: post
published: false
---

# Draft Hidden

This content should be excluded from all outputs.
```

Remove the starter placeholder:

```text
// Delete Posts/Posts.txt
```

- [ ] **Step 4: Run the new tests to verify they fail for the right reason**

Run: `swift test --filter SitePublishingTests`

Expected: FAIL because `/2/`, `/archive/`, `/about/`, and `/posts/welcome-to-tsubame/` are not published yet, while the starter site still renders only the hello-world homepage.

- [ ] **Step 5: Commit**

```bash
git add Package.swift Posts Tests/RaptorTsubameTests
git commit -m "test: add publishing fixtures and harness"
```

---

### Task 2: Implement Content Metadata And Pagination State

**Files:**
- Create: `Sources/Content/SiteContentKind.swift`
- Create: `Sources/Content/SiteContentLoader.swift`
- Create: `Sources/Content/PostQueries.swift`
- Modify: `Sources/Site.swift`
- Test: `Tests/RaptorTsubameTests/SitePublishingTests.swift`

- [ ] **Step 1: Extend the failing tests to assert pagination state is derived from content**

```swift
@Test("derives two homepage pages from three published posts with page size two")
func derivesHomepagePageCount() async throws {
    let harness = try TestPublishHarness()
    defer { harness.cleanup() }

    var site = ExampleSite()
    try await site.prepare()

    #expect(site.homePage.totalPages == 2)
    #expect(site.generatedPages.contains { $0.path == "/2" })
}
```

- [ ] **Step 2: Add semantic content keys and render-time post queries**

```swift
// Sources/Content/SiteContentKind.swift
import Foundation

enum SiteContentKind: String, Sendable {
    case post
    case page
}

enum SiteContentMetadataKey {
    static let kind = "kind"
    static let published = "published"
    static let path = "path"
}

extension Dictionary where Key == String, Value == any Sendable {
    func stringValue(for key: String) -> String? {
        self[key] as? String
    }
}
```

```swift
// Sources/Content/PostQueries.swift
import Foundation
import Raptor

enum PostQueries {
    static func publishedPosts<S: Sequence>(_ posts: S) -> [Post] where S.Element == Post {
        posts.filter { post in
            let kind = post.metadata.stringValue(for: SiteContentMetadataKey.kind)
            return kind == SiteContentKind.post.rawValue && post.isPublished
        }
        .sorted(by: \.date, order: .reverse)
    }

    static func standalonePage<S: Sequence>(at path: String, in posts: S) -> Post? where S.Element == Post {
        posts.first { post in
            let kind = post.metadata.stringValue(for: SiteContentMetadataKey.kind)
            return kind == SiteContentKind.page.rawValue && post.isPublished && post.path == path
        }
    }

    static func archiveGroups<S: Sequence>(_ posts: S) -> [(year: Int, posts: [Post])] where S.Element == Post {
        let grouped = Dictionary(grouping: publishedPosts(posts)) { post in
            Calendar(identifier: .gregorian).component(.year, from: post.date)
        }

        return grouped
            .keys
            .sorted(by: >)
            .map { year in (year, grouped[year]!.sorted(by: \.date, order: .reverse)) }
    }

    static func paginate(_ posts: [Post], pageSize: Int) -> [[Post]] {
        stride(from: 0, to: posts.count, by: pageSize).map { start in
            Array(posts[start..<min(start + pageSize, posts.count)])
        }
    }
}
```

- [ ] **Step 3: Add a lightweight front-matter scanner and wire site pagination state through `prepare()`**

```swift
// Sources/Content/SiteContentLoader.swift
import Foundation

struct SiteContentDescriptor: Sendable, Equatable {
    let title: String
    let date: Date
    let kind: SiteContentKind
    let isPublished: Bool
}

enum SiteContentLoader {
    static func loadDescriptors(from rootDirectory: URL) throws -> [SiteContentDescriptor] {
        let postsDirectory = rootDirectory.appending(path: "Posts")
        let files = try FileManager.default.subpathsOfDirectory(atPath: postsDirectory.path())
            .filter { $0.hasSuffix(".md") }

        return try files.map { relativePath in
            let fileURL = postsDirectory.appending(path: relativePath)
            let markdown = try String(contentsOf: fileURL, encoding: .utf8)
            let frontMatter = parseFrontMatter(markdown)

            let title = frontMatter["title"] ?? fileURL.deletingPathExtension().lastPathComponent
            let date = try parseDate(frontMatter["date"] ?? "1970-01-01")
            let kind = SiteContentKind(rawValue: frontMatter["kind"] ?? "post") ?? .post
            let isPublished = frontMatter["published"].flatMap(Bool.init) ?? true

            return SiteContentDescriptor(title: title, date: date, kind: kind, isPublished: isPublished)
        }
        .sorted { $0.date > $1.date }
    }

    private static func parseFrontMatter(_ markdown: String) -> [String: String] {
        guard markdown.hasPrefix("---") else { return [:] }
        let pieces = markdown.split(separator: "---", maxSplits: 2, omittingEmptySubsequences: false)
        guard pieces.count >= 2 else { return [:] }

        return pieces[1]
            .split(separator: "\n")
            .reduce(into: [:]) { result, line in
                let parts = line.split(separator: ":", maxSplits: 1).map(String.init)
                guard parts.count == 2 else { return }
                result[parts[0].trimmingCharacters(in: .whitespaces)] =
                    parts[1].trimmingCharacters(in: .whitespaces)
            }
    }

    private static func parseDate(_ value: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: value) else {
            throw NSError(domain: "SiteContentLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Bad fixture date: \(value)"])
        }
        return date
    }
}
```

```swift
// Sources/Site.swift
import Foundation
import Raptor

@main
struct RaptorWebsite {
    static func main() async {
        var site = ExampleSite()

        do {
            try await site.publish()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ExampleSite: Site {
    static let homePageSize = 2

    var name = "Raptor Tsubame"
    var titleSuffix = " – Raptor Tsubame"
    var url = URL(static: "https://www.example.com")
    var author = "Shiinayane"

    var homePage = HomePage(pageNumber: 1, totalPages: 1)
    var layout = MainLayout()
    var postPages: [any PostPage] = [ArticlePage()]

    var generatedPages: [HomePage] = []

    var pages: [any Page] {
        generatedPages + [ArchivePage(), AboutPage()]
    }

    mutating func prepare() async throws {
        let root = URL(filePath: FileManager.default.currentDirectoryPath)
        let descriptors = try SiteContentLoader.loadDescriptors(from: root)
        let publishedPosts = descriptors.filter { $0.kind == .post && $0.isPublished }
        let totalPages = max(1, Int(ceil(Double(publishedPosts.count) / Double(Self.homePageSize))))

        homePage = HomePage(pageNumber: 1, totalPages: totalPages)
        generatedPages = (2...totalPages).map { HomePage(pageNumber: $0, totalPages: totalPages) }
    }
}
```

- [ ] **Step 4: Run the focused tests**

Run: `swift test --filter SitePublishingTests/derivesHomepagePageCount`

Expected: PASS for page-count state, while route publishing tests still fail because page/layout/component rendering is not implemented yet.

- [ ] **Step 5: Commit**

```bash
git add Sources/Content Sources/Site.swift Tests/RaptorTsubameTests/SitePublishingTests.swift
git commit -m "feat: derive content metadata and homepage pagination state"
```

---

### Task 3: Build The Shared Layout And Structural Components

**Files:**
- Modify: `Sources/Layouts/MainLayout.swift`
- Create: `Sources/Components/TopNavigation.swift`
- Create: `Sources/Components/PageFooter.swift`
- Create: `Sources/Components/PostMeta.swift`
- Create: `Sources/Components/PostList.swift`
- Create: `Sources/Components/PostListItem.swift`
- Create: `Sources/Components/PaginationControls.swift`
- Create: `Sources/Components/ArchiveList.swift`
- Create: `Sources/Components/MarkdownContent.swift`
- Test: `Tests/RaptorTsubameTests/SitePublishingTests.swift`

- [ ] **Step 1: Add a structural assertion to the publishing tests**

```swift
@Test("homepage and about include shared navigation")
func includesSharedNavigation() async throws {
    let harness = try TestPublishHarness()
    defer { harness.cleanup() }

    try await harness.publish()

    let homepage = try harness.contents(of: "index.html")
    let about = try harness.contents(of: "about/index.html")

    #expect(homepage.contains("Home"))
    #expect(homepage.contains("Archive"))
    #expect(homepage.contains("About"))
    #expect(about.contains("Archive"))
}
```

- [ ] **Step 2: Create the shared site shell**

```swift
// Sources/Components/TopNavigation.swift
import Foundation
import Raptor

struct TopNavigation: HTML {
    var body: some HTML {
        Navigation {
            Link("Home", destination: "/")
            Link("Archive", destination: "/archive/")
            Link("About", destination: "/about/")
        }
        .navigationBarSizing(.content)
    }
}
```

```swift
// Sources/Components/PageFooter.swift
import Foundation
import Raptor

struct PageFooter: HTML {
    var body: some HTML {
        Text {
            "Built with "
            Link("Raptor", destination: URL(static: "https://raptor.build"))
        }
        .multilineTextAlignment(.center)
        .margin(.top, .xLarge)
    }
}
```

```swift
// Sources/Layouts/MainLayout.swift
import Foundation
import Raptor

struct MainLayout: Layout {
    var body: some Document {
        TopNavigation()

        Main {
            content
            PageFooter()
        }
    }
}
```

- [ ] **Step 3: Add the reusable structural content components**

```swift
// Sources/Components/PostMeta.swift
import Foundation
import Raptor

struct PostMeta: HTML {
    let post: Post

    var body: some HTML {
        Text("\(formatted(post.date)) · \(post.description)")
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
```

```swift
// Sources/Components/PostListItem.swift
import Foundation
import Raptor

struct PostListItem: HTML {
    let post: Post

    var body: some HTML {
        Section {
            Link(post.title, destination: post)
            PostMeta(post: post)
        }
    }
}
```

```swift
// Sources/Components/PostList.swift
import Foundation
import Raptor

struct PostList: HTML {
    let posts: [Post]

    var body: some HTML {
        VStack {
            ForEach(posts) { post in
                PostListItem(post: post)
            }
        }
    }
}
```

```swift
// Sources/Components/PaginationControls.swift
import Foundation
import Raptor

struct PaginationControls: HTML {
    let currentPage: Int
    let totalPages: Int

    var body: some HTML {
        HStack {
            if currentPage > 1 {
                Link("Newer", destination: path(for: currentPage - 1))
            }
            Spacer()
            Text("Page \(currentPage) of \(totalPages)")
            Spacer()
            if currentPage < totalPages {
                Link("Older", destination: path(for: currentPage + 1))
            }
        }
    }

    private func path(for page: Int) -> String {
        page == 1 ? "/" : "/\(page)/"
    }
}
```

```swift
// Sources/Components/ArchiveList.swift
import Foundation
import Raptor

struct ArchiveList: HTML {
    let groups: [(year: Int, posts: [Post])]

    var body: some HTML {
        VStack {
            ForEach(groups, id: \.year) { group in
                Section("\(group.year)") {
                    PostList(posts: group.posts)
                }
            }
        }
    }
}
```

```swift
// Sources/Components/MarkdownContent.swift
import Foundation
import Raptor

struct MarkdownContent: HTML {
    let post: Post

    var body: some HTML {
        Section {
            post.text
        }
    }
}
```

- [ ] **Step 4: Run the structural navigation test**

Run: `swift test --filter SitePublishingTests/includesSharedNavigation`

Expected: PASS once all first-pass pages render through `MainLayout`, even before article/archive/about-specific content is complete.

- [ ] **Step 5: Commit**

```bash
git add Sources/Layouts/MainLayout.swift Sources/Components Tests/RaptorTsubameTests/SitePublishingTests.swift
git commit -m "feat: add shared site layout and structural components"
```

---

### Task 4: Implement Homepage, Archive, And About Pages

**Files:**
- Create: `Sources/Pages/HomePage.swift`
- Create: `Sources/Pages/ArchivePage.swift`
- Create: `Sources/Pages/AboutPage.swift`
- Modify: `Sources/Pages/Home.swift`
- Test: `Tests/RaptorTsubameTests/SitePublishingTests.swift`

- [ ] **Step 1: Add page-specific failing tests**

```swift
@Test("homepage page two contains only the remaining post")
func rendersSecondHomepagePage() async throws {
    let harness = try TestPublishHarness()
    defer { harness.cleanup() }

    try await harness.publish()

    let pageTwo = try harness.contents(of: "2/index.html")
    #expect(pageTwo.contains("Welcome To Tsubame"))
    #expect(!pageTwo.contains("Raptor Notes"))
}

@Test("archive contains every published post")
func archiveContainsAllPublishedPosts() async throws {
    let harness = try TestPublishHarness()
    defer { harness.cleanup() }

    try await harness.publish()

    let archive = try harness.contents(of: "archive/index.html")
    #expect(archive.contains("Welcome To Tsubame"))
    #expect(archive.contains("Raptor Notes"))
    #expect(archive.contains("Fuwari Study Notes"))
}
```

- [ ] **Step 2: Replace the starter home page with the paginated homepage**

```swift
// Sources/Pages/Home.swift
import Foundation
import Raptor

typealias Home = HomePage
```

```swift
// Sources/Pages/HomePage.swift
import Foundation
import Raptor

struct HomePage: Page {
    @Environment(\.posts) private var posts

    let pageNumber: Int
    let totalPages: Int

    var path: String {
        pageNumber == 1 ? "/" : "/\(pageNumber)"
    }

    var title: String {
        pageNumber == 1 ? "Home" : "Home – Page \(pageNumber)"
    }

    var description: String {
        "Latest posts"
    }

    var body: some HTML {
        let published = PostQueries.publishedPosts(posts)
        let pages = PostQueries.paginate(published, pageSize: ExampleSite.homePageSize)
        let pagePosts = pages.indices.contains(pageNumber - 1) ? pages[pageNumber - 1] : []

        return Section {
            Text("Latest Posts").font(.title1)
            PostList(posts: pagePosts)
            PaginationControls(currentPage: pageNumber, totalPages: totalPages)
        }
    }
}
```

- [ ] **Step 3: Implement archive and about as Markdown-backed aggregate pages**

```swift
// Sources/Pages/ArchivePage.swift
import Foundation
import Raptor

struct ArchivePage: Page {
    @Environment(\.posts) private var posts

    var path: String { "/archive" }
    var title: String { "Archive" }
    var description: String { "All published posts" }

    var body: some HTML {
        Section {
            Text("Archive").font(.title1)
            ArchiveList(groups: PostQueries.archiveGroups(posts))
        }
    }
}
```

```swift
// Sources/Pages/AboutPage.swift
import Foundation
import Raptor

struct AboutPage: Page {
    @Environment(\.posts) private var posts

    var path: String { "/about" }
    var title: String { "About" }
    var description: String { "About this site" }

    var body: some HTML {
        guard let page = PostQueries.standalonePage(at: "/about/", in: posts) else {
            return Text("About content missing")
        }

        return Section {
            Text(page.title).font(.title1)
            MarkdownContent(post: page)
        }
    }
}
```

- [ ] **Step 4: Run the aggregate page tests**

Run: `swift test --filter SitePublishingTests`

Expected: homepage pagination, archive, and About tests PASS. Post route tests still fail until the `PostPage` implementation is added.

- [ ] **Step 5: Commit**

```bash
git add Sources/Pages Tests/RaptorTsubameTests/SitePublishingTests.swift
git commit -m "feat: add homepage archive and about pages"
```

---

### Task 5: Implement The Shared Article Post Page

**Files:**
- Create: `Sources/Pages/ArticlePage.swift`
- Modify: `Sources/Site.swift`
- Test: `Tests/RaptorTsubameTests/SitePublishingTests.swift`

- [ ] **Step 1: Add the article-page-specific failing test**

```swift
@Test("article page renders markdown body and metadata")
func rendersArticlePage() async throws {
    let harness = try TestPublishHarness()
    defer { harness.cleanup() }

    try await harness.publish()

    let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
    #expect(article.contains("Welcome To Tsubame"))
    #expect(article.contains("This is the first published post."))
    #expect(article.contains("Raptor Tsubame"))
}
```

- [ ] **Step 2: Create the site-wide `PostPage` implementation**

```swift
// Sources/Pages/ArticlePage.swift
import Foundation
import Raptor

struct ArticlePage: PostPage {
    var body: some HTML {
        Section {
            Text(post.title).font(.title1)
            PostMeta(post: post)
            MarkdownContent(post: post)
        }
    }
}
```

Ensure the site still points to this page template:

```swift
// Sources/Site.swift
var postPages: [any PostPage] = [ArticlePage()]
```

- [ ] **Step 3: Run the article route tests**

Run: `swift test --filter SitePublishingTests/rendersArticlePage`

Expected: PASS, with published HTML generated at `/posts/<slug>/` from the Markdown file path under `Posts/posts/`.

- [ ] **Step 4: Run the full suite**

Run: `swift test`

Expected: PASS for the full `RaptorTsubameTests` target.

- [ ] **Step 5: Commit**

```bash
git add Sources/Pages/ArticlePage.swift Sources/Site.swift Tests/RaptorTsubameTests/SitePublishingTests.swift
git commit -m "feat: add markdown-backed article page"
```

---

### Task 6: Final Cleanup And Verification

**Files:**
- Modify: `Sources/Components/*` as needed from test feedback
- Modify: `Sources/Pages/*` as needed from test feedback
- Modify: `Sources/Site.swift` as needed from test feedback
- Test: `Tests/RaptorTsubameTests/SitePublishingTests.swift`

- [ ] **Step 1: Verify the published outputs manually**

Run:

```bash
swift run RaptorTsubame
```

Expected output:

```text
📗 Publish completed!
```

Then inspect:

```bash
find Build -maxdepth 3 -type f | sort
```

Expected paths include:

```text
Build/2/index.html
Build/about/index.html
Build/archive/index.html
Build/index.html
Build/posts/fuwari-study/index.html
Build/posts/raptor-notes/index.html
Build/posts/welcome-to-tsubame/index.html
```

- [ ] **Step 2: Verify draft exclusion explicitly**

Run:

```bash
find Build -type f | rg "draft-hidden"
```

Expected: no output

- [ ] **Step 3: Re-run the full test suite**

Run:

```bash
swift test
```

Expected:

```text
Build complete!
Test Suite ... passed
```

- [ ] **Step 4: Commit the final integrated state**

```bash
git add Package.swift Posts Sources Tests
git commit -m "feat: implement first-pass fuwari information architecture"
```

---

## Self-Review

### Spec coverage

- Homepage pagination: covered by Tasks 2 and 4.
- Article pages under `/posts/<slug>/`: covered by Task 5.
- Archive page: covered by Task 4.
- Markdown-backed About page: covered by Task 4.
- Shared navigation layout: covered by Task 3.
- Draft exclusion: covered by Tasks 1, 2, and 6.
- Layered Raptor structure: enforced by the file map and all source-task boundaries.

### Placeholder scan

- No `TBD`, `TODO`, or deferred “implement later” steps remain.
- Each code-changing step includes concrete file contents or explicit commands.
- Each test step includes the exact command and expected result.

### Type consistency

- `ExampleSite.homePage` and `generatedPages` both use `HomePage`.
- `ArticlePage` is the sole `PostPage`.
- `PostQueries` is the shared aggregation entry point for page rendering.
- `SiteContentLoader` is only used in `prepare()` for pagination-state derivation.
