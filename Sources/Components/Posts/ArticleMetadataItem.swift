import Foundation
import Raptor

struct ArticleMetadataItem<Content: HTML>: HTML {
    let kind: String
    let icon: String
    let usesMetadataIcon: Bool
    let content: Content

    init(
        kind: String,
        icon: String,
        usesMetadataIcon: Bool = true,
        @HTMLBuilder content: () -> Content
    ) {
        self.kind = kind
        self.icon = icon
        self.usesMetadataIcon = usesMetadataIcon
        self.content = content()
    }

    var body: some HTML {
        HStack(alignment: .center, spacing: 8) {
            if usesMetadataIcon {
                Tag("i")
                    .class("bi", icon)
                    .style(ArticleMetadataIconStyle())
                    .aria(.hidden, "true")
                    .data("article-meta-icon", "true")
            } else {
                Tag("i")
                    .class("bi", icon)
                    .style(ArticleReadingIconStyle())
                    .aria(.hidden, "true")
                    .data("article-meta-icon", "true")
            }

            content
        }
        .style(ArticleMetadataItemStyle())
        .data("article-meta-item", kind)
    }
}
