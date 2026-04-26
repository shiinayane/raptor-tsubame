import Foundation
import Raptor

struct SidebarTagChip: HTML {
    let item: TaxonomyCountItem
    let isActive: Bool

    var body: some HTML {
        if isActive {
            Link(label, destination: item.path)
                .data("sidebar-tag-chip", "true")
                .data("sidebar-term-slug", item.term.slug)
                .data("sidebar-current", "true")
                .aria(.current, "page")
        } else {
            Link(label, destination: item.path)
                .data("sidebar-tag-chip", "true")
                .data("sidebar-term-slug", item.term.slug)
        }
    }

    private var label: String {
        "\(item.name) (\(item.count))"
    }
}
