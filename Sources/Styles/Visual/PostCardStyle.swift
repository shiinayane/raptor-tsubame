import Foundation
import Raptor

struct PostCardStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.padding(.px(18)))
                .style(.lineHeight(1.55))
                .foregroundStyle(palette.text)
        } else {
            content
                .style(.padding(.px(22)))
                .style(.lineHeight(1.58))
                .foregroundStyle(palette.text)
        }
    }
}

struct PostCardCoverStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.height(.px(180)))
                .style(.borderRadius(.px(14)))
                .style(.overflow(.hidden))
                .background(palette.surfaceRaised)
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.height(.px(220)))
                .style(.borderRadius(.px(16)))
                .style(.overflow(.hidden))
                .background(palette.surfaceRaised)
                .border(palette.border, width: 1, style: .solid)
        }
    }
}

struct PostCardCoverImageStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.width(.percent(100)))
            .style(.height(.percent(100)))
            .style(.objectFit(.cover))
    }
}

struct PostCardTaxonomyStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.lineHeight(1.45))
            .foregroundStyle(palette.mutedText)
    }
}

struct PostCardStatsStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.alignItems(.center))
            .style(.lineHeight(1.4))
            .foregroundStyle(palette.mutedText)
    }
}
