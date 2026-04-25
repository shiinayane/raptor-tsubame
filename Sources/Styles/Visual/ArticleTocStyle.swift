import Foundation
import Raptor

struct ArticleTocStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)
        let background = environment.colorScheme == .dark
            ? palette.surfaceRaised
            : palette.canvasBackground

        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .padding(14)
                .style(.borderRadius(.px(18)))
                .background(background)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .style(.borderRadius(.px(20)))
                .background(background)
                .foregroundStyle(palette.text)
                .border(palette.border, width: 1, style: .solid)
        }
    }
}
