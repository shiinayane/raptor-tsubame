# Fuwari Taxonomy Stage 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add first-class `tags` and `category` taxonomy support to the Stage 1 site, including taxonomy routes, taxonomy index/detail pages, and article-page taxonomy metadata display.

**Architecture:** Extend the existing Stage 1 query-driven architecture rather than introducing a second site subsystem. Keep Markdown front matter as the content source, use `SiteContentLoader` only for `prepare()`-time page generation state, and keep render-time taxonomy aggregation inside `PostQueries` over real `Post` values from `@Environment(\.posts)`.

**Tech Stack:** Swift 6.2, Raptor 0.1.2, Swift Testing (`Testing`), Markdown front matter under `Posts/`

---

## File Structure

### Existing files to modify

- `Posts/posts/welcome-to-tsubame.md`
  Add Stage 2 `category` and `tags` metadata.
- `Posts/posts/raptor-notes.md`
  Add Stage 2 `category` and `tags` metadata.
- `Posts/posts/fuwari-study.md`
  Add Stage 2 `category` and `tags` metadata.
- `Sources/Site.swift`
  Add generated taxonomy page state and wire taxonomy pages into `site.pages`.
- `Sources/SiteRoutes.swift`
  Add route helpers for tags and categories.
- `Sources/Content/SiteContentKind.swift`
  Extend front matter metadata keys to include `category` and `tags`.
- `Sources/Content/SiteContentLoader.swift`
  Parse taxonomy metadata into lightweight descriptors and derive generated term pages in `prepare()`.
- `Sources/Content/PostQueries.swift`
  Add render-time taxonomy aggregation helpers over real `Post` values.
- `Sources/Pages/ArticlePage.swift`
  Render taxonomy metadata in article pages.

### New source files

- `Sources/Content/TaxonomyTerm.swift`
  Shared taxonomy term model, slug normalization, and route mapping used by both `SiteContentLoader` and `PostQueries`.
- `Sources/Components/TaxonomyBadgeList.swift`
  Article-page category and tag link list.
- `Sources/Components/TaxonomyIndexItem.swift`
  Single taxonomy term row with count.
- `Sources/Components/TaxonomyIndexList.swift`
  List wrapper for taxonomy index rows.
- `Sources/Components/TaxonomyPostListHeader.swift`
  Shared header for taxonomy detail pages.
- `Sources/Pages/TagsIndexPage.swift`
  `/tags/` index page.
- `Sources/Pages/TagPage.swift`
  `/tags/<slug>/` detail page.
- `Sources/Pages/CategoriesIndexPage.swift`
  `/categories/` index page.
- `Sources/Pages/CategoryTermPage.swift`
  `/categories/<slug>/` detail page. Named `CategoryTermPage` to avoid collision with Raptor’s `CategoryPage` protocol.

### New tests

- `Tests/RaptorTsubameTests/TaxonomyPublishingTests.swift`
  Integration tests for taxonomy routes, taxonomy page content, and article-page taxonomy metadata.
- `Tests/RaptorTsubameTests/TaxonomySupportTests.swift`
  Focused tests for term normalization and prepare-time metadata parsing.

---

### Task 1: Add Taxonomy Fixtures And Failing Integration Tests

**Files:**
- Modify: `Posts/posts/welcome-to-tsubame.md`
- Modify: `Posts/posts/raptor-notes.md`
- Modify: `Posts/posts/fuwari-study.md`
- Create: `Tests/RaptorTsubameTests/TaxonomyPublishingTests.swift`

- [ ] **Step 1: Write the failing taxonomy publishing tests**

