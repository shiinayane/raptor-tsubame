import Foundation
import Raptor

struct ArticleTitleBlockStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.alignItems(.flexStart))
                .style(.lineHeight(1.18))
                .style(.fontSize(.px(30)))
                .foregroundStyle(palette.text)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.alignItems(.flexStart))
                .style(.lineHeight(1.14))
                .style(.fontSize(.px(36)))
                .foregroundStyle(palette.text)
        }
    }
}

struct ArticleTitleAccentStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.width(.px(4)))
            .style(.height(.px(20)))
            .style(.borderRadius(.px(999)))
            .background(palette.accent)
    }
}
