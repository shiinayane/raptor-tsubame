import Foundation
import Raptor

struct PostListItem: HTML {
    let post: Post

    var body: some HTML {
        VStack(alignment: .leading, spacing: 10) {
            Link(post)
            PostMeta(post: post)
        }
        .style(ContentSurfaceStyle())
        .style(PostCardStyle())
        .data("post-card", "true")
    }
}
