import Foundation
import Raptor

struct SidebarPanelStyle: Style {
    func style(content: Content, environment: EnvironmentConditions) -> Content {
        if environment.horizontalSizeClass == .compact {
            content
                .style(.padding(.px(16)))
                .style(.borderRadius(.px(10)))
                .style(.backgroundColor(.rgb(250, 250, 248)))
                .border(Color(red: 230, green: 228, blue: 222), width: 1, style: .solid)
        } else {
            content
                .style(.padding(.px(18)))
                .style(.borderRadius(.px(12)))
                .style(.backgroundColor(.rgb(250, 250, 248)))
                .border(Color(red: 230, green: 228, blue: 222), width: 1, style: .solid)
                .shadow(Color(red: 40, green: 36, blue: 30, opacity: 6%), radius: 18, x: 0, y: 10)
        }
    }
}
