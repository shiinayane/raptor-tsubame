import Foundation
import Raptor

struct MainLayout: Layout {
    @Environment(\.page) private var page
    @Environment(\.posts) private var posts
    @Environment(\.site) private var site

    private var sidebarProfile: SiteProfile {
        SiteProfile(
            name: site.name,
            description: site.description ?? SiteProfile.default.description,
            avatarText: SiteProfile.default.avatarText
        )
    }

    private var sidebarCategories: [TaxonomyCountItem] {
        PostQueries.sidebarCategories(posts)
    }

    private var sidebarTags: [TaxonomyCountItem] {
        PostQueries.sidebarTags(posts)
    }

    private var sidebarSelection: SidebarSelection {
        SidebarSelection(path: page.url.path)
    }

    private var navigationSelection: NavigationSelection {
        NavigationSelection(path: page.url.path)
    }

    var body: some Document {
        Navigation { TopNavigation(siteName: site.name, selection: navigationSelection).body }
        Main {
            Tag("div") {
                Tag("div") {
                    Tag("div") {
                        content
                    }
                    .style(ShellMainStyle())

                    Tag("div") {
                        SidebarContainer {
                            SidebarProfile(profile: sidebarProfile)
                            SidebarCategories(items: sidebarCategories, selection: sidebarSelection)
                            SidebarTags(items: sidebarTags, selection: sidebarSelection)
                        }
                    }
                    .style(ShellSidebarStyle())
                    .data("sidebar-position", "leading")
                }
                .class("site-shell")
                .style(SiteShellStyle())
                .data("shell-layout", "two-column")
                .data("sidebar-shell", "true")
            }
            .style(PageCanvasStyle())
        }
        .pageResource("/css/markdown-reading.css", relationship: .stylesheet)
        Footer { PageFooter(siteName: site.name) }
    }
}
