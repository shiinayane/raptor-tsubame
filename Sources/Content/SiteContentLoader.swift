import Foundation

struct SiteContentDescriptor: Sendable {
    let sourceURL: URL
    let title: String
    let description: String
    let date: Date?
    let path: String?
    let kind: SiteContentKind
    let isPublished: Bool
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
            title: metadata[.title] ?? "",
            description: metadata[.description] ?? "",
            date: parseDate(metadata[.date]),
            path: metadata[.path],
            kind: parseKind(metadata[.kind]),
            isPublished: parsePublished(metadata[.published])
        )
    }

    private func parseFrontMatter(in contents: String) -> [SiteContentMetadataKey: String] {
        let lines = contents.components(separatedBy: .newlines)
        guard lines.first == "---" else {
            return [:]
        }

        var metadata = [SiteContentMetadataKey: String]()
        var index = 1

        while index < lines.count {
            let line = lines[index]
            if line == "---" {
                break
            }

            if let separator = line.firstIndex(of: ":") {
                let key = line[..<separator].trimmingCharacters(in: .whitespaces)
                let value = line[line.index(after: separator)...].trimmingCharacters(in: .whitespaces)

                if let metadataKey = SiteContentMetadataKey(rawValue: key) {
                    metadata[metadataKey] = value
                }
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

    private func parseDate(_ rawValue: String?) -> Date? {
        guard let rawValue else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: rawValue)
    }
}
