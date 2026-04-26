import Foundation
import Raptor

struct ArticleStyleSeed: HTML {
    var body: some HTML {
        EmptyHTML().style(ArticleSurfaceStyle())
        EmptyHTML().style(ArticleHeaderStyle())
        EmptyHTML().style(ArticleTitleBlockStyle())
        EmptyHTML().style(ArticleTitleAccentStyle())
        EmptyHTML().style(ArticleMetadataItemStyle())
        EmptyHTML().style(ArticleReadingIconStyle())
        EmptyHTML().style(ArticleMetadataIconStyle())
        EmptyHTML().style(ArticleCoverStyle())
        EmptyHTML().style(ArticleCoverImageStyle())
        EmptyHTML().style(ArticleBodyStyle())
        EmptyHTML().style(ArticleTocStyle())
        EmptyHTML().style(ArticleTocTitleStyle())
        EmptyHTML().style(ArticleTocListStyle())
        EmptyHTML().style(ArticleTocItemStyle(level: .h2))
        EmptyHTML().style(ArticleTocItemStyle(level: .h3))
        EmptyHTML().style(ArticleTocLinkStyle(level: .h2))
        EmptyHTML().style(ArticleTocLinkStyle(level: .h3))
        EmptyHTML().style(ArticleNavigationStyle())
        EmptyHTML().style(ArticleNavigationRowStyle())
        EmptyHTML().style(ArticleNavigationLinkStyle())
    }
}
