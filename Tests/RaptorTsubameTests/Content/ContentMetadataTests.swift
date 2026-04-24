import Foundation
import Testing
@testable import RaptorTsubame

@Suite("Content metadata", .serialized)
struct ContentMetadataTests {
    @Test("prepare derives homepage pagination when process cwd is outside the repo")
    func prepareUsesStableRootDirectory() async throws {
        let temporaryDirectory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }

        var site = ExampleSite()

        try await withCurrentDirectory(temporaryDirectory) {
            try await site.prepare()
        }

        #expect(site.homePage.totalPages == 2)
        #expect(site.generatedPages.map(\.path) == [SiteRoutes.homePage(2)])
    }

    @Test("malformed front matter without closing delimiter does not leak body metadata")
    func malformedFrontMatterDoesNotLeakMetadata() throws {
        let rootDirectory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }

        let postsDirectory = rootDirectory.appending(path: "Posts/posts")
        try FileManager.default.createDirectory(at: postsDirectory, withIntermediateDirectories: true)

        let malformedPost = postsDirectory.appending(path: "malformed.md")
        try """
        ---
        title: Broken Header
        kind: page
        published: false
        This line is body content and the header never closes.
        """.write(to: malformedPost, atomically: true, encoding: .utf8)

        let loader = SiteContentLoader()
        let content = try loader.load(from: rootDirectory)

        #expect(loader.publishedPostCount(in: content) == 1)

        let descriptor = try #require(content.first)
        #expect(descriptor.kind == .post)
        #expect(descriptor.isPublished)
        #expect(descriptor.path == nil)
    }

    @Test("published metadata follows Raptor Bool parsing")
    func publishedMetadataFollowsRaptorBoolParsing() throws {
        let rootDirectory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: rootDirectory) }

        let postsDirectory = rootDirectory.appending(path: "Posts/posts")
        try FileManager.default.createDirectory(at: postsDirectory, withIntermediateDirectories: true)

        try writePost(named: "draft.md", published: "false", to: postsDirectory)
        try writePost(named: "uppercase.md", published: "FALSE", to: postsDirectory)

        let loader = SiteContentLoader()
        let content = try loader.load(from: rootDirectory)

        #expect(loader.publishedPostCount(in: content) == 1)
        #expect(try #require(content.first { $0.sourceURL.lastPathComponent == "draft.md" }).isPublished == false)
        #expect(try #require(content.first { $0.sourceURL.lastPathComponent == "uppercase.md" }).isPublished)
    }

    @Test("draft metadata is compatibility-only and does not affect publishing")
    func draftMetadataDoesNotAffectPublishing() {
        let metadata = SiteContentMetadata(
            [
                "published": "true",
                "draft": "true"
            ]
        )

        #expect(metadata.isPublished)
        #expect(metadata.isDraftMarked)
    }

    @Test("shared site metadata parser normalizes custom content fields")
    func sharedSiteMetadataParserNormalizesCustomContentFields() {
        let metadata = SiteContentMetadata(
            [
                "kind": "page",
                "published": "FALSE",
                "path": " about ",
                "category": " Notes ",
                "tags": "Raptor, Swift, ",
                "image": " ./cover.jpg ",
                "updated": " 2026-04-25 ",
                "lang": " zh_CN ",
                "draft": "true"
            ]
        )

        #expect(metadata.kind == .page)
        #expect(metadata.isPublished)
        #expect(metadata.path == "about")
        #expect(metadata.category == "Notes")
        #expect(metadata.tags == ["Raptor", "Swift"])
        #expect(metadata.image == "./cover.jpg")
        #expect(metadata.updated == "2026-04-25")
        #expect(metadata.lang == "zh_CN")
        #expect(metadata.isDraftMarked)
    }

    @Test("Fuwari aligned metadata fields default to nil when absent or empty")
    func fuwariAlignedMetadataFieldsDefaultToNil() {
        let metadata = SiteContentMetadata(
            [
                "image": " ",
                "updated": "",
                "lang": "\n"
            ]
        )

        #expect(metadata.image == nil)
        #expect(metadata.updated == nil)
        #expect(metadata.lang == nil)
        #expect(!metadata.isDraftMarked)
    }

    @Test("published site helper reuses generated output")
    func publishedSiteHelperReusesGeneratedOutput() async throws {
        let first = try await publishedSite()
        let second = try await publishedSite()

        #expect(first.buildDirectory == second.buildDirectory)
    }

    private func writePost(named fileName: String, published: String, to directory: URL) throws {
        let fileURL = directory.appending(path: fileName)
        try """
        ---
        title: \(fileName)
        kind: post
        published: \(published)
        ---

        Body.
        """.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
