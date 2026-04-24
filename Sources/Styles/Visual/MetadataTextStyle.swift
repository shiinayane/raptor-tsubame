import Foundation
import Raptor

struct MetadataTextStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        let palette = SiteThemePalette.resolve(for: environment)

        content
            .style(.lineHeight(1.5))
            .foregroundStyle(palette.mutedText)
    }
}