```swift
import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Taxonomy publishing", .serialized)
struct TaxonomyPublishingTests {
    @Test("publishes tag routes")
    func publishesTagRoutes() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        #expect(harness.fileExists("tags/index.html"))
        #expect(harness.fileExists("tags/raptor/index.html"))
        #expect(harness.fileExists("tags/design/index.html"))
    }

    @Test("publishes category routes")
    func publishesCategoryRoutes() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        #expect(harness.fileExists("categories/index.html"))
        #expect(harness.fileExists("categories/notes/index.html"))
        #expect(harness.fileExists("categories/updates/index.html"))
    }

    @Test("renders tag index and detail pages")
    func rendersTagIndexAndDetailPages() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let tags = try harness.contents(of: "tags/index.html")
        #expect(tags.contains("Design (1)"))
        #expect(tags.contains("Raptor (2)"))

        let raptor = try harness.contents(of: "tags/raptor/index.html")
        #expect(raptor.contains("Raptor Notes"))
        #expect(raptor.contains("Fuwari Study Notes"))
        #expect(!raptor.contains("Welcome To Tsubame"))
    }

    @Test("renders category index and detail pages")
    func rendersCategoryIndexAndDetailPages() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let categories = try harness.contents(of: "categories/index.html")
        #expect(categories.contains("Notes (2)"))
        #expect(categories.contains("Updates (1)"))

        let notes = try harness.contents(of: "categories/notes/index.html")
        #expect(notes.contains("Raptor Notes"))
        #expect(notes.contains("Fuwari Study Notes"))
        #expect(!notes.contains("Welcome To Tsubame"))
    }

    @Test("article page shows category and tag links")
    func articlePageShowsTaxonomyLinks() async throws {
        let harness = try TestPublishHarness()
        defer { harness.cleanup() }

        try await harness.publish()

        let article = try harness.contents(of: "posts/welcome-to-tsubame/index.html")
        #expect(article.contains("href=\"/categories/updates/\""))
        #expect(article.contains("href=\"/tags/intro/\""))
        #expect(article.contains("href=\"/tags/site/\""))
        #expect(article.contains(">Updates<"))
        #expect(article.contains(">Intro<"))
        #expect(article.contains(">Site<"))
    }
}
```

- [ ] **Step 2: Run one focused test to verify the red state**

Run: `swift test --filter TaxonomyPublishingTests/publishesTagRoutes`

Expected: FAIL because `/tags/` pages are not implemented yet.

- [ ] **Step 3: Add Stage 2 taxonomy metadata to the Markdown fixtures**

```markdown
<!-- Posts/posts/welcome-to-tsubame.md -->
---
title: Welcome To Tsubame
date: 2026-01-01
description: The first published post in the fixture set.
kind: post
category: Updates
tags: Intro, Site
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
category: Notes
tags: Raptor, Swift
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
category: Notes
tags: Raptor, Design
published: true
---

# Fuwari Study Notes

Newest post used to verify descending homepage ordering.
```

- [ ] **Step 4: Re-run the same focused test**

Run: `swift test --filter TaxonomyPublishingTests/publishesTagRoutes`

Expected: FAIL because the taxonomy routes are still not implemented, but the fixtures compile and load.

- [ ] **Step 5: Commit**

```bash
git add Posts/posts Tests/RaptorTsubameTests/TaxonomyPublishingTests.swift
git commit -m "test: add taxonomy fixtures and publishing assertions"
```

---

### Task 2: Add Shared Taxonomy Models And Metadata Parsing

**Files:**
- Create: `Sources/Content/TaxonomyTerm.swift`
- Modify: `Sources/SiteRoutes.swift`
- Modify: `Sources/Content/SiteContentKind.swift`
- Modify: `Sources/Content/SiteContentLoader.swift`
- Modify: `Sources/Content/PostQueries.swift`
- Create: `Tests/RaptorTsubameTests/TaxonomySupportTests.swift`

- [ ] **Step 1: Write focused failing support tests**

