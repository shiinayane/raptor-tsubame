import Foundation
import Raptor

struct ArchivePage: Page {
    @Environment(\.posts) private var posts

    var title: String { "Archive" }
    var path: String { SiteRoutes.archive }

    private var groups: [ArchiveList.Group] {
        PostQueries.archiveGroups(posts).map { group in
            ArchiveList.Group(year: group.year, posts: group.posts)
        }
    }

    var body: some HTML {
        ArchiveList(groups: groups)
    }
}

