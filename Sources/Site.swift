import Foundation
import Raptor

@main
struct RaptorWebsite {
    static func main() async {
        var site = ExampleSite()

        do {
            try await site.publish()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct ExampleSite: Site {    
    static let homePageSize = 2

    var name = "Raptor Tsubame"
    var titleSuffix = " – Raptor Tsubame"
    var url = URL(static: "https://raptor-tsubame.example.com")
    var author = "Tsubame"

    var homePage = HomePage(pageNumber: 1, totalPages: 1)
    var layout = MainLayout()
    var postPages = [ArticlePage()]
    var generatedPages: [HomePage] = []

    var pages: [any Page] {
        generatedPages + [ArchivePage(), AboutPage()]
    }

    mutating func prepare() async throws {
        let rootDirectory = URL(filePath: FileManager.default.currentDirectoryPath)
        let descriptors = try SiteContentLoader().load(from: rootDirectory)
        let totalPages = PostQueries.pageCount(
            forPublishedPostsIn: descriptors,
            pageSize: Self.homePageSize
        )

        homePage = HomePage(pageNumber: 1, totalPages: totalPages)
        generatedPages = (2...totalPages).map { HomePage(pageNumber: $0, totalPages: totalPages) }
    }
}

struct HomePage: Page {
    let pageNumber: Int
    let totalPages: Int

    var title: String { "Home" }

    var path: String {
        pageNumber == 1 ? "/" : "/\(pageNumber)"
    }

    var body: some HTML {
        Text("Home")
    }
}

struct ArchivePage: Page {
    var title: String { "Archive" }
    var path: String { "/archive" }

    var body: some HTML {
        Text("Archive")
    }
}

struct AboutPage: Page {
    var title: String { "About" }
    var path: String { "/about" }

    var body: some HTML {
        Text("About")
    }
}

struct ArticlePage: PostPage {
    var body: some HTML {
        Text(post.title)
    }
}