```swift
import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Taxonomy support", .serialized)
struct TaxonomySupportTests {
    @Test("normalizes taxonomy names into slugged routes")
    func normalizesTaxonomyTerms() {
        let tag = TaxonomyTerm(kind: .tag, name: "Raptor Notes")
        let category = TaxonomyTerm(kind: .category, name: "Site Updates")

        #expect(tag.slug == "raptor-notes")
        #expect(tag.path == SiteRoutes.tag("raptor-notes"))
        #expect(category.slug == "site-updates")
        #expect(category.path == SiteRoutes.category("site-updates"))
    }

    @Test("loader extracts category and tags from post front matter")
    func loaderExtractsTaxonomyMetadata() throws {
        let loader = SiteContentLoader()
        let descriptors = try loader.load(from: packageRoot())

        let raptorNotes = try #require(descriptors.first {
            $0.sourceURL.lastPathComponent == "raptor-notes.md"
        })

        #expect(raptorNotes.category == "Notes")
        #expect(raptorNotes.tags == ["Raptor", "Swift"])
    }
}
```

- [ ] **Step 2: Run the support tests to verify the red state**

Run: `swift test --filter TaxonomySupportTests`

Expected: FAIL because `TaxonomyTerm`, `SiteRoutes.tag`, `SiteRoutes.category`, and descriptor taxonomy metadata do not exist yet.

- [ ] **Step 3: Add the shared taxonomy term model**

```swift
// Sources/Content/TaxonomyTerm.swift
import Foundation
import Raptor

enum TaxonomyKind: String, Sendable {
    case tag
    case category
}

struct TaxonomyTerm: Hashable, Sendable, Identifiable {
    let kind: TaxonomyKind
    let name: String

    var slug: String {
        name.convertedToSlug()
    }

    var id: String {
        "\(kind.rawValue):\(slug)"
    }

    var path: String {
        switch kind {
        case .tag:
            SiteRoutes.tag(slug)
        case .category:
            SiteRoutes.category(slug)
        }
    }
}
```

- [ ] **Step 4: Extend routes, metadata keys, loader parsing, and render-time queries**

```swift
// Sources/SiteRoutes.swift
import Foundation

enum SiteRoutes {
    static let home = "/"
    static let archive = "/archive/"
    static let about = "/about/"
    static let tags = "/tags/"
    static let categories = "/categories/"

    static func homePage(_ pageNumber: Int) -> String {
        pageNumber <= 1 ? home : "/\(pageNumber)/"
    }

    static func tag(_ slug: String) -> String {
        "/tags/\(slug)/"
    }

    static func category(_ slug: String) -> String {
        "/categories/\(slug)/"
    }
}
```

```swift
// Sources/Content/SiteContentKind.swift
import Foundation

enum SiteContentKind: String, Sendable {
    case post
    case page
}

enum SiteContentMetadataKey: String, Sendable {
    case kind
    case published
    case path
    case category
    case tags
}

extension Dictionary where Key == String, Value == any Sendable {
    func stringValue(for key: String) -> String? {
        self[key] as? String
    }
}
```

