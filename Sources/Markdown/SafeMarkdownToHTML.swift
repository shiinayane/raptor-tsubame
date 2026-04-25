import Raptor

struct SafeMarkdownToHTML: PostProcessor {
    var removeTitleFromBody: Bool { processor.removeTitleFromBody }
    var syntaxHighlighterLanguages: Set<SyntaxHighlighterLanguage> {
        processor.syntaxHighlighterLanguages
    }

    private var processor = MarkdownToHTML()

    mutating func process(_ markup: String) throws -> ProcessedPost {
        processor.process(escapeMarkdownCode(in: markup))
    }

    func delimitRawMarkup(_ widgetHTML: String) -> String {
        processor.delimitRawMarkup(widgetHTML)
    }
}

private func escapeMarkdownCode(in markup: String) -> String {
    var result = ""
    var index = markup.startIndex
    var openFence: MarkdownFence?

    while index < markup.endIndex {
        let lineEnd = markup[index...].firstIndex(of: "\n") ?? markup.endIndex
        let line = String(markup[index..<lineEnd])
        let newline = lineEnd < markup.endIndex ? "\n" : ""

        if let fence = openFence {
            if closesFence(line, fence: fence) {
                result += line + newline
                openFence = nil
            } else {
                result += escapeHTMLText(line) + newline
            }
        } else if let fence = openingFence(in: line) {
            result += line + newline
            openFence = fence
        } else {
            result += escapeInlineCode(in: line) + newline
        }

        index = lineEnd < markup.endIndex ? markup.index(after: lineEnd) : lineEnd
    }

    return result
}

private struct MarkdownFence {
    let character: Character
    let count: Int
}

private func openingFence(in line: String) -> MarkdownFence? {
    let trimmed = line.dropFirst(min(indentationCount(in: line), 3))
    guard let first = trimmed.first, first == "`" || first == "~" else {
        return nil
    }

    let count = trimmed.prefix { $0 == first }.count
    guard count >= 3 else { return nil }

    return MarkdownFence(character: first, count: count)
}

private func closesFence(_ line: String, fence: MarkdownFence) -> Bool {
    let trimmed = line.dropFirst(min(indentationCount(in: line), 3))
    let count = trimmed.prefix { $0 == fence.character }.count
    return count >= fence.count
}

private func indentationCount(in line: String) -> Int {
    line.prefix { $0 == " " }.count
}

private func escapeInlineCode(in line: String) -> String {
    var result = ""
    var index = line.startIndex

    while let delimiterRange = nextBacktickRun(in: line, startingAt: index) {
        result += line[index..<delimiterRange.lowerBound]

        let delimiter = String(line[delimiterRange])
        let contentStart = delimiterRange.upperBound

        guard let closingRange = line.range(
            of: delimiter,
            range: contentStart..<line.endIndex
        ) else {
            result += line[delimiterRange.lowerBound...]
            return result
        }

        result += delimiter
        result += escapeHTMLText(String(line[contentStart..<closingRange.lowerBound]))
        result += delimiter
        index = closingRange.upperBound
    }

    result += line[index...]
    return result
}

private func nextBacktickRun(
    in line: String,
    startingAt start: String.Index
) -> Range<String.Index>? {
    guard let first = line[start...].firstIndex(of: "`") else {
        return nil
    }

    var end = first
    while end < line.endIndex, line[end] == "`" {
        end = line.index(after: end)
    }

    return first..<end
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
