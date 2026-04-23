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
            Tag("div") {
                HStack(alignment: .top, spacing: 32) {
                    SidebarContainer {
                        SidebarProfile(profile: sidebarProfile)
                        SidebarCategories(items: sidebarCategories)
                        SidebarTags(items: sidebarTags)
                    }

                    content
                }
            }
            .data("sidebar-shell", "true")
        }
        Footer { PageFooter() }
    }
}
