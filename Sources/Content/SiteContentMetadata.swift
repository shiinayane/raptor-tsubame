import Foundation

struct SiteContentMetadata: Sendable {
    let values: [String: any Sendable]

    init(_ values: [String: any Sendable]) {
        self.values = values
    }

    var kind: SiteContentKind {
        let rawValue = stringValue(for: .kind)
        return SiteContentKind(rawValue: rawValue ?? "") ?? .post
    }

    var isPublished: Bool {
        guard let rawValue = stringValue(for: .published) else {
            return true
        }

        return Bool(rawValue) ?? true
    }

    var path: String? {
        trimmedValue(for: .path)
    }

    var category: String? {
        trimmedValue(for: .category)
    }

    var tags: [String] {
        guard let rawValue = stringValue(for: .tags) else {
            return []
        }

        return rawValue
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func stringValue(for key: SiteContentMetadataKey) -> String? {
        values.stringValue(for: key.rawValue)
    }

    private func trimmedValue(for key: SiteContentMetadataKey) -> String? {
        guard let rawValue = stringValue(for: key)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawValue.isEmpty else {
            return nil
        }

        return rawValue
    }
}
