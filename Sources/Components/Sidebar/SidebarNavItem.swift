import Foundation
import Raptor

struct SidebarNavItem: HTML {
    let item: TaxonomyCountItem
    let isActive: Bool

    var body: some HTML {
        if isActive {
            Link(destination: item.path) {
                linkContent
            }
                .style(SidebarNavItemStyle(isActive: isActive))
                .data("sidebar-nav-item", "category")
                .data("sidebar-term-slug", item.term.slug)
                .data("sidebar-current", "true")
                .aria(.current, "page")
        } else {
            Link(destination: item.path) {
                linkContent
            }
                .style(SidebarNavItemStyle(isActive: isActive))
                .data("sidebar-nav-item", "category")
                .data("sidebar-term-slug", item.term.slug)
        }
    }

    @InlineContentBuilder private var linkContent: some InlineContent {
        InlineText(item.name)
            .style(SidebarNavLabelStyle())
        InlineText("\(item.count)")
            .style(SidebarCountBadgeStyle(isActive: isActive))
    }
}
