import Foundation
import Raptor

struct HomePage: Page {
    @Environment(\.posts) private var posts

    let pageNumber: Int
    let totalPages: Int

    var title: String { "Home" }

    var path: String {
        SiteRoutes.homePage(pageNumber)
    }

    private var pagePosts: [Post] {
        let published = PostQueries.publishedPosts(posts)
        let pages = PostQueries.paginate(published, pageSize: ExampleSite.homePageSize)

        let index = max(1, pageNumber) - 1
        guard index < pages.count else { return [] }
        return pages[index]
    }

    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            PostList(posts: pagePosts)
            PaginationControls(currentPage: pageNumber, totalPages: totalPages)
        }
    }
}

