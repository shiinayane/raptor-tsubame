import Foundation
import Raptor

struct SidebarCategories: HTML {
    let items: [TaxonomyCountItem]
    let selection: SidebarSelection

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            SidebarSectionTitle(text: "Categories")
            VStack(alignment: .leading, spacing: 6) {
                ForEach(items) { item in
                    SidebarNavItem(item: item, isActive: selection.isActive(item))
                }
            }
            .data("sidebar-nav-list", "categories")
        }
        .style(SidebarPanelStyle())
        .data("sidebar-categories", "true")
    }
}
