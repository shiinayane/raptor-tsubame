import Foundation

struct PostCardMetadata: Sendable {
    let coverPath: String?
    let wordCount: Int
    let readingMinutes: Int
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]

    init(metadata: SiteContentMetadata, body: String) {
        self.init(metadata: metadata, wordCount: Self.countWords(in: body))
    }

    init(metadata: SiteContentMetadata, wordCount: Int) {
        self.coverPath = metadata.image
        self.wordCount = wordCount
        self.readingMinutes = max(1, Int(ceil(Double(wordCount) / 200.0)))
        self.category = metadata.category.map { TaxonomyTerm(kind: .category, name: $0) }
        self.tags = metadata.tags.map { TaxonomyTerm(kind: .tag, name: $0) }
    }

    private static func countWords(in body: String) -> Int {
        body.matches(of: #/\w+(?:-\w+)*/#).count
    }
}
