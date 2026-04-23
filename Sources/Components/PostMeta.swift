import Foundation
import Raptor

struct PostMeta: HTML {
    let post: Post

    var body: some HTML {
        VStack(alignment: .leading, spacing: 4) {
            Time(post.date.formatted(date: .abbreviated, time: .omitted), dateTime: post.date)
            if !post.description.isEmpty {
                Text { post.description }
            }
        }
    }
}
