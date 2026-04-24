import Foundation
import Raptor

struct PostList: HTML {
    let posts: [Post]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(posts) { post in
                PostListItem(post: post)
            }
        }
    }
}
