import Foundation
import Raptor

struct ArticleNavigationStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.gap(.px(12)))
                .margin(.top, 4)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.gap(.px(12)))
                .margin(.top, 8)
        }
    }
}

struct ArticleNavigationLinkStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)
        let background = environment.colorScheme == .dark
            ? palette.surfaceRaised
            : palette.canvasBackground

        return content
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .style(.borderRadius(.px(14)))
            .background(background)
            .foregroundStyle(palette.accent)
            .border(palette.border, width: 1, style: .solid)
            .textDecoration(.none)
            .fontWeight(.bold)
    }
}
