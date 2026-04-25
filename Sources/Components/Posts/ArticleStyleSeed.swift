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
        EmptyHTML().style(ArticleNavigationStyle())
        EmptyHTML().style(ArticleNavigationLinkStyle())
    }
}
