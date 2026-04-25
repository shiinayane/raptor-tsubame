import Raptor

struct SafeMarkdownToHTML: PostProcessor {
    var removeTitleFromBody: Bool { processor.removeTitleFromBody }
    var syntaxHighlighterLanguages: Set<SyntaxHighlighterLanguage> {
        processor.syntaxHighlighterLanguages
    }

    private var processor = MarkdownToHTML()

    mutating func process(_ markup: String) throws -> ProcessedPost {
        var processed = processor.process(markup)
        processed.body = escapeCodeElementBodies(in: processed.body)
        return processed
    }

    func delimitRawMarkup(_ widgetHTML: String) -> String {
        processor.delimitRawMarkup(widgetHTML)
    }
}

private func escapeCodeElementBodies(in html: String) -> String {
    var result = ""
    var remainder = html[...]

    while let openRange = remainder.range(of: "<code") {
        result += remainder[..<openRange.lowerBound]

        guard let openEnd = remainder[openRange.upperBound...].firstIndex(of: ">"),
              let closeRange = remainder[openEnd...].range(of: "</code>")
        else {
            result += remainder[openRange.lowerBound...]
            return result
        }

        let openingTag = remainder[openRange.lowerBound...openEnd]
        let codeBody = remainder[remainder.index(after: openEnd)..<closeRange.lowerBound]

        result += openingTag
        result += escapeHTMLText(String(codeBody))
        result += "</code>"
        remainder = remainder[closeRange.upperBound...]
    }

    result += remainder
    return result
}

private func escapeHTMLText(_ text: String) -> String {
    guard text.contains("<") || text.contains(">") || text.contains("\"") || text.contains("'") else {
        return text
    }

    return text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&#39;")
}
