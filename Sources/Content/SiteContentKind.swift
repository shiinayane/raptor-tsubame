import Foundation

enum SiteContentKind: String, Sendable {
    case post
    case page
}

enum SiteContentMetadataKey: String, Sendable {
    case kind
    case published
    case path
    case category
    case tags
}

extension Dictionary where Key == String, Value == any Sendable {
    func stringValue(for key: String) -> String? {
        self[key] as? String
    }
}
