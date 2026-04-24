import Foundation
import Raptor

struct ArticleBodyStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.lineHeight(1.78))
                .foregroundStyle(palette.text)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.lineHeight(1.82))
                .foregroundStyle(palette.text)
        }
    }
}
