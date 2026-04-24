import Foundation
import Raptor

struct ArticleReadingStats: HTML {
    let post: Post

    var body: some HTML {
        HStack(spacing: 8) {
            Text("\(post.estimatedReadingMinutes) min read")
            Text("\(post.estimatedWordCount) words")
        }
        .style(MetadataTextStyle())
        .data("reading-stats", "true")
    }
}
