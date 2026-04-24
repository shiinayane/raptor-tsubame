import Foundation
import Raptor

struct ContentSurfaceStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.backgroundColor(.rgb(255, 251, 244)))
                .style(.borderRadius(.px(16)))
                .border(Color(red: 232, green: 213, blue: 190), width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.backgroundColor(.rgb(255, 251, 244)))
                .style(.borderRadius(.px(18)))
                .border(Color(red: 232, green: 213, blue: 190), width: 1, style: .solid)
                .shadow(Color(red: 82, green: 49, blue: 28, opacity: 8%), radius: 22, x: 0, y: 12)
        }
    }
}
