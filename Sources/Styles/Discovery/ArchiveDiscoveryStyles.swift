import Foundation
import Raptor

struct ArchiveDiscoveryPageStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.width(.percent(100)))
            .style(.lineHeight(1.58))
            .foregroundStyle(palette.text)
    }
}

struct ArchiveYearGroupStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.width(.percent(100)))
            .style(.padding(.px(22)))
            .style(.borderRadius(.px(20)))
            .background(palette.surface)
            .foregroundStyle(palette.text)
            .border(palette.border, width: 1, style: .solid)
            .shadow(palette.shadow, radius: 20, x: 0, y: 12)
    }
}

struct ArchiveYearTitleStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.margin(.px(0)))
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(palette.text)
    }
}

struct ArchiveYearCountStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.display(.inlineFlex))
            .style(.paddingBlock(.px(4)))
            .style(.paddingInline(.px(9)))
            .style(.borderRadius(.px(999)))
            .font(.system(size: 12, weight: .semibold))
            .background(palette.canvasBackground)
            .foregroundStyle(palette.mutedText)
            .border(palette.border, width: 1, style: .solid)
    }
}

struct ArchiveEntryStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.width(.percent(100)))
            .style(.paddingBlock(.px(16)))
            .style(.paddingInline(.px(18)))
            .style(.borderRadius(.px(16)))
            .background(palette.surfaceRaised)
            .border(palette.border, width: 1, style: .solid)
    }
}

struct ArchiveEntryDateStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.whiteSpace(.nowrap))
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(palette.accent)
    }
}

struct ArchiveEntryTitleStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.textDecoration(.none))
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(palette.text)
    }
}

struct ArchiveEntryDescriptionStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.margin(.px(0)))
            .foregroundStyle(palette.mutedText)
            .font(.system(size: 14, weight: .regular))
    }
}

struct ArchiveEntryTaxonomyStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        return content
            .style(.lineHeight(1.45))
            .foregroundStyle(palette.mutedText)
    }
}
