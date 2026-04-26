import Foundation
import Raptor

struct TopNavigation: HTML {
    let siteName: String
    let selection: NavigationSelection

    private var homeItem: NavigationItem {
        NavigationItem.primary[0]
    }

    private var archiveItem: NavigationItem {
        NavigationItem.primary[1]
    }

    private var aboutItem: NavigationItem {
        NavigationItem.primary[2]
    }

    var body: some HTML {
        Tag("nav") {
            Link(siteName, destination: SiteRoutes.home)
                .style(TopNavigationBrandStyle())
                .attribute("aria-label", "\(siteName) home")
                .data("nav-brand", "true")

            Tag("div") {
                primaryLink(homeItem)
                primaryLink(archiveItem)
                primaryLink(aboutItem)
            }
            .style(TopNavigationLinksStyle())
            .data("nav-primary", "true")

            Tag("div") {
                EmptyHTML()
            }
            .style(TopNavigationActionsStyle())
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
