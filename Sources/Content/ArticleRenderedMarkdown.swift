import Foundation

struct ArticleRenderedMarkdown: Sendable, Equatable {
    let html: String
    let outline: ArticleOutline

    init(html: String) {
        let result = Self.transform(html)
        self.html = result.html
        self.outline = ArticleOutline(items: result.items)
    }

    private static func transform(_ html: String) -> (html: String, items: [ArticleOutlineItem]) {
        let pattern = #"<h([23])([^>]*)>(.*?)</h\1>"#
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        ) else {
            return (html, [])
        }

        let nsRange = NSRange(html.startIndex..<html.endIndex, in: html)
        let matches = regex.matches(in: html, range: nsRange)

        var slugger = ArticleHeadingSlugger()
        var items = [ArticleOutlineItem]()
        var transformed = ""
        var cursor = html.startIndex

        for match in matches {
            guard
                let fullRange = Range(match.range(at: 0), in: html),
                let levelRange = Range(match.range(at: 1), in: html),
                let attributeRange = Range(match.range(at: 2), in: html),
                let contentRange = Range(match.range(at: 3), in: html),
                let levelValue = Int(html[levelRange]),
                let level = ArticleHeadingLevel(rawValue: levelValue)
            else {
                continue
            }

            transformed += html[cursor..<fullRange.lowerBound]

            let attributes = String(html[attributeRange])
            let content = String(html[contentRange])
            let title = plainText(from: content)
            let id = attributeValue(named: "id", in: attributes) ?? slugger.slug(for: title)
            let rewrittenAttributes = headingAttributes(from: attributes, id: id)

            transformed += "<h\(level.rawValue)\(rewrittenAttributes)>\(content)</h\(level.rawValue)>"
            cursor = fullRange.upperBound
            items.append(ArticleOutlineItem(id: id, title: title, level: level))
        }

        transformed += html[cursor...]
        return (transformed, items)
    }
}

private func headingAttributes(from attributes: String, id: String) -> String {
    var attributes = attributes

    if attributeValue(named: "id", in: attributes) == nil {
        attributes += #" id="\#(id)""#
    }

    if attributeValue(named: "data-article-heading-anchor", in: attributes) == nil {
        attributes += #" data-article-heading-anchor="true""#
    }

    return attributes
}

private func attributeValue(named name: String, in attributes: String) -> String? {
    let escapedName = NSRegularExpression.escapedPattern(for: name)
    let pattern = #"(?:^|\s)"# + escapedName + #"\s*=\s*"([^"]*)""#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
        return nil
    }

    let nsRange = NSRange(attributes.startIndex..<attributes.endIndex, in: attributes)
    guard
        let match = regex.firstMatch(in: attributes, range: nsRange),
        let valueRange = Range(match.range(at: 1), in: attributes)
    else {
        return nil
    }

    return String(attributes[valueRange])
}

private func plainText(from html: String) -> String {
    let withoutTags = html.replacingOccurrences(
        of: #"<[^>]+>"#,
        with: "",
        options: .regularExpression
    )

    return decodeHTMLEntities(in: withoutTags)
        .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

private func decodeHTMLEntities(in text: String) -> String {
    text
        .replacingOccurrences(of: "&amp;", with: "&")
        .replacingOccurrences(of: "&lt;", with: "<")
        .replacingOccurrences(of: "&gt;", with: ">")
        .replacingOccurrences(of: "&quot;", with: "\"")
        .replacingOccurrences(of: "&#39;", with: "'")
}
