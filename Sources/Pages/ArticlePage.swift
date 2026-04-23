import Foundation
import Raptor

struct ArticlePage: PostPage {
    var body: some HTML {
        VStack(alignment: .leading, spacing: 16) {
            Text(post.title)
                .font(.title1)

            PostMeta(post: post)

            MarkdownContent(post: post)
        }
    }
}

