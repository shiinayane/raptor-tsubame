import Foundation
import Raptor

struct ArchiveList: HTML {
    struct Group {
        let year: Int
        let posts: [Post]
    }

    let groups: [Group]

    var body: some HTML {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(groups) { group in
                Section {
                    Tag("h2") { "\(group.year)" }
                    PostList(posts: group.posts)
                }
            }
        }
    }
}

