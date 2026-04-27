import Foundation
import Raptor

struct SiteTheme: Theme {
    func theme(site: Content, colorScheme: ColorScheme) -> Content {
        let themedSite = site.syntaxHighlighterTheme(.xcode)

        if colorScheme == .dark {
            themedSite.background(SiteThemePalette.dark.pageBackground)
        } else {
            themedSite.background(SiteThemePalette.light.pageBackground)
        }
    }
}
