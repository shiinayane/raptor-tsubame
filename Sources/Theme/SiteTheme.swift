import Foundation
import Raptor

struct SiteTheme: Theme {
    func theme(site: Content, colorScheme: ColorScheme) -> Content {
        if colorScheme == .dark {
            site.background(SiteThemePalette.dark.pageBackground)
        } else {
            site.background(SiteThemePalette.light.pageBackground)
        }
    }
}
