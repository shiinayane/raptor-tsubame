import Foundation
import Raptor

struct ArticleReadingStats: HTML {
    let post: Post

    var body: some HTML {
        HStack(spacing: 8) {
            ArticleMetadataItem(kind: "reading-minutes", icon: "bi-clock", usesMetadataIcon: false) {
                Text("\(post.estimatedReadingMinutes) min read")
                    .data("article-meta-content", "reading-minutes")
            }

            ArticleMetadataItem(kind: "reading-words", icon: "bi-text-left", usesMetadataIcon: false) {
                Text("\(post.estimatedWordCount) words")
                    .data("article-meta-content", "reading-words")
            }
        }
        .style(MetadataTextStyle())
        .data("reading-stats", "true")
    }
}
