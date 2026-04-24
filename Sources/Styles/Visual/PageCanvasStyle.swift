import Foundation
import Raptor

struct PageCanvasStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.backgroundColor(.rgb(252, 246, 236)))
                .style(.paddingBlock(.px(24)))
                .style(.paddingInline(.px(16)))
                .style(.minWidth(.px(0)))
        } else {
            content
                .style(.backgroundColor(.rgb(252, 246, 236)))
                .style(.paddingBlock(.px(40)))
                .style(.paddingInline(.px(24)))
                .style(.minWidth(.px(0)))
        }
    }
}
