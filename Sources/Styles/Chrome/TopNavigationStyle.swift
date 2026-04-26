import Foundation
import Raptor

struct TopNavigationStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.display(.flex))
                .style(.flexDirection(.column))
                .style(.gap(.px(14)))
                .style(.width(.percent(100)))
                .style(.paddingBlock(.px(14)))
                .style(.paddingInline(.px(16)))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
                .shadow(palette.shadow, radius: 16, x: 0, y: 8)
        } else {
            content
                .style(.display(.flex))
                .style(.alignItems(.center))
                .style(.justifyContent(.spaceBetween))
                .style(.gap(.px(18)))
                .style(.width(.percent(100)))
                .style(.maxWidth(.px(1120)))
                .style(.marginInline(nil))
                .style(.paddingBlock(.px(16)))
                .style(.paddingInline(.px(20)))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
                .shadow(palette.shadow, radius: 18, x: 0, y: 10)
        }
    }
}

struct TopNavigationBrandStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.paddingBlock(.px(8)))
            .style(.paddingInline(.px(10)))
            .style(.borderRadius(.px(12)))
            .style(.textDecoration(.none))
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(palette.text)
    }
}

struct TopNavigationLinksStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.display(.flex))
                .style(.flexWrap(.wrap))
                .style(.gap(.px(8)))
                .style(.width(.percent(100)))
        } else {
            content
                .style(.display(.flex))
                .style(.alignItems(.center))
                .style(.justifyContent(.center))
                .style(.gap(.px(10)))
        }
    }
}
