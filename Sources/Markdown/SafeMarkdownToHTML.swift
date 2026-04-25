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
        guard isCodeTagBoundary(in: remainder, after: openRange.upperBound) else {
            result += remainder[..<openRange.upperBound]
            remainder = remainder[openRange.upperBound...]
            continue
        }

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
    var escaped = ""
    var index = text.startIndex

    while index < text.endIndex {
        switch text[index] {
        case "&":
            if let entityEnd = validHTMLEntityEnd(in: text, startingAt: index) {
                escaped += text[index...entityEnd]
                index = text.index(after: entityEnd)
            } else {
                escaped += "&amp;"
                index = text.index(after: index)
            }
        case "<":
            escaped += "&lt;"
            index = text.index(after: index)
        case ">":
            escaped += "&gt;"
            index = text.index(after: index)
        default:
            escaped.append(text[index])
            index = text.index(after: index)
        }
    }

    return escaped
}

private func isCodeTagBoundary(in html: Substring, after index: Substring.Index) -> Bool {
    guard index < html.endIndex else { return false }

    let character = html[index]
    return character == ">" || character == "/" || character.isWhitespace
}

private func validHTMLEntityEnd(in text: String, startingAt ampersand: String.Index) -> String.Index? {
    let entityStart = text.index(after: ampersand)
    guard entityStart < text.endIndex else { return nil }

    let maxEntityLength = 32
    var cursor = entityStart
    var length = 0

    while cursor < text.endIndex, length <= maxEntityLength {
        if text[cursor] == ";" {
            let body = text[entityStart..<cursor]
            return isValidHTMLEntityBody(body) ? cursor : nil
        }

        cursor = text.index(after: cursor)
        length += 1
    }

    return nil
}

private func isValidHTMLEntityBody(_ body: Substring) -> Bool {
    guard let first = body.first else { return false }

    if first == "#" {
        let numeric = body.dropFirst()
        guard let marker = numeric.first else { return false }

        if marker == "x" || marker == "X" {
            let hexDigits = numeric.dropFirst()
            return !hexDigits.isEmpty && hexDigits.allSatisfy(\.isHexDigit)
        }

        return numeric.allSatisfy(\.isNumber)
    }

    return first.isLetter && body.allSatisfy { $0.isLetter || $0.isNumber }
}
