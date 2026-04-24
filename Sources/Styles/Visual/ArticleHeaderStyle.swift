import Foundation
import Raptor

struct ArticleHeaderStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.paddingBottom(.px(16)))
                .style(.lineHeight(1.35))
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid, edges: .bottom)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.paddingBottom(.px(18)))
                .style(.lineHeight(1.32))
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid, edges: .bottom)
        }
    }
}
