import Foundation
import Raptor

struct ArticleStyleSeed: HTML {
    var body: some HTML {
        EmptyHTML().style(ArticleSurfaceStyle())
        EmptyHTML().style(ArticleHeaderStyle())
        EmptyHTML().style(ArticleBodyStyle())
    }
}
