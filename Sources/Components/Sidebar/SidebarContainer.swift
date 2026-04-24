import Foundation
import Raptor

struct SidebarContainer<Content: HTML>: HTML {
    @HTMLBuilder let content: () -> Content

    var body: some HTML {
        Tag("aside") {
            VStack(alignment: .leading, spacing: 16) {
                content()
            }
        }
        .data("sidebar-container", "true")
    }
}
