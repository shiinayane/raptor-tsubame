import Foundation
import Raptor

struct ArchiveYearGroup: HTML {
    let year: Int
    let posts: [Post]

    var body: some HTML {
        Section {
            HStack(alignment: .center, spacing: 12) {
                Tag("h2") { "\(year)" }
                    .style(ArchiveYearTitleStyle())
                Text("\(posts.count) posts")
                    .style(ArchiveYearCountStyle())
            }

            VStack(alignment: .leading, spacing: 14) {
                ForEach(posts) { post in
                    ArchiveEntry(post: post)
                }
            }
        }
        .style(ArchiveYearGroupStyle())
        .data("archive-year-group", "true")
    }
}
