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
            guard let processed = try? processor.process(preprocessedMarkdownBody(from: rawMarkdown)) else {
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

    private func preprocessedMarkdownBody(from markdown: String) -> String {
        let sourcesDirectory = rootDirectory.appending(path: "Sources")
        let body = markdownBody(from: markdown)
        let (protectedBody, escapedTokens) = protectEscapedTokens(in: body)
        let withCodeIncludes = expandCodeIncludes(in: protectedBody, sourcesDirectory: sourcesDirectory)
        let withTextIncludes = expandTextIncludes(in: withCodeIncludes, sourcesDirectory: sourcesDirectory)
        return restoreEscapedTokens(in: withTextIncludes, tokens: escapedTokens)
    }

    private func expandTextIncludes(in markdown: String, sourcesDirectory: URL) -> String {
        replacingMatches(in: markdown, pattern: #"@\{text:([^}]+)\}"#) { match, source in
            guard let pathRange = Range(match.range(at: 1), in: source),
                  let include = loadInclude(String(source[pathRange]), sourcesDirectory: sourcesDirectory) else {
                return nil
            }

            return include.trimmingCharacters(in: .newlines)
        }
    }

    private func expandCodeIncludes(in markdown: String, sourcesDirectory: URL) -> String {
        replacingMatches(in: markdown, pattern: #"@\{code(?::(noimports))?:([^}]+)\}"#) { match, source in
            guard let pathRange = Range(match.range(at: 2), in: source),
                  let include = loadInclude(String(source[pathRange]), sourcesDirectory: sourcesDirectory) else {
                return nil
            }

            let rawPath = String(source[pathRange])
            let noImports = match.range(at: 1).location != NSNotFound
            let code = noImports ? stripLeadingImports(from: include) : include
            let language = languageTag(for: rawPath)

            return """
            ```\(language)
            \(code.trimmingCharacters(in: .newlines))
            ```
            """
        }
    }

    private func protectEscapedTokens(in markdown: String) -> (String, [EscapedToken]) {
        var tokens: [EscapedToken] = []
        var index = 0
        let protected = replacingMatches(in: markdown, pattern: #"\$@\{[^}]+\}"#) { match, source in
            guard let matchRange = Range(match.range, in: source) else {
                return nil
            }

            let placeholder = "__ARTICLE_ESCAPED_TOKEN_\(index)__"
            let original = String(source[matchRange].dropFirst())
            tokens.append(EscapedToken(placeholder: placeholder, original: original))
            index += 1
            return placeholder
        }

        return (protected, tokens)
    }

    private func restoreEscapedTokens(in markdown: String, tokens: [EscapedToken]) -> String {
        tokens.reduce(markdown) { result, token in
            result.replacingOccurrences(of: token.placeholder, with: token.original)
        }
    }

    private func loadInclude(_ path: String, sourcesDirectory: URL) -> String? {
        try? String(contentsOf: sourcesDirectory.appendingPathComponent(path), encoding: .utf8)
    }

    private func languageTag(for path: String) -> String {
        let pathExtension = URL(fileURLWithPath: path).pathExtension
        let aliases = [
            "js": "javascript",
            "ts": "typescript",
            "md": "markdown",
            "m": "objectivec"
        ]

        return aliases[pathExtension] ?? pathExtension
    }

    private func stripLeadingImports(from source: String) -> String {
        let prefixes = ["import ", "from ", "use ", "#include"]
        let lines = source.split(separator: "\n", omittingEmptySubsequences: false)
        var index = 0

        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)

            if line.isEmpty || prefixes.contains(where: { line.hasPrefix($0) }) {
                index += 1
                continue
            }

            break
        }

        guard index < lines.count else {
            return ""
        }

        return lines[index...].joined(separator: "\n")
    }
}

private struct EscapedToken {
    let placeholder: String
    let original: String
}

private func replacingMatches(
    in source: String,
    pattern: String,
    replacement: (NSTextCheckingResult, String) -> String?
) -> String {
    guard let expression = try? NSRegularExpression(pattern: pattern) else {
        return source
    }

    let nsRange = NSRange(source.startIndex..<source.endIndex, in: source)
    let matches = expression.matches(in: source, range: nsRange)
    var result = source

    for match in matches.reversed() {
        guard let range = Range(match.range, in: source),
              let replacement = replacement(match, source) else {
            continue
        }

        result.replaceSubrange(range, with: replacement)
    }

    return result
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
