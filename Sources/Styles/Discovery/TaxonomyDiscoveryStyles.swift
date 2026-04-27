import Foundation
import Raptor

struct TaxonomyIndexListStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.width(.percent(100)))
    }
}

struct TaxonomyIndexSummaryStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.margin(.px(0)))
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(palette.mutedText)
    }
}

struct TaxonomyIndexItemStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.flex))
            .style(.alignItems(.center))
            .style(.justifyContent(.spaceBetween))
            .style(.paddingBlock(.px(14)))
            .style(.paddingInline(.px(16)))
            .style(.borderRadius(.px(14)))
            .style(.textDecoration(.none))
            .background(palette.surface)
            .foregroundStyle(palette.text)
            .border(palette.border, width: 1, style: .solid)
    }
}

struct TaxonomyIndexItemContextStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.margin(.px(0)))
            .style(.textTransform(.uppercase))
            .style(.letterSpacing(.px(1)))
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(palette.accent)
    }
}

struct TaxonomyIndexItemLinkStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.textDecoration(.none))
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(palette.text)
    }
}

struct TaxonomyIndexItemCountStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.margin(.px(0)))
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(palette.mutedText)
    }
}

struct TaxonomyDetailStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.width(.percent(100)))
    }
}

struct TaxonomyDetailContextStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.margin(.px(0)))
            .style(.textTransform(.uppercase))
            .style(.letterSpacing(.px(1)))
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(palette.accent)
    }
}

struct TaxonomyPostListHeaderStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.width(.percent(100)))
            .style(.paddingBlock(.px(18)))
            .style(.paddingInline(.px(18)))
            .style(.borderRadius(.px(16)))
            .background(palette.surface)
            .foregroundStyle(palette.text)
            .border(palette.border, width: 1, style: .solid)
    }
}
