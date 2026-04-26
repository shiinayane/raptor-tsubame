import Foundation
import Raptor

struct PageFooterStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.flex))
            .style(.flexDirection(.column))
            .style(.alignItems(.center))
            .style(.gap(.px(12)))
            .style(.width(.percent(100)))
            .style(.paddingBlock(.px(28)))
            .style(.paddingInline(.px(16)))
            .foregroundStyle(palette.mutedText)
            .border(palette.border, width: 1, style: .solid, edges: .top)
    }
}

struct PageFooterLinksStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.display(.flex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.flexWrap(.wrap))
            .style(.gap(.px(10)))
    }
}

struct PageFooterLinkStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.paddingBlock(.px(6)))
            .style(.paddingInline(.px(8)))
            .style(.borderRadius(.px(10)))
            .style(.textDecoration(.none))
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(palette.accent)
    }
}
