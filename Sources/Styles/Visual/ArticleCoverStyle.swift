import Foundation
import Raptor

struct ArticleCoverStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.height(.px(220)))
                .style(.borderRadius(.px(18)))
                .style(.overflow(.hidden))
                .background(palette.surfaceRaised)
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.height(.px(320)))
                .style(.borderRadius(.px(22)))
                .style(.overflow(.hidden))
                .background(palette.surfaceRaised)
                .border(palette.border, width: 1, style: .solid)
        }
    }
}

struct ArticleCoverImageStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.width(.percent(100)))
            .style(.height(.percent(100)))
            .style(.objectFit(.cover))
    }
}
