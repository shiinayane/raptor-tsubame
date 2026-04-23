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
