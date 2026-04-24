import Foundation
import Raptor

struct ArticleMetadataItemStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.alignItems(.center))
            .style(.lineHeight(1.35))
            .foregroundStyle(palette.mutedText)
    }
}

struct ArticleReadingIconStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.width(.px(24)))
            .style(.height(.px(24)))
            .style(.borderRadius(.px(999)))
            .background(palette.surfaceRaised)
            .foregroundStyle(palette.accent)
            .border(palette.border, width: 1, style: .solid)
    }
}

struct ArticleMetadataIconStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.width(.px(32)))
            .style(.height(.px(32)))
            .style(.borderRadius(.px(999)))
            .background(palette.surfaceRaised)
            .foregroundStyle(palette.accent)
            .border(palette.border, width: 1, style: .solid)
    }
}