```swift
// Sources/Content/SiteContentLoader.swift
import Foundation

struct SiteContentDescriptor: Sendable {
    let sourceURL: URL
    let path: String?
    let kind: SiteContentKind
    let isPublished: Bool
    let category: String?
    let tags: [String]
}

struct SiteContentLoader {
    func load(from rootDirectory: URL) throws -> [SiteContentDescriptor] {
        let postsDirectory = rootDirectory.appending(path: "Posts")

        guard FileManager.default.fileExists(atPath: postsDirectory.path) else {
            return []
        }

        let markdownFiles = try markdownFiles(in: postsDirectory)
        return try markdownFiles.map(loadDescriptor(from:))
    }

    func publishedPostCount(in content: [SiteContentDescriptor]) -> Int {
        content.count { $0.kind == .post && $0.isPublished }
    }

    func publishedTagTerms(in content: [SiteContentDescriptor]) -> [TaxonomyTerm] {
        aggregatedTerms(
            kind: .tag,
            names: content
                .filter { $0.kind == .post && $0.isPublished }
                .flatMap(\.tags)
        )
    }

    func publishedCategoryTerms(in content: [SiteContentDescriptor]) -> [TaxonomyTerm] {
        aggregatedTerms(
            kind: .category,
            names: content
                .filter { $0.kind == .post && $0.isPublished }
                .compactMap(\.category)
        )
    }

    private func loadDescriptor(from fileURL: URL) throws -> SiteContentDescriptor {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        let metadata = parseFrontMatter(in: contents)

        return SiteContentDescriptor(
            sourceURL: fileURL,
            path: metadata.stringValue(for: SiteContentMetadataKey.path.rawValue),
            kind: parseKind(metadata.stringValue(for: SiteContentMetadataKey.kind.rawValue)),
            isPublished: parsePublished(metadata.stringValue(for: SiteContentMetadataKey.published.rawValue)),
            category: parseSingleValue(metadata.stringValue(for: SiteContentMetadataKey.category.rawValue)),
            tags: parseTags(metadata.stringValue(for: SiteContentMetadataKey.tags.rawValue))
        )
    }

    private func aggregatedTerms(kind: TaxonomyKind, names: [String]) -> [TaxonomyTerm] {
        let uniqueNames = Set(names.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty })
        return uniqueNames
            .map { TaxonomyTerm(kind: kind, name: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func parseSingleValue(_ rawValue: String?) -> String? {
        guard let rawValue?.trimmingCharacters(in: .whitespacesAndNewlines), !rawValue.isEmpty else {
            return nil
        }
        return rawValue
    }

    private func parseTags(_ rawValue: String?) -> [String] {
        guard let rawValue else { return [] }

        return rawValue
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
```

```swift
// Sources/Content/PostQueries.swift
import Foundation
import Raptor

enum PostQueries {
    static func publishedPosts<S: Sequence>(_ posts: S) -> [Post] where S.Element == Post {
        posts
            .filter { contentKind(for: $0) == .post }
            .filter(\.isPublished)
            .sorted(by: \.date, order: .reverse)
    }

    static func standalonePage<S: Sequence>(at path: String, in posts: S) -> Post? where S.Element == Post {
        let normalizedPath = normalized(path)

        return posts.first {
            contentKind(for: $0) == .page &&
            $0.isPublished &&
            normalized($0.metadata.stringValue(for: SiteContentMetadataKey.path.rawValue) ?? $0.path) == normalizedPath
        }
    }

    static func archiveGroups<S: Sequence>(_ posts: S) -> [(year: Int, posts: [Post])] where S.Element == Post {
        let groupedPosts = Dictionary(grouping: publishedPosts(posts)) {
            Calendar(identifier: .gregorian).component(.year, from: $0.date)
        }

        return groupedPosts
            .map { (year: $0.key, posts: $0.value.sorted(by: \.date, order: .reverse)) }
            .sorted { $0.year > $1.year }
    }

    static func paginate(_ posts: [Post], pageSize: Int) -> [[Post]] {
        precondition(pageSize > 0, "Page size must be greater than zero.")

        guard !posts.isEmpty else {
            return []
        }

        return stride(from: 0, to: posts.count, by: pageSize).map { index in
            Array(posts[index..<min(index + pageSize, posts.count)])
        }
    }

    static func category(for post: Post) -> TaxonomyTerm? {
        guard contentKind(for: post) == .post,
              post.isPublished,
              let rawValue = post.metadata.stringValue(for: SiteContentMetadataKey.category.rawValue)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !rawValue.isEmpty else {
            return nil
        }

        return TaxonomyTerm(kind: .category, name: rawValue)
    }

    static func tags(for post: Post) -> [TaxonomyTerm] {
        guard contentKind(for: post) == .post, post.isPublished else {
            return []
        }

        let rawValue = post.metadata.stringValue(for: SiteContentMetadataKey.tags.rawValue) ?? ""
        return rawValue
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { TaxonomyTerm(kind: .tag, name: $0) }
    }

    static func tagGroups<S: Sequence>(_ posts: S) -> [(term: TaxonomyTerm, posts: [Post])] where S.Element == Post {
        let published = publishedPosts(posts)
        let grouped = Dictionary(grouping: published.flatMap { post in
            tags(for: post).map { ($0, post) }
        }, by: \.0)

        return grouped
            .map { entry in
                (
                    term: entry.key,
                    posts: entry.value.map(\.1).sorted(by: \.date, order: .reverse)
                )
            }
            .sorted { $0.term.name.localizedCaseInsensitiveCompare($1.term.name) == .orderedAscending }
    }

    static func categoryGroups<S: Sequence>(_ posts: S) -> [(term: TaxonomyTerm, posts: [Post])] where S.Element == Post {
        let published = publishedPosts(posts)
        let grouped = Dictionary(grouping: published.compactMap { post in
            category(for: post).map { ($0, post) }
        }, by: \.0)

        return grouped
            .map { entry in
                (
                    term: entry.key,
                    posts: entry.value.map(\.1).sorted(by: \.date, order: .reverse)
                )
            }
            .sorted { $0.term.name.localizedCaseInsensitiveCompare($1.term.name) == .orderedAscending }
    }

    static func posts<S: Sequence>(tagged slug: String, in posts: S) -> [Post] where S.Element == Post {
        tagGroups(posts)
            .first { $0.term.slug == slug }?
            .posts ?? []
    }

    static func posts<S: Sequence>(inCategory slug: String, posts: S) -> [Post] where S.Element == Post {
        categoryGroups(posts)
            .first { $0.term.slug == slug }?
            .posts ?? []
    }

    private static func normalized(_ path: String) -> String {
        let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed.isEmpty ? "/" : "/\(trimmed)/"
    }

    private static func contentKind(for post: Post) -> SiteContentKind {
        let rawValue = post.metadata.stringValue(for: SiteContentMetadataKey.kind.rawValue)
        return SiteContentKind(rawValue: rawValue ?? "") ?? .post
    }
}
```

