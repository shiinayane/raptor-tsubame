import Testing

@Suite("Markdown compatibility publishing", .serialized)
struct MarkdownCompatibilityPublishingTests {
    @Test("publishes markdown compatibility lab through article pipeline")
    func publishesCompatibilityLab() async throws {
        let harness = try await publishedSite()

        #expect(harness.fileExists("posts/markdown-compatibility-lab/index.html"))

        let page = try harness.contents(of: "posts/markdown-compatibility-lab/index.html")
        let main = try mainSlice(of: page)
        let markdown = try compatibilityMarkdownSlice(of: main)

        #expect(main.contains("data-article-page=\"true\""))
        #expect(main.contains("Markdown Compatibility Lab"))
        #expect(markdown.contains("data-markdown-content=\"true\""))
        #expect(markdown.contains("compat-basic-paragraph-marker"))
        #expect(markdown.contains("compat-fenced-html-code-marker"))
    }

    @Test("compatibility lab does not affect post indexes or taxonomy listings")
    func compatibilityLabDoesNotAffectPostIndexes() async throws {
        let harness = try await publishedSite()

        let homepage = try harness.contents(of: "index.html")
        let archive = try harness.contents(of: "archive/index.html")
        let tags = try harness.contents(of: "tags/index.html")
        let categories = try harness.contents(of: "categories/index.html")
        let raptorTag = try harness.contents(of: "tags/raptor/index.html")
        let notesCategory = try harness.contents(of: "categories/notes/index.html")

        try expectCompatibilityLabAbsent(from: homepage)
        try expectCompatibilityLabAbsent(from: archive)
        try expectCompatibilityLabAbsent(from: tags)
        try expectCompatibilityLabAbsent(from: categories)
        try expectCompatibilityLabAbsent(from: raptorTag)
        try expectCompatibilityLabAbsent(from: notesCategory)
        #expect(!tags.contains("Markdown (1)"))
        #expect(!harness.fileExists("tags/markdown/index.html"))
    }
}

private func expectCompatibilityLabAbsent(from html: String) throws {
    #expect(!html.contains("Markdown Compatibility Lab"))
    #expect(!html.contains("Fixture for auditing Raptor Markdown compatibility in Tsubame."))
}

private func compatibilityMarkdownSlice(of html: String) throws -> String {
    let marker = try #require(html.range(of: "data-markdown-content=\"true\""))
    let openStart = try #require(html[..<marker.lowerBound].range(of: "<", options: .backwards))
    let end = html[marker.upperBound...].range(of: "data-article-navigation")?.lowerBound ?? html.endIndex
    return String(html[openStart.lowerBound..<end])
}
