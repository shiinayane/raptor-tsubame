import Foundation

enum SiteContentKind: String, Sendable {
    case post
    case page
}

enum SiteContentMetadataKey: String, Sendable {
    case title
    case date
    case description
    case published
    case path
    case kind
}
