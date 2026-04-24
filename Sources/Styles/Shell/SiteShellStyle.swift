import Foundation
import Raptor

struct SiteShellStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.display(.flex))
                .style(.flexDirection(.column))
                .style(.gap(.px(24)))
                .style(.width(.percent(100)))
        } else {
            content
                .style(.display(.flex))
                .style(.flexDirection(.row))
                .style(.alignItems(.flexStart))
                .style(.gap(.px(32)))
                .style(.width(.percent(100)))
                .style(.maxWidth(.px(1120)))
                .style(.marginInline(nil))
        }
    }
}
