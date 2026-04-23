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

    static func category(for post: Post) -> TaxonomyTerm? {
        guard contentKind(for: post) == .post,
              post.isPublished,
              let rawValue = post.metadata.stringValue(for: SiteContentMetadataKey.category.rawValue)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !rawValue.isEmpty else {
            return nil
        }

        return TaxonomyTerm(kind: .category, name: rawValue)
    }

    static func tags(for post: Post) -> [TaxonomyTerm] {
        guard contentKind(for: post) == .post, post.isPublished else {
            return []
        }

        let rawValue = post.metadata.stringValue(for: SiteContentMetadataKey.tags.rawValue) ?? ""
        var seenTermIDs = Set<String>()
        var terms = [TaxonomyTerm]()

        for tag in rawValue.split(separator: ",") {
            let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                continue
            }

            let term = TaxonomyTerm(kind: .tag, name: trimmed)
            if seenTermIDs.insert(term.id).inserted {
                terms.append(term)
            }
        }

        return terms
    }

    static func tagGroups<S: Sequence>(_ posts: S) -> [(term: TaxonomyTerm, posts: [Post])] where S.Element == Post {
        let published = publishedPosts(posts)
        let grouped = Dictionary(
            grouping: published.flatMap { post in
                tags(for: post).map { ($0, post) }
            },
            by: \.0
        )

        return grouped
            .map { entry in
                (
                    term: entry.key,
                    posts: entry.value.map(\.1).sorted(by: \.date, order: .reverse)
                )
            }
            .sorted { $0.term.name.localizedCaseInsensitiveCompare($1.term.name) == .orderedAscending }
    }

    static func categoryGroups<S: Sequence>(_ posts: S) -> [(term: TaxonomyTerm, posts: [Post])] where S.Element == Post {
        let published = publishedPosts(posts)
        let grouped = Dictionary(
            grouping: published.compactMap { post in
                category(for: post).map { ($0, post) }
            },
            by: \.0
        )

        return grouped
            .map { entry in
                (
                    term: entry.key,
                    posts: entry.value.map(\.1).sorted(by: \.date, order: .reverse)
                )
            }
            .sorted { $0.term.name.localizedCaseInsensitiveCompare($1.term.name) == .orderedAscending }
    }

    static func posts<S: Sequence>(tagged slug: String, in posts: S) -> [Post] where S.Element == Post {
        tagGroups(posts)
            .first { $0.term.slug == slug }?
            .posts ?? []
    }

    static func posts<S: Sequence>(inCategory slug: String, posts: S) -> [Post] where S.Element == Post {
        categoryGroups(posts)
            .first { $0.term.slug == slug }?
            .posts ?? []
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
