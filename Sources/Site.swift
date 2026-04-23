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

    let rootDirectory: URL

    var name = "Raptor Tsubame"
    var titleSuffix = " – Raptor Tsubame"
    var url = URL(static: "https://raptor-tsubame.example.com")
    var author = "Tsubame"

    var homePage = HomePage(pageNumber: 1, totalPages: 1)
    var layout = MainLayout()
    var postPages: [any PostPage] = [ArticlePage(), MarkdownPage()]
    var generatedPages: [HomePage] = []

    init(rootDirectory: URL = sitePackageRoot()) {
        self.rootDirectory = rootDirectory
    }

    var pages: [any Page] {
        generatedPages + [ArchivePage()]
    }

    mutating func prepare() async throws {
        let contentLoader = SiteContentLoader()
        let descriptors = try contentLoader.load(from: rootDirectory)
        let publishedPostCount = contentLoader.publishedPostCount(in: descriptors)
        let totalPages = max(1, Int(ceil(Double(publishedPostCount) / Double(Self.homePageSize))))

        homePage = HomePage(pageNumber: 1, totalPages: totalPages)
        generatedPages = totalPages > 1
            ? (2...totalPages).map { HomePage(pageNumber: $0, totalPages: totalPages) }
            : []
    }
}

struct MarkdownPage: PostPage {
    var body: some HTML {
        MarkdownContent(post: post)
    }
}

private func sitePackageRoot(from file: StaticString = #filePath) -> URL {
    var directory = URL(filePath: "\(file)").deletingLastPathComponent()

    while directory.path != "/" {
        if FileManager.default.fileExists(atPath: directory.appending(path: "Package.swift").path) {
            return directory
        }
        directory.deleteLastPathComponent()
    }

    fatalError("Unable to locate package root.")
}
