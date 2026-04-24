import Foundation
import Raptor

struct SidebarPanelStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass < .regular {
            content
                .style(.width(.percent(100)))
                .style(.padding(.px(16)))
                .style(.borderRadius(.px(12)))
                .style(.backgroundColor(.rgb(255, 251, 244)))
                .foregroundStyle(Color(red: 73, green: 48, blue: 31))
                .border(Color(red: 232, green: 213, blue: 190), width: 1, style: .solid)
        } else {
            content
                .style(.width(.percent(100)))
                .style(.padding(.px(18)))
                .style(.borderRadius(.px(14)))
                .style(.backgroundColor(.rgb(255, 251, 244)))
                .foregroundStyle(Color(red: 73, green: 48, blue: 31))
                .border(Color(red: 232, green: 213, blue: 190), width: 1, style: .solid)
                .shadow(Color(red: 82, green: 49, blue: 28, opacity: 7%), radius: 18, x: 0, y: 10)
        }
    }
}
