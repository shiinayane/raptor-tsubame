import Foundation
import Raptor

struct AboutPage: Page {
    @Environment(\.posts) private var posts

    var title: String { "About" }
    var path: String { SiteRoutes.about }

    private var aboutPost: Post? {
        PostQueries.standalonePage(at: SiteRoutes.about, in: posts)
    }

    var body: some HTML {
        if let aboutPost {
            MarkdownContent(post: aboutPost)
        } else {
            Text("About")
        }
    }
}

