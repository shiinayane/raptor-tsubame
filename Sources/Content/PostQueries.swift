import Foundation
import Raptor

enum PostQueries {
    static func publishedPosts<S: Sequence>(_ posts: S) -> [Post] where S.Element == Post {
        posts
            .filter { contentKind(for: $0) == .post }
            .filter(\.isPublished)
            .sorted(by: \.date, order: .reverse)
    }

    static func standalonePage<S: Sequence>(at path: String, in posts: S) -> Post? where S.Element == Post {
        let normalizedPath = normalized(path)

        return posts.first {
            contentKind(for: $0) == .page &&
            $0.isPublished &&
            normalized($0.metadata.stringValue(for: SiteContentMetadataKey.path.rawValue) ?? $0.path) == normalizedPath
        }
    }

    static func archiveGroups<S: Sequence>(_ posts: S) -> [(year: Int, posts: [Post])] where S.Element == Post {
        let groupedPosts = Dictionary(grouping: publishedPosts(posts)) {
            Calendar(identifier: .gregorian).component(.year, from: $0.date)
        }

        return groupedPosts
            .map { (year: $0.key, posts: $0.value.sorted(by: \.date, order: .reverse)) }
            .sorted { $0.year > $1.year }
    }

    static func paginate(_ posts: [Post], pageSize: Int) -> [[Post]] {
        precondition(pageSize > 0, "Page size must be greater than zero.")

        guard !posts.isEmpty else {
            return []
        }

        return stride(from: 0, to: posts.count, by: pageSize).map { index in
            Array(posts[index..<min(index + pageSize, posts.count)])
        }
    }

    private static func normalized(_ path: String) -> String {
        let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed.isEmpty ? "/" : "/\(trimmed)/"
    }

    private static func contentKind(for post: Post) -> SiteContentKind {
        let rawValue = post.metadata.stringValue(for: SiteContentMetadataKey.kind.rawValue)
        return SiteContentKind(rawValue: rawValue ?? "") ?? .post
    }
}
