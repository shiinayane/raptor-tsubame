import Foundation
import Raptor

struct SidebarTags: HTML {
    let items: [TaxonomyCountItem]
    let selection: SidebarSelection

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            SidebarSectionTitle(text: "Tags")
            Tag("div") {
                ForEach(items) { item in
                    SidebarTagChip(item: item, isActive: selection.isActive(item))
                }
            }
            .style(SidebarTagCloudStyle())
            .data("sidebar-tag-cloud", "true")
        }
        .style(SidebarPanelStyle())
        .data("sidebar-tags", "true")
    }
}
