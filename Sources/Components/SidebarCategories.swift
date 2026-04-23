import Foundation
import Raptor

struct SidebarCategories: HTML {
    let items: [SidebarTaxonomyItem]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categories").font(.title5)
            ForEach(items) { item in
                Link("\(item.name) (\(item.count))", destination: item.path)
            }
        }
        .data("sidebar-categories", "true")
    }
}
