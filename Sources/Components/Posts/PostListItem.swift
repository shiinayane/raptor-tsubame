import Foundation
import Raptor

struct PostListItem: HTML {
    let post: Post

    var body: some HTML {
        VStack(alignment: .leading, spacing: 6) {
            Link(post)
            PostMeta(post: post)
        }
    }
}