- [ ] **Step 5: Run the support tests to verify they pass**

Run: `swift test --filter TaxonomySupportTests`

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add Sources/Content Sources/SiteRoutes.swift Tests/RaptorTsubameTests/TaxonomySupportTests.swift
git commit -m "feat: add taxonomy term models and metadata parsing"
```

---

### Task 3: Implement Tag Pages And Shared Taxonomy Index Components

**Files:**
- Create: `Sources/Components/TaxonomyIndexItem.swift`
- Create: `Sources/Components/TaxonomyIndexList.swift`
- Create: `Sources/Components/TaxonomyPostListHeader.swift`
- Create: `Sources/Pages/TagsIndexPage.swift`
- Create: `Sources/Pages/TagPage.swift`
- Modify: `Sources/Site.swift`
- Test: `Tests/RaptorTsubameTests/TaxonomyPublishingTests.swift`

- [ ] **Step 1: Run the focused tag publishing test to verify the red state**

Run: `swift test --filter TaxonomyPublishingTests/publishesTagRoutes`

Expected: FAIL because `TagsIndexPage`, `TagPage`, and generated tag pages do not exist yet.

- [ ] **Step 2: Add the shared taxonomy index/detail components**

```swift
// Sources/Components/TaxonomyIndexItem.swift
import Foundation
import Raptor

struct TaxonomyIndexItem: HTML {
    let name: String
    let path: String
    let count: Int

    var body: some HTML {
        Link("\(name) (\(count))", destination: path)
    }
}
```

```swift
// Sources/Components/TaxonomyIndexList.swift
import Foundation
import Raptor

struct TaxonomyIndexList: HTML {
    struct Item: Identifiable {
        let name: String
        let path: String
        let count: Int

        var id: String { path }
    }

