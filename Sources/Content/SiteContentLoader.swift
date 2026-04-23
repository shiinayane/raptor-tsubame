import Foundation

struct SiteContentDescriptor: Sendable {
    let sourceURL: URL
    let path: String?
    let kind: SiteContentKind
    let isPublished: Bool
    let category: String?
    let tags: [String]
}

struct SiteContentLoader {
    func load(from rootDirectory: URL) throws -> [SiteContentDescriptor] {
        let postsDirectory = rootDirectory.appending(path: "Posts")

        guard FileManager.default.fileExists(atPath: postsDirectory.path) else {
            return []
        }

        let markdownFiles = try markdownFiles(in: postsDirectory)
        return try markdownFiles.map(loadDescriptor(from:))
    }

    func publishedPostCount(in content: [SiteContentDescriptor]) -> Int {
        content.count { $0.kind == .post && $0.isPublished }
    }

    func publishedTagTerms(in content: [SiteContentDescriptor]) -> [TaxonomyTerm] {
        aggregatedTerms(
            kind: .tag,
            names: content
                .filter { $0.kind == .post && $0.isPublished }
                .flatMap(\.tags)
        )
    }

    func publishedCategoryTerms(in content: [SiteContentDescriptor]) -> [TaxonomyTerm] {
        aggregatedTerms(
            kind: .category,
            names: content
                .filter { $0.kind == .post && $0.isPublished }
                .compactMap(\.category)
        )
    }

    private func markdownFiles(in directory: URL) throws -> [URL] {
        let keys: Set<URLResourceKey> = [.isRegularFileKey]
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: Array(keys)
        ) else {
            return []
        }

        var files = [URL]()

        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: keys)
            guard values.isRegularFile == true, fileURL.pathExtension == "md" else {
                continue
            }
            files.append(fileURL)
        }

        return files.sorted { $0.path < $1.path }
    }

    private func loadDescriptor(from fileURL: URL) throws -> SiteContentDescriptor {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        let metadata = parseFrontMatter(in: contents)

        return SiteContentDescriptor(
            sourceURL: fileURL,
            path: metadata.stringValue(for: SiteContentMetadataKey.path.rawValue),
            kind: parseKind(metadata.stringValue(for: SiteContentMetadataKey.kind.rawValue)),
            isPublished: parsePublished(metadata.stringValue(for: SiteContentMetadataKey.published.rawValue)),
            category: parseSingleValue(metadata.stringValue(for: SiteContentMetadataKey.category.rawValue)),
            tags: parseTags(metadata.stringValue(for: SiteContentMetadataKey.tags.rawValue))
        )
    }

    private func aggregatedTerms(kind: TaxonomyKind, names: [String]) -> [TaxonomyTerm] {
        let uniqueNames = Set(
            names
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        )

        return uniqueNames
            .map { TaxonomyTerm(kind: kind, name: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func parseFrontMatter(in contents: String) -> [String: any Sendable] {
        let lines = contents.components(separatedBy: .newlines)
        guard lines.first == "---" else {
            return [:]
        }

        guard let closingIndex = lines[1...].firstIndex(of: "---") else {
            return [:]
        }

        var metadata = [String: any Sendable]()
        var index = 1

        while index < closingIndex {
            let line = lines[index]
            if let separator = line.firstIndex(of: ":") {
                let key = line[..<separator].trimmingCharacters(in: .whitespaces)
                let value = line[line.index(after: separator)...].trimmingCharacters(in: .whitespaces)
                metadata[key] = value
            }

            index += 1
        }

        return metadata
    }

    private func parseKind(_ rawValue: String?) -> SiteContentKind {
        guard let rawValue, let kind = SiteContentKind(rawValue: rawValue) else {
            return .post
        }
        return kind
    }

    private func parsePublished(_ rawValue: String?) -> Bool {
        guard let rawValue else {
            return true
        }

        return rawValue.lowercased() != "false"
    }

    private func parseSingleValue(_ rawValue: String?) -> String? {
        guard let rawValue = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines), !rawValue.isEmpty else {
            return nil
        }

        return rawValue
    }

    private func parseTags(_ rawValue: String?) -> [String] {
        guard let rawValue else {
            return []
        }

        return rawValue
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
