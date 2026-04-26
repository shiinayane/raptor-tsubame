import Foundation
import Raptor

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
