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
        let matches = headingMatches(in: html)
        var slugger = ArticleHeadingSlugger()
        var items = [ArticleOutlineItem]()
        var transformed = ""
        var cursor = html.startIndex

        for match in matches {
            transformed += html[cursor..<match.fullRange.lowerBound]

            let attributes = String(html[match.attributeRange])
            let content = String(html[match.contentRange])
            let title = plainText(from: content)
            let id = attributeValue(named: "id", in: attributes) ?? slugger.slug(for: title)
            let rewrittenAttributes = headingAttributes(from: attributes, id: id)

            transformed += "<h\(match.level.rawValue)\(rewrittenAttributes)>\(content)</h\(match.level.rawValue)>"
            cursor = match.fullRange.upperBound
            items.append(ArticleOutlineItem(id: id, title: title, level: match.level))
        }

        transformed += html[cursor...]
        return (transformed, items)
    }
}

private struct HeadingMatch {
    let level: ArticleHeadingLevel
    let fullRange: Range<String.Index>
    let attributeRange: Range<String.Index>
    let contentRange: Range<String.Index>
}

private func headingMatches(in html: String) -> [HeadingMatch] {
    var matches = [HeadingMatch]()
    var cursor = html.startIndex

    while let tagStart = html[cursor...].firstIndex(of: "<") {
        guard
            let start = headingStart(at: tagStart, in: html),
            let tagEnd = headingStartTagEnd(from: start.attributeStart, in: html)
        else {
            cursor = html.index(after: tagStart)
            continue
        }

        let contentStart = html.index(after: tagEnd)
        guard
            let closingRange = html.range(
                of: "</h\(start.level.rawValue)>",
                options: [.caseInsensitive],
                range: contentStart..<html.endIndex
            )
        else {
            cursor = html.index(after: tagStart)
            continue
        }

        matches.append(
            HeadingMatch(
                level: start.level,
                fullRange: tagStart..<closingRange.upperBound,
                attributeRange: start.attributeStart..<tagEnd,
                contentRange: contentStart..<closingRange.lowerBound
            )
        )
        cursor = closingRange.upperBound
    }

    return matches
}

private func headingStart(
    at tagStart: String.Index,
    in html: String
) -> (level: ArticleHeadingLevel, attributeStart: String.Index)? {
    guard html[tagStart] == "<" else {
        return nil
    }

    let hIndex = html.index(after: tagStart)
    guard hIndex < html.endIndex, html[hIndex].lowercased() == "h" else {
        return nil
    }

    let levelIndex = html.index(after: hIndex)
    guard
        levelIndex < html.endIndex,
        let levelValue = Int(String(html[levelIndex])),
        let level = ArticleHeadingLevel(rawValue: levelValue)
    else {
        return nil
    }

    let attributeStart = html.index(after: levelIndex)
    guard attributeStart < html.endIndex else {
        return nil
    }

    let delimiter = html[attributeStart]
    guard delimiter == ">" || delimiter.isWhitespace else {
        return nil
    }

    return (level, attributeStart)
}

private func headingStartTagEnd(from start: String.Index, in html: String) -> String.Index? {
    var cursor = start
    var quotedBy: Character?

    while cursor < html.endIndex {
        let character = html[cursor]

        if let quote = quotedBy {
            if character == quote {
                quotedBy = nil
            }
        } else if character == "\"" || character == "'" {
            quotedBy = character
        } else if character == ">" {
            return cursor
        }

        cursor = html.index(after: cursor)
    }

    return nil
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
    let pattern = #"(?:^|\s)"# + escapedName + #"(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'=<>`]+)))?(?=\s|$)"#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
        return nil
    }

    let nsRange = NSRange(attributes.startIndex..<attributes.endIndex, in: attributes)
    guard let match = regex.firstMatch(in: attributes, range: nsRange) else {
        return nil
    }

    for rangeIndex in 1..<match.numberOfRanges {
        let nsRange = match.range(at: rangeIndex)
        guard nsRange.location != NSNotFound, let valueRange = Range(nsRange, in: attributes) else {
            continue
        }

        return String(attributes[valueRange])
    }

    if match.range(at: 0).location != NSNotFound {
        return ""
    }

    return nil
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
        .replacingOccurrences(of: "&quot;", with: "\"")
        .replacingOccurrences(of: "&#39;", with: "'")
}
