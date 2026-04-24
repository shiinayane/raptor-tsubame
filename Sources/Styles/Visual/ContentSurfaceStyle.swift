import Foundation
import Raptor

struct ContentSurfaceStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .background(palette.surface)
                .style(.borderRadius(.px(16)))
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .background(palette.surface)
                .style(.borderRadius(.px(18)))
                .border(palette.border, width: 1, style: .solid)
                .shadow(palette.shadow, radius: 22, x: 0, y: 12)
        }
    }
}
