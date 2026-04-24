import Foundation

enum SiteRoutes {
    static let home = "/"
    static let archive = "/archive/"
    static let about = "/about/"
    static let tags = "/tags/"
    static let categories = "/categories/"

    static func homePage(_ pageNumber: Int) -> String {
        pageNumber <= 1 ? home : "/\(pageNumber)/"
    }

    static func tag(_ slug: String) -> String {
        "/tags/\(slug)/"
    }

    static func category(_ slug: String) -> String {
        "/categories/\(slug)/"
    }
}
