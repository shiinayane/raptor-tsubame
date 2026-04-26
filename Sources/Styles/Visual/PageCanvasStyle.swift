import Foundation
import Raptor

struct PageCanvasStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .background(palette.pageBackground)
                .style(.paddingBlock(.px(24)))
                .style(.paddingInline(.px(16)))
                .style(.minWidth(.px(0)))
        } else {
            content
                .background(palette.pageBackground)
                .style(.paddingBlock(.px(40)))
                .style(.paddingInline(.px(24)))
                .style(.minWidth(.px(0)))
        }
    }
}
