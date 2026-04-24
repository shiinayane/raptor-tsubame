import Foundation
import Raptor

struct ArticleTitleBlock: HTML {
    let title: String

    var body: some HTML {
        HStack(alignment: .top, spacing: 12) {
            Tag("span")
                .style(ArticleTitleAccentStyle())
                .aria(.hidden, "true")
                .data("article-title-accent", "true")

            Text(title)
                .font(.title1)
        }
        .style(ArticleTitleBlockStyle())
        .data("article-title", "true")
    }
}
