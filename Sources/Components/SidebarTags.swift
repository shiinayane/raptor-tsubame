import Foundation
import Raptor

struct SidebarTags: HTML {
    let items: [SidebarTaxonomyItem]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags").font(.title5)
            ForEach(items) { item in
                Link("\(item.name) (\(item.count))", destination: item.path)
            }
        }
        .data("sidebar-tags", "true")
    }
}
