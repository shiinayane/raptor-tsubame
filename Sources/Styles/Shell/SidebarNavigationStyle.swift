import Foundation
import Raptor

struct SidebarSectionTitleStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.display(.block))
            .style(.textTransform(.uppercase))
            .style(.letterSpacing(.px(1)))
            .style(.fontSize(.px(13)))
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(palette.accent)
    }
}

struct SidebarNavItemStyle: Style {
    let isActive: Bool

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.display(.flex))
            .style(.alignItems(.center))
            .style(.justifyContent(.spaceBetween))
            .style(.gap(.px(10)))
            .style(.width(.percent(100)))
            .style(.minWidth(.px(0)))
            .style(.padding(.px(10)))
            .style(.borderRadius(.px(10)))
            .style(.textDecoration(.none))
            .background(isActive ? palette.surfaceRaised : palette.surface)
            .foregroundStyle(isActive ? palette.accent : palette.text)
            .border(isActive ? palette.accent : palette.border, width: 1, style: .solid)
    }
}

struct SidebarNavLabelStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.display(.block))
            .style(.minWidth(.px(0)))
            .style(.overflow(.hidden))
            .style(.textOverflow(.ellipsis))
            .style(.whiteSpace(.nowrap))
            .font(.system(size: 14, weight: .medium))
    }
}

struct SidebarCountBadgeStyle: Style {
    let isActive: Bool

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.justifyContent(.center))
            .style(.minWidth(.px(24)))
            .style(.padding(.px(4)))
            .style(.borderRadius(.px(999)))
            .style(.textAlign(.center))
            .style(.whiteSpace(.nowrap))
            .font(.system(size: 12, weight: .semibold))
            .background(isActive ? palette.accent : palette.canvasBackground)
            .foregroundStyle(isActive ? palette.surfaceRaised : palette.text)
            .border(isActive ? palette.accent : palette.border, width: 1, style: .solid)
    }
}

struct SidebarTagCloudStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.display(.flex))
            .style(.alignItems(.center))
            .style(.gap(.px(8)))
            .style(.flexWrap(.wrap))
            .style(.width(.percent(100)))
    }
}

struct SidebarTagChipStyle: Style {
    let isActive: Bool

    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.display(.inlineFlex))
            .style(.alignItems(.center))
            .style(.gap(.px(6)))
            .style(.padding(.px(8)))
            .style(.borderRadius(.px(999)))
            .style(.textDecoration(.none))
            .background(isActive ? palette.surfaceRaised : palette.surface)
            .foregroundStyle(isActive ? palette.accent : palette.text)
            .border(isActive ? palette.accent : palette.border, width: 1, style: .solid)
    }
}

struct SidebarTagLabelStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.display(.block))
            .style(.whiteSpace(.nowrap))
            .font(.system(size: 13, weight: .medium))
    }
}
