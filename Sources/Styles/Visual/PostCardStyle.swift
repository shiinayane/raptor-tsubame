import Foundation
import Raptor

struct PostCardStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        if environment.horizontalSizeClass < .regular {
            content
                .style(.padding(.px(18)))
                .style(.lineHeight(1.55))
                .foregroundStyle(palette.text)
        } else {
            content
                .style(.padding(.px(22)))
                .style(.lineHeight(1.58))
                .foregroundStyle(palette.text)
        }
    }
}
