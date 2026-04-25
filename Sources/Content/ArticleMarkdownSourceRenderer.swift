import Foundation
import Raptor

struct ArticleMarkdownSourceRenderer {
    let rootDirectory: URL

    init(rootDirectory: URL = articlePackageRoot()) {
        self.rootDirectory = rootDirectory
    }

    func render(post: Post) -> ArticleRenderedMarkdown? {
        render(path: post.path)
    }

    func render(path: String) -> ArticleRenderedMarkdown? {
        let normalizedPath = normalizedContentPath(path)

        for sourceURL in candidateSourceURLs(for: normalizedPath) {
            guard FileManager.default.fileExists(atPath: sourceURL.path),
                  let rawMarkdown = try? String(contentsOf: sourceURL, encoding: .utf8),
                  sourceMatches(rawMarkdown, sourceURL: sourceURL, normalizedPath: normalizedPath) else {
                continue
            }

            var processor = SafeMarkdownToHTML()
            guard let processed = try? processor.process(markdownBody(from: rawMarkdown)) else {
                return nil
            }

            return ArticleRenderedMarkdown(
                html: #"<div class="markdown" data-markdown-content="true">\#(processed.body)</div>"#
            )
        }

        return nil
    }

    private func candidateSourceURLs(for normalizedPath: String) -> [URL] {
        let postsDirectory = rootDirectory.appending(path: "Posts")
        let slug = normalizedPath
            .split(separator: "/")
            .last
            .map(String.init)

        guard let slug else {
            return []
        }

        return [
            postsDirectory.appending(path: "posts/\(slug).md"),
            postsDirectory.appending(path: "pages/\(slug).md"),
            postsDirectory.appending(path: "\(slug).md")
        ]
    }

    private func sourceMatches(_ markdown: String, sourceURL: URL, normalizedPath: String) -> Bool {
        let metadataPath = frontMatterValue(named: "path", in: markdown).map(normalizedContentPath)
        return metadataPath == normalizedPath || inferredPath(from: sourceURL) == normalizedPath
    }

    private func inferredPath(from sourceURL: URL) -> String? {
        let postsDirectory = rootDirectory.appending(path: "Posts").standardizedFileURL
        let standardizedURL = sourceURL.standardizedFileURL
        let relativePath = standardizedURL.path.replacingOccurrences(
            of: postsDirectory.path + "/",
            with: ""
        )
        let components = relativePath.split(separator: "/").map(String.init)
        guard components.count >= 2 else {
            return nil
        }

        let folder = components[components.count - 2]
        let slug = URL(fileURLWithPath: components.last ?? "")
            .deletingPathExtension()
            .lastPathComponent

        return normalizedContentPath("/\(folder)/\(slug)/")
    }
}

private func markdownBody(from markdown: String) -> String {
    let lines = markdown.components(separatedBy: .newlines)
    guard lines.first == "---",
          let closingIndex = lines[1...].firstIndex(of: "---") else {
        return markdown
    }

    return lines[(closingIndex + 1)...].joined(separator: "\n")
}

private func frontMatterValue(named name: String, in markdown: String) -> String? {
    let lines = markdown.components(separatedBy: .newlines)
    guard lines.first == "---",
          let closingIndex = lines[1...].firstIndex(of: "---") else {
        return nil
    }

    for line in lines[1..<closingIndex] {
        guard let separator = line.firstIndex(of: ":") else {
            continue
        }

        let key = line[..<separator].trimmingCharacters(in: .whitespacesAndNewlines)
        guard key == name else {
            continue
        }

        return line[line.index(after: separator)...]
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    return nil
}

private func normalizedContentPath(_ path: String) -> String {
    let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    return "/\(trimmed)/"
}

private func articlePackageRoot(from file: StaticString = #filePath) -> URL {
    var directory = URL(filePath: "\(file)").deletingLastPathComponent()

    while directory.path != "/" {
        if FileManager.default.fileExists(atPath: directory.appending(path: "Package.swift").path) {
            return directory
        }
        directory.deleteLastPathComponent()
    }

    fatalError("Unable to locate package root.")
}
