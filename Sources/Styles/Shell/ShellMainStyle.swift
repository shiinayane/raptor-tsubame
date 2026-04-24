import Foundation
import Raptor

struct ShellMainStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.minWidth(.px(0)))
        } else {
            content
                .style(.flexGrow(1))
                .style(.flexShrink(1))
                .style(.flexBasis(.length(.px(0))))
                .style(.minWidth(.px(0)))
                .style(.maxWidth(.px(760)))
        }
    }
}