    let items: [Item]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items) { item in
                TaxonomyIndexItem(name: item.name, path: item.path, count: item.count)
            }
        }
    }
}
```

```swift
// Sources/Components/TaxonomyPostListHeader.swift
import Foundation
import Raptor

struct TaxonomyPostListHeader: HTML {
    let title: String
    let count: Int

    var body: some HTML {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.title1)
            Text("\(count) posts")
        }
    }
}
```

- [ ] **Step 3: Add the tag index/detail pages and generated tag routing**

```swift
// Sources/Pages/TagsIndexPage.swift
import Foundation
import Raptor

struct TagsIndexPage: Page {
    @Environment(\.posts) private var posts

    var title: String { "Tags" }
    var path: String { SiteRoutes.tags }

    private var items: [TaxonomyIndexList.Item] {
        PostQueries.tagGroups(posts).map { group in
            TaxonomyIndexList.Item(
                name: group.term.name,
                path: group.term.path,
                count: group.posts.count
            )
        }
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            Text("Tags").font(.title1)
            TaxonomyIndexList(items: items)
        }
    }
}
```

```swift
// Sources/Pages/TagPage.swift
import Foundation
import Raptor

struct TagPage: Page {
    @Environment(\.posts) private var posts

    let term: TaxonomyTerm

    var title: String { "Tag: \(term.name)" }
    var path: String { term.path }

    private var tagPosts: [Post] {
        PostQueries.posts(tagged: term.slug, in: posts)
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            TaxonomyPostListHeader(title: "Tag: \(term.name)", count: tagPosts.count)
            PostList(posts: tagPosts)
        }
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

    let rootDirectory: URL

    var name = "Raptor Tsubame"
    var titleSuffix = " – Raptor Tsubame"
    var url = URL(static: "https://raptor-tsubame.example.com")
    var author = "Tsubame"

    var homePage = HomePage(pageNumber: 1, totalPages: 1)
    var layout = MainLayout()

    // `ArticlePage` is the default for regular posts.
    // `MarkdownPage` is selected explicitly via front matter `layout: MarkdownPage` (e.g. Posts/pages/about.md).
    var postPages: [any PostPage] = [ArticlePage(), MarkdownPage()]
    var generatedPages: [HomePage] = []
    var generatedTagPages: [TagPage] = []

    init(rootDirectory: URL = sitePackageRoot()) {
        self.rootDirectory = rootDirectory
    }

    var pages: [any Page] {
        generatedPages + [ArchivePage(), TagsIndexPage()] + generatedTagPages
    }

    mutating func prepare() async throws {
        let contentLoader = SiteContentLoader()
        let descriptors = try contentLoader.load(from: rootDirectory)
        let publishedPostCount = contentLoader.publishedPostCount(in: descriptors)
        let totalPages = max(1, Int(ceil(Double(publishedPostCount) / Double(Self.homePageSize))))

        homePage = HomePage(pageNumber: 1, totalPages: totalPages)
        generatedPages = totalPages > 1
            ? (2...totalPages).map { HomePage(pageNumber: $0, totalPages: totalPages) }
            : []
        generatedTagPages = contentLoader.publishedTagTerms(in: descriptors).map(TagPage.init(term:))
    }
}

struct MarkdownPage: PostPage {
    var body: some HTML {
        MarkdownContent(post: post)
    }
}
```

- [ ] **Step 4: Run the tag publishing tests**

Run: `swift test --filter TaxonomyPublishingTests/publishesTagRoutes`

Expected: PASS

Run: `swift test --filter TaxonomyPublishingTests/rendersTagIndexAndDetailPages`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/Components/TaxonomyIndexItem.swift Sources/Components/TaxonomyIndexList.swift Sources/Components/TaxonomyPostListHeader.swift Sources/Pages/TagsIndexPage.swift Sources/Pages/TagPage.swift Sources/Site.swift
git commit -m "feat: add tag taxonomy pages"
```

---

### Task 4: Implement Category Pages And Article Taxonomy Metadata

