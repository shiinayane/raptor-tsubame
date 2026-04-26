import Foundation
import Raptor

struct ChromeStyleSeed: HTML {
    var body: some HTML {
        EmptyHTML().style(ChromeSurfaceStyle())
        EmptyHTML().style(ChromeButtonLinkStyle(isActive: false))
        EmptyHTML().style(ChromeButtonLinkStyle(isActive: true))
        EmptyHTML().style(ChromeBadgeStyle())
        EmptyHTML().style(ChromeSectionTitleStyle())
        EmptyHTML().style(ChromeIconBoxStyle())
        EmptyHTML().style(ChromeMutedTextStyle())
    }
}
