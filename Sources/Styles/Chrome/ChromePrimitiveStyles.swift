import Foundation
import Raptor

struct ChromeSurfaceStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.width(.percent(100)))
            .style(.borderRadius(.px(16)))
            .style(.paddingBlock(.px(16)))
            .style(.paddingInline(.px(16)))
            .background(palette.surface)
            .foregroundStyle(palette.text)
            .border(palette.border, width: 1, style: .solid)
            .shadow(palette.shadow, radius: 18, x: 0, y: 10)
    }
}

struct ChromeButtonLinkStyle: Style {
    let isActive: Bool

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.gap(.px(8)))
            .style(.minWidth(.px(0)))
            .style(.paddingBlock(.px(10)))
            .style(.paddingInline(.px(14)))
            .style(.borderRadius(.px(12)))
            .style(.textDecoration(.none))
            .font(.system(size: 14, weight: .semibold))
            .background(isActive ? palette.surfaceRaised : palette.surface)
            .foregroundStyle(isActive ? palette.accent : palette.text)
            .border(isActive ? palette.accent : palette.border, width: 1, style: .solid)
    }
}

struct ChromeBadgeStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.paddingBlock(.px(3)))
            .style(.paddingInline(.px(8)))
            .style(.borderRadius(.px(999)))
            .font(.system(size: 12, weight: .semibold))
            .background(palette.canvasBackground)
            .foregroundStyle(palette.mutedText)
            .border(palette.border, width: 1, style: .solid)
    }
}

struct ChromeSectionTitleStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.block))
            .style(.textTransform(.uppercase))
            .style(.letterSpacing(.px(1)))
            .style(.fontSize(.px(13)))
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(palette.accent)
    }
}

struct ChromeIconBoxStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.width(.px(32)))
            .style(.height(.px(32)))
            .style(.borderRadius(.px(10)))
            .font(.system(size: 13, weight: .bold))
            .background(palette.surfaceRaised)
            .foregroundStyle(palette.accent)
            .border(palette.border, width: 1, style: .solid)
    }
}

struct ChromeMutedTextStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .foregroundStyle(palette.mutedText)
            .font(.system(size: 14, weight: .regular))
    }
}
