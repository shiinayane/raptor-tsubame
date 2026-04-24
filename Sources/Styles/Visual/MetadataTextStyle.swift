import Foundation
import Raptor

struct MetadataTextStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        content
            .style(.lineHeight(1.5))
            .foregroundStyle(Color(red: 126, green: 83, blue: 47))
    }
}
