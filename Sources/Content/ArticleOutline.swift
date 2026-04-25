import Foundation

struct ArticleOutline: Sendable, Equatable {
    let items: [ArticleOutlineItem]

    var isEmpty: Bool {
        items.isEmpty
    }

    var shouldRender: Bool {
        items.count >= 2
    }
}

struct ArticleOutlineItem: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let level: ArticleHeadingLevel
}

enum ArticleHeadingLevel: Int, Sendable, Equatable {
    case h2 = 2
    case h3 = 3
}

struct ArticleHeadingSlugger {
    private var countsByBase = [String: Int]()
    private var fallbackCount = 0

    mutating func slug(for title: String) -> String {
        let base = normalizedBase(for: title)
        let resolvedBase: String

        if base.isEmpty {
            fallbackCount += 1
            resolvedBase = "section-\(fallbackCount)"
        } else {
            resolvedBase = base
        }

        let count = (countsByBase[resolvedBase] ?? 0) + 1
        countsByBase[resolvedBase] = count

        return count == 1 ? resolvedBase : "\(resolvedBase)-\(count)"
    }

    private func normalizedBase(for title: String) -> String {
        var result = ""
        var lastWasHyphen = false

        for scalar in title.lowercased().unicodeScalars {
            if CharacterSet.alphanumerics.contains(scalar), scalar.isASCII {
                result.unicodeScalars.append(scalar)
                lastWasHyphen = false
            } else if !lastWasHyphen {
                result.append("-")
                lastWasHyphen = true
            }
        }

        return result.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
