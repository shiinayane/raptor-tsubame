import Foundation
import Raptor

struct SidebarSectionTitle: HTML {
    let text: String

    var body: some HTML {
        Text(text)
            .font(.title5)
            .style(SidebarSectionTitleStyle())
            .data("sidebar-section-title", text.lowercased())
    }
}
