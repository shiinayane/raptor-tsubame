import Foundation
import Raptor

struct SidebarContainer<Content: HTML>: HTML {
    @HTMLBuilder let content: () -> Content

    var body: some HTML {
        Tag("aside") {
            VStack(alignment: .leading, spacing: 20) {
                content()
            }
        }
        .data("sidebar-shell", "true")
    }
}
