import Foundation
import Raptor

struct TopNavigation: HTML {
    let siteName: String
    let selection: NavigationSelection

    var body: some HTML {
        Link(siteName, destination: SiteRoutes.home)
            .style(TopNavigationBrandStyle())
            .attribute("aria-label", "\(siteName) home")
            .data("top-navigation", "true")
            .data("nav-brand", "true")

        ForEach(NavigationItem.primary) { item in
            primaryLink(item)
        }

        Tag("span") {
            EmptyHTML()
        }
        .style(TopNavigationActionsStyle())
        .attribute("aria-hidden", "true")
        .data("nav-actions", "reserved")
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
