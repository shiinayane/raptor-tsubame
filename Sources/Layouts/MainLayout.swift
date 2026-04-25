import Foundation
import Raptor

struct MainLayout: Layout {
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

    var body: some Document {
        Navigation { TopNavigation().body }
        Main {
            MarkdownReadingStylesheet()

            Tag("div") {
                Tag("div") {
                    Tag("div") {
                        content
                    }
                    .style(ShellMainStyle())

                    Tag("div") {
                        SidebarContainer {
                            SidebarProfile(profile: sidebarProfile)
                            SidebarCategories(items: sidebarCategories)
                            SidebarTags(items: sidebarTags)
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
        Footer { PageFooter() }
    }
}
