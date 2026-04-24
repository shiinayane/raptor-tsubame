import Foundation
import Raptor

struct SiteThemePalette: Sendable {
    let pageBackground: Color
    let canvasBackground: Color
    let surface: Color
    let surfaceRaised: Color
    let border: Color
    let text: Color
    let mutedText: Color
    let accent: Color
    let shadow: Color

    static let light = SiteThemePalette(
        pageBackground: Color(red: 247, green: 251, blue: 255),
        canvasBackground: Color(red: 242, green: 248, blue: 255),
        surface: Color(red: 251, green: 253, blue: 255),
        surfaceRaised: Color(red: 255, green: 255, blue: 255),
        border: Color(red: 200, green: 221, blue: 242),
        text: Color(red: 19, green: 40, blue: 62),
        mutedText: Color(red: 88, green: 113, blue: 139),
        accent: Color(red: 74, green: 139, blue: 203),
        shadow: Color(red: 34, green: 86, blue: 137, opacity: 14%)
    )

    static let dark = SiteThemePalette(
        pageBackground: Color(red: 7, green: 17, blue: 29),
        canvasBackground: Color(red: 7, green: 17, blue: 29),
        surface: Color(red: 11, green: 23, blue: 38),
        surfaceRaised: Color(red: 16, green: 34, blue: 54),
        border: Color(red: 36, green: 71, blue: 98),
        text: Color(red: 220, green: 236, blue: 255),
        mutedText: Color(red: 142, green: 169, blue: 197),
        accent: Color(red: 120, green: 184, blue: 245),
        shadow: Color(red: 0, green: 0, blue: 0, opacity: 36%)
    )

    static func resolve(for environment: EnvironmentConditions) -> SiteThemePalette {
        environment.colorScheme == .dark ? .dark : .light
    }
}
