import Foundation
import Raptor

struct PostListItem: HTML {
    let post: Post

    private var metadata: PostCardMetadata {
        PostCardMetadata(
            metadata: SiteContentMetadata(post.metadata),
            wordCount: post.estimatedWordCount
        )
    }

    private var coverPath: String? {
        metadata.coverPath
    }

    private var category: TaxonomyTerm? {
        metadata.category
    }

    private var tags: [TaxonomyTerm] {
        metadata.tags
    }

    private var wordCount: Int {
        metadata.wordCount
    }

    private var readingMinutes: Int {
        metadata.readingMinutes
    }

    var body: some HTML {
        cardContent
            .data("post-card", "true")
    }

    private var cardContent: some HTML {
        VStack(alignment: .leading, spacing: 14) {
            if let coverPath {
                Section {
                    Image(coverPath, description: post.imageDescription)
                        .resizable()
                        .imageFit(.cover)
                        .style(PostCardCoverImageStyle())
                }
                .style(PostCardCoverStyle())
                .data("post-card-cover", "true")
            }

            Link(post)
            PostMeta(post: post)

            if hasTaxonomy {
                Section {
                    TaxonomyBadgeList(category: category, tags: tags)
                }
                .style(PostCardTaxonomyStyle())
                .data("post-card-taxonomy", "true")
            }

            HStack(spacing: 8) {
                Text("\(readingMinutes) min read")
                Text("\(wordCount) words")
            }
            .style(PostCardStatsStyle())
            .data("post-card-stats", "true")
        }
        .style(ContentSurfaceStyle())
        .style(PostCardStyle())
    }

    private var hasTaxonomy: Bool {
        category != nil || !tags.isEmpty
    }
}
