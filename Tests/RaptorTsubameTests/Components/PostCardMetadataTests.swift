import Testing
@testable import RaptorTsubame

@Suite("Post card metadata")
struct PostCardMetadataTests {
    @Test("cover path reads metadata image")
    func coverPathReadsMetadataImage() {
        let metadata = SiteContentMetadata(["image": "/images/cover.jpg"])
        let model = PostCardMetadata(metadata: metadata, body: "")

        #expect(model.coverPath == "/images/cover.jpg")
    }

    @Test("cover path is nil when metadata image is absent")
    func coverPathNilWhenAbsent() {
        let metadata = SiteContentMetadata([:])
        let model = PostCardMetadata(metadata: metadata, body: "")

        #expect(model.coverPath == nil)
    }

    @Test("computes word count and reading minutes from body")
    func computesWordCountAndReadingMinutes() {
        let metadata = SiteContentMetadata([:])
        let model = PostCardMetadata(metadata: metadata, body: "one two three four five")

        #expect(model.wordCount == 5)
        #expect(model.readingMinutes == 1)
    }

    @Test("counts Markdown-shaped body without marker tokens")
    func countsMarkdownShapedBodyWithoutMarkerTokens() {
        let metadata = SiteContentMetadata([:])
        let model = PostCardMetadata(metadata: metadata, body: "# Title\n\n- one two")

        #expect(model.wordCount == 3)
        #expect(model.readingMinutes == 1)
    }

    @Test("rounds reading minutes up at 201 words")
    func roundsReadingMinutesUpAt201Words() {
        let metadata = SiteContentMetadata([:])
        let body = Array(repeating: "word", count: 201).joined(separator: " ")
        let model = PostCardMetadata(metadata: metadata, body: body)

        #expect(model.wordCount == 201)
        #expect(model.readingMinutes == 2)
    }

    @Test("maps category and tags into taxonomy terms")
    func mapsCategoryAndTagsIntoTaxonomyTerms() {
        let metadata = SiteContentMetadata([
            "category": "Swift",
            "tags": "Raptor, Static Site"
        ])
        let model = PostCardMetadata(metadata: metadata, body: "")

        #expect(model.category?.name == "Swift")
        #expect(model.tags.map(\.name) == ["Raptor", "Static Site"])
    }
}
