import Foundation
import Raptor

struct ShellSidebarStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass == .compact {
            content
                .style(.width(.percent(100)))
                .style(.order(0))
        } else {
            content
                .style(.order(-1))
                .style(.flexGrow(0))
                .style(.flexShrink(0))
                .style(.flexBasis(.length(.px(280))))
                .style(.width(.px(280)))
                .style(.maxWidth(.px(300)))
        }
    }
}
