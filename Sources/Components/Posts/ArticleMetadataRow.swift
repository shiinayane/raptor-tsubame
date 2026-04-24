import Foundation
import Raptor

struct ArticleMetadataRow: HTML {
    let post: Post
    let category: TaxonomyTerm?
    let tags: [TaxonomyTerm]

    private var metadata: SiteContentMetadata {
        SiteContentMetadata(post.metadata)
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ArticleMetadataItem(kind: "published", icon: "bi-calendar3") {
                    Time(post.date.formatted(date: .abbreviated, time: .omitted), dateTime: post.date)
                        .data("article-meta-content", "published")
                }

                if let updated = metadata.updated {
                    ArticleMetadataItem(kind: "updated", icon: "bi-arrow-repeat") {
                        Text(updated)
                            .data("article-meta-content", "updated")
                    }
                }

                if let lang = metadata.lang {
                    ArticleMetadataItem(kind: "lang", icon: "bi-translate") {
                        Text(lang)
                            .data("article-meta-content", "lang")
                    }
                }
            }

            HStack(spacing: 10) {
                if let category {
                    ArticleMetadataItem(kind: "category", icon: "bi-journal-bookmark") {
                        Link(category.name, destination: category.path)
                            .data("article-meta-content", "category")
                    }
                }

                if !tags.isEmpty {
                    ArticleMetadataItem(kind: "tags", icon: "bi-hash") {
                        HStack(spacing: 6) {
                            ForEach(tags) { tag in
                                Link(tag.name, destination: tag.path)
                            }
                        }
                        .data("article-meta-content", "tags")
                    }
                }
            }
        }
        .style(MetadataTextStyle())
        .data("article-metadata-row", "true")
    }
}
