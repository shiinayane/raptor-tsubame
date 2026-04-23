import Foundation

struct SiteProfile: Sendable, Equatable {
    static let defaultName = "Raptor Tsubame"

    let name: String
    let description: String
    let avatarText: String

    static let `default` = SiteProfile(
        name: defaultName,
        description: "A Raptor site studying Fuwari through content architecture and gradual shell refinement.",
        avatarText: "TS"
    )
}
