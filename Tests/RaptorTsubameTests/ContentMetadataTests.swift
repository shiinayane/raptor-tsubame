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
}
