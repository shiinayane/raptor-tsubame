import Foundation
import Raptor

struct MarkdownContent: HTML {
    let post: Post

    var body: some HTML {
        post.text
    }
}