**Files:**
- Create: `Sources/Components/TaxonomyBadgeList.swift`
- Create: `Sources/Pages/CategoriesIndexPage.swift`
- Create: `Sources/Pages/CategoryTermPage.swift`
- Modify: `Sources/Pages/ArticlePage.swift`
- Modify: `Sources/Site.swift`
- Test: `Tests/RaptorTsubameTests/TaxonomyPublishingTests.swift`

- [ ] **Step 1: Run the category/article taxonomy tests to verify the red state**

Run: `swift test --filter TaxonomyPublishingTests/publishesCategoryRoutes`

Expected: FAIL because category pages do not exist yet.

Run: `swift test --filter TaxonomyPublishingTests/articlePageShowsTaxonomyLinks`

Expected: FAIL because the article page does not render category/tag links yet.

- [ ] **Step 2: Add the article taxonomy component**

```swift
// Sources/Components/TaxonomyBadgeList.swift
import Foundation
import Raptor

struct TaxonomyBadgeList: HTML {
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            if let category {
                HStack(spacing: 8) {
                    Text("Category")
                    Link(category.name, destination: category.path)
                }
            }

            if !tags.isEmpty {
                HStack(spacing: 8) {
                    Text("Tags")
                    ForEach(tags) { tag in
                        Link(tag.name, destination: tag.path)
                    }
                }
            }
        }
    }
}
```

- [ ] **Step 3: Add category index/detail pages, wire generated category pages, and render taxonomy in `ArticlePage`**

```swift
// Sources/Pages/CategoriesIndexPage.swift
import Foundation
import Raptor

struct CategoriesIndexPage: Page {
    @Environment(\.posts) private var posts

    var title: String { "Categories" }
    var path: String { SiteRoutes.categories }

    private var items: [TaxonomyIndexList.Item] {
        PostQueries.categoryGroups(posts).map { group in
            TaxonomyIndexList.Item(
                name: group.term.name,
                path: group.term.path,
                count: group.posts.count
            )
        }
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            Text("Categories").font(.title1)
            TaxonomyIndexList(items: items)
        }
    }
}
```

```swift
// Sources/Pages/CategoryTermPage.swift
import Foundation
import Raptor

struct CategoryTermPage: Page {
    @Environment(\.posts) private var posts

    let term: TaxonomyTerm

    var title: String { "Category: \(term.name)" }
    var path: String { term.path }

    private var categoryPosts: [Post] {
        PostQueries.posts(inCategory: term.slug, posts: posts)
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            TaxonomyPostListHeader(title: "Category: \(term.name)", count: categoryPosts.count)
            PostList(posts: categoryPosts)
        }
    }
}
```

