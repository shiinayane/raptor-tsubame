import Foundation
import Raptor

struct ArticleNavigation: HTML {
    let newer: Post?
    let older: Post?

    var body: some HTML {
        Tag("nav") {
            HStack(spacing: 12) {
                if let newer {
                    Link("Newer: \(newer.title)", destination: newer)
                        .style(ArticleNavigationLinkStyle())
                        .data("article-navigation-link", "newer")
                }

                Spacer()

                if let older {
                    Link("Older: \(older.title)", destination: older)
                        .style(ArticleNavigationLinkStyle())
                        .data("article-navigation-link", "older")
                }
            }
        }
        .style(ArticleNavigationStyle())
        .data("article-navigation", "true")
    }
}
