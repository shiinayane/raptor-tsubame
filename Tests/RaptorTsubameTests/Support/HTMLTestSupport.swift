import Foundation
import Testing

func mainSlice(of html: String) throws -> String {
    let mainOpen = try #require(html.range(of: "<main"))
    let mainClose = try #require(html.range(of: "</main>"))
    return String(html[mainOpen.lowerBound..<mainClose.upperBound])
}

func expectSidebarMarkerOwnership(in main: String) throws {
    let siteShellTag = try openingTag(containingClass: "site-shell", in: main)
    let sidebarContainerTag = try sidebarContainerOpeningTag(in: main)

    #expect(siteShellTag.contains("data-sidebar-shell=\"true\""))
    #expect(sidebarContainerTag.contains("data-sidebar-container=\"true\""))
    #expect(!sidebarContainerTag.contains("data-sidebar-shell=\"true\""))
}

func sidebarContainerOpeningTag(in html: String) throws -> String {
    if let containerRange = html.range(of: "data-sidebar-container=\"true\"") {
        return try openingTag(containing: containerRange.lowerBound, in: html)
    }

    return try openingTag(startingWith: "<aside", in: html)
}

func openingTag(containing needle: String, in html: String) throws -> String {
    let needleRange = try #require(html.range(of: needle))
    return try openingTag(containing: needleRange.lowerBound, in: html)
}

func openingTag(containingClass className: String, in html: String) throws -> String {
    var searchStart = html.startIndex

    while let classRange = html.range(of: className, range: searchStart..<html.endIndex) {
        let tag = try openingTag(containing: classRange.lowerBound, in: html)

        if openingTag(tag, containsClass: className) {
            return tag
        }

        searchStart = classRange.upperBound
    }

    let missingTag: String? = nil
    return try #require(missingTag)
}

func openingTag(_ tag: String, containsClass className: String) -> Bool {
    guard let attributeStart = tag.range(of: "class=\"") else { return false }
    let classStart = attributeStart.upperBound
    guard let classEnd = tag[classStart...].firstIndex(of: "\"") else { return false }
    let classes = tag[classStart..<classEnd].split(separator: " ")

    return classes.contains { candidate in
        candidate == Substring(className) || candidate.hasPrefix("\(className)-")
    }
}

func openingTag(containing index: String.Index, in html: String) throws -> String {
    let beforeNeedle = html[..<index]
    let afterNeedle = html[index...]
    let open = try #require(beforeNeedle.lastIndex(of: "<"))
    let close = try #require(afterNeedle.firstIndex(of: ">"))
    return String(html[open...close])
}

func openingTag(startingWith prefix: String, in html: String) throws -> String {
    let open = try #require(html.range(of: prefix))
    let afterOpen = html[open.lowerBound...]
    let close = try #require(afterOpen.firstIndex(of: ">"))
    return String(html[open.lowerBound...close])
}

func occurrenceCount(of needle: String, in haystack: String) -> Int {
    guard !needle.isEmpty else { return 0 }
    return haystack.components(separatedBy: needle).count - 1
}