```swift
// Sources/Pages/ArticlePage.swift
import Foundation
import Raptor

struct ArticlePage: PostPage {
    private var category: TaxonomyTerm? {
        PostQueries.category(for: post)
    }

    private var tags: [TaxonomyTerm] {
        PostQueries.tags(for: post)
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 16) {
            Text(post.title)
                .font(.title1)

            PostMeta(post: post)
            TaxonomyBadgeList(category: category, tags: tags)
            MarkdownContent(post: post)
        }
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

    let rootDirectory: URL

    var name = "Raptor Tsubame"
    var titleSuffix = " – Raptor Tsubame"
    var url = URL(static: "https://raptor-tsubame.example.com")
    var author = "Tsubame"

    var homePage = HomePage(pageNumber: 1, totalPages: 1)
    var layout = MainLayout()

    // `ArticlePage` is the default for regular posts.
    // `MarkdownPage` is selected explicitly via front matter `layout: MarkdownPage` (e.g. Posts/pages/about.md).
    var postPages: [any PostPage] = [ArticlePage(), MarkdownPage()]
    var generatedPages: [HomePage] = []
    var generatedTagPages: [TagPage] = []
    var generatedCategoryPages: [CategoryTermPage] = []

    init(rootDirectory: URL = sitePackageRoot()) {
        self.rootDirectory = rootDirectory
    }

    var pages: [any Page] {
        generatedPages +
        [ArchivePage(), TagsIndexPage(), CategoriesIndexPage()] +
        generatedTagPages +
        generatedCategoryPages
    }

    mutating func prepare() async throws {
        let contentLoader = SiteContentLoader()
        let descriptors = try contentLoader.load(from: rootDirectory)
        let publishedPostCount = contentLoader.publishedPostCount(in: descriptors)
        let totalPages = max(1, Int(ceil(Double(publishedPostCount) / Double(Self.homePageSize))))

        homePage = HomePage(pageNumber: 1, totalPages: totalPages)
        generatedPages = totalPages > 1
            ? (2...totalPages).map { HomePage(pageNumber: $0, totalPages: totalPages) }
            : []
        generatedTagPages = contentLoader.publishedTagTerms(in: descriptors).map(TagPage.init(term:))
        generatedCategoryPages = contentLoader.publishedCategoryTerms(in: descriptors).map(CategoryTermPage.init(term:))
    }
}

struct MarkdownPage: PostPage {
    var body: some HTML {
        MarkdownContent(post: post)
    }
}
```

- [ ] **Step 4: Run the taxonomy suite**

Run: `swift test --filter TaxonomyPublishingTests`

Expected: PASS

- [ ] **Step 5: Run the full suite**

Run: `swift test`

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add Sources/Components/TaxonomyBadgeList.swift Sources/Pages/CategoriesIndexPage.swift Sources/Pages/CategoryTermPage.swift Sources/Pages/ArticlePage.swift Sources/Site.swift
git commit -m "feat: add category taxonomy pages and article metadata"
```

---

### Task 5: Final Cleanup And Verification

**Files:**
- Modify: `Sources/Content/*` as needed from test feedback
- Modify: `Sources/Pages/*` as needed from test feedback
- Modify: `Sources/Components/*` as needed from test feedback
- Modify: `Tests/RaptorTsubameTests/*` as needed from test feedback

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
find Build -maxdepth 4 -type f | sort
```

Expected paths include:

```text
Build/index.html
Build/2/index.html
Build/archive/index.html
Build/about/index.html
Build/tags/index.html
Build/tags/raptor/index.html
Build/categories/index.html
Build/categories/notes/index.html
Build/posts/welcome-to-tsubame/index.html
```

- [ ] **Step 2: Verify draft and page exclusion explicitly**

Run:

```bash
find Build -type f | rg "draft-hidden|tags/about|categories/about"
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
Test run with ... passed
```

- [ ] **Step 4: Commit the final integrated state**

```bash
git add Posts Sources Tests
git commit -m "feat: implement stage 2 taxonomy architecture"
```

---

## Self-Review

### Spec coverage

- `category` + `tags` as independent front matter fields: covered by Tasks 1 and 2.
- `/tags/` and `/tags/<slug>/`: covered by Tasks 1, 3, and 5.
- `/categories/` and `/categories/<slug>/`: covered by Tasks 1, 4, and 5.
- article-page taxonomy metadata: covered by Tasks 1 and 4.
- pages and drafts excluded from taxonomy: covered by Tasks 1, 2, and 5.
- Stage 1 route preservation: covered by Tasks 4 and 5 through full-suite verification.

### Placeholder scan

- No `TBD`, `TODO`, or “similar to above” placeholders remain.
- Every code-changing step includes concrete file content.
- Every verification step includes exact commands and expected results.

### Type consistency

- `TaxonomyTerm` is the single shared taxonomy model for render-time and prepare-time state.
- `SiteRoutes` owns tag/category route generation.
- `TagPage` and `CategoryTermPage` use shared `TaxonomyTerm`.
- `ArticlePage` remains the default `PostPage`.
- `MarkdownPage` remains the explicit layout owner for `/about/`.
