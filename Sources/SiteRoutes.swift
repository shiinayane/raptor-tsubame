import Foundation

enum SiteRoutes {
    static let home = "/"
    static let archive = "/archive/"
    static let about = "/about/"

    static func homePage(_ pageNumber: Int) -> String {
        pageNumber <= 1 ? home : "/\(pageNumber)/"
    }
}

