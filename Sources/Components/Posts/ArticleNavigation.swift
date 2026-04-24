import Foundation
import Raptor

struct ArticleNavigation: HTML {
    let newer: Post?
    let older: Post?

    var body: some HTML {
        Tag("nav") {
            HStack(spacing: 16) {
                if let newer {
                    Link("Newer: \(newer.title)", destination: newer)
                }

                if let older {
                    Link("Older: \(older.title)", destination: older)
                }
            }
        }
        .data("article-navigation", "true")
    }
}
