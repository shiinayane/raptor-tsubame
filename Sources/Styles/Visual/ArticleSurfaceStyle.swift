import Foundation
import Raptor

struct ArticleSurfaceStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.padding(.px(20)))
                .style(.borderRadius(.px(18)))
                .style(.lineHeight(1.68))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.padding(.px(28)))
                .style(.borderRadius(.px(22)))
                .style(.lineHeight(1.72))
                .background(palette.surface)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
                .shadow(palette.shadow, radius: 24, x: 0, y: 14)
        }
    }
}
