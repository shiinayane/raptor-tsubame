import Foundation
import Raptor

struct SidebarTagChip: HTML {
    let item: TaxonomyCountItem
    let isActive: Bool

    var body: some HTML {
        if isActive {
            Link(destination: item.path) {
                linkContent
            }
                .style(SidebarTagChipStyle(isActive: isActive))
                .data("sidebar-tag-chip", "true")
                .data("sidebar-term-slug", item.term.slug)
                .data("sidebar-current", "true")
                .aria(.current, "page")
                .aria(.label, "\(item.name) (\(item.count))")
        } else {
            Link(destination: item.path) {
                linkContent
            }
                .style(SidebarTagChipStyle(isActive: isActive))
                .data("sidebar-tag-chip", "true")
                .data("sidebar-term-slug", item.term.slug)
                .aria(.label, "\(item.name) (\(item.count))")
        }
    }

    @InlineContentBuilder private var linkContent: some InlineContent {
        InlineText(item.name)
            .style(SidebarTagLabelStyle())
        InlineText("\(item.count)")
            .style(SidebarCountBadgeStyle(isActive: isActive))
    }
}
