import Foundation
import Raptor

struct SidebarProfile: HTML {
    let profile: SiteProfile

    var body: some HTML {
        VStack(alignment: .leading, spacing: 10) {
            Text(profile.avatarText)
                .font(.title2)
            Text(profile.name)
                .font(.title3)
            Text(profile.description)
        }
        .style(SidebarPanelStyle())
        .data("sidebar-profile", "true")
    }
}
