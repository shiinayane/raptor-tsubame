import Foundation
import Raptor

struct ArchiveEntry: HTML {
    let post: Post

    private var metadata: PostCardMetadata {
        PostCardMetadata(
            metadata: SiteContentMetadata(post.metadata),
            wordCount: post.estimatedWordCount
        )
    }

    private var category: TaxonomyTerm? {
        metadata.category
    }

    private var tags: [TaxonomyTerm] {
        metadata.tags
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 14) {
                Time(post.date.formatted(date: .abbreviated, time: .omitted), dateTime: post.date)
                    .style(ArchiveEntryDateStyle())
                Link(post)
                    .style(ArchiveEntryTitleStyle())
            }

            if !post.description.isEmpty {
                Text(post.description)
                    .style(ArchiveEntryDescriptionStyle())
            }

            if hasTaxonomy {
                Section {
                    TaxonomyBadgeList(category: category, tags: tags)
                }
                .style(ArchiveEntryTaxonomyStyle())
            }
        }
        .style(ArchiveEntryStyle())
        .data("archive-entry", "true")
    }

    private var hasTaxonomy: Bool {
        category != nil || !tags.isEmpty
    }
}
