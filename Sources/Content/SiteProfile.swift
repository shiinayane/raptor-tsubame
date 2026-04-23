import Foundation

struct SiteProfile: Sendable, Equatable {
    let name: String
    let description: String
    let avatarText: String

    static let `default` = SiteProfile(
        name: "Raptor Tsubame",
        description: "A Raptor site studying Fuwari through content architecture and gradual shell refinement.",
        avatarText: "TS"
    )
}
