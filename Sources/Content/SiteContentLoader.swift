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
        let metadata = SiteContentMetadata(parseFrontMatter(in: contents))

        return SiteContentDescriptor(
            sourceURL: fileURL,
            path: metadata.path,
            kind: metadata.kind,
            isPublished: metadata.isPublished,
            category: metadata.category,
            tags: metadata.tags
        )
    }

    private func aggregatedTerms(kind: TaxonomyKind, names: [String]) -> [TaxonomyTerm] {
        var uniqueTermsByID = [String: TaxonomyTerm]()

        for name in names {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                continue
            }

            let term = TaxonomyTerm(kind: kind, name: trimmed)
            if uniqueTermsByID[term.id] == nil {
                uniqueTermsByID[term.id] = term
            }
        }

        return uniqueTermsByID.values
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

}
