import Foundation
import Raptor

struct TopNavigation: HTML {
    let siteName: String
    let selection: NavigationSelection

    var body: some HTML {
        Tag("div") {
            Link(siteName, destination: SiteRoutes.home)
                .style(TopNavigationBrandStyle())
                .attribute("aria-label", "\(siteName) home")
                .data("nav-brand", "true")

            Tag("div") {
                ForEach(NavigationItem.primary) { item in
                    primaryLink(item)
                }
            }
            .style(TopNavigationLinksStyle())
            .data("nav-primary", "true")

            Tag("div") {
                EmptyHTML()
            }
            .style(TopNavigationActionsStyle())
            .attribute("aria-hidden", "true")
            .data("nav-actions", "reserved")
        }
        .style(TopNavigationStyle())
        .data("top-navigation", "true")
    }

    private func primaryLink(_ item: NavigationItem) -> some HTML {
        ChromeButtonLink(
            item.label,
            destination: item.path,
            markerName: "nav-item",
            markerValue: item.id.rawValue,
            isActive: selection.isActive(item)
        )
    }
}
