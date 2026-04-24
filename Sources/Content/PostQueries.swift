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
            metadata(for: $0).kind == .page &&
            $0.isPublished &&
            normalized(metadata(for: $0).path ?? $0.path) == normalizedPath
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
        let metadata = metadata(for: post)

        guard metadata.kind == .post,
              post.isPublished,
              let rawValue = metadata.category else {
            return nil
        }

        return TaxonomyTerm(kind: .category, name: rawValue)
    }

    static func tags(for post: Post) -> [TaxonomyTerm] {
        let metadata = metadata(for: post)

        guard metadata.kind == .post, post.isPublished else {
            return []
        }

        var seenTermIDs = Set<String>()
        var terms = [TaxonomyTerm]()

        for tag in metadata.tags {
            let term = TaxonomyTerm(kind: .tag, name: tag)
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

    static func adjacentPosts<S: Sequence>(
        to post: Post,
        in posts: S
    ) -> (newer: Post?, older: Post?) where S.Element == Post {
        let published = publishedPosts(posts)
        guard let index = published.firstIndex(where: { normalized($0.path) == normalized(post.path) }) else {
            return (nil, nil)
        }

        let newer = index > published.startIndex ? published[published.index(before: index)] : nil
        let older = published.index(after: index) < published.endIndex ? published[published.index(after: index)] : nil
        return (newer, older)
    }

    private static func normalized(_ path: String) -> String {
        let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed.isEmpty ? "/" : "/\(trimmed)/"
    }

    private static func contentKind(for post: Post) -> SiteContentKind {
        metadata(for: post).kind
    }

    private static func metadata(for post: Post) -> SiteContentMetadata {
        SiteContentMetadata(post.metadata)
    }
}

extension PostQueries {
    static func sidebarCategories<S: Sequence>(_ posts: S) -> [TaxonomyCountItem] where S.Element == Post {
        categoryGroups(posts).map { group in
            TaxonomyCountItem(term: group.term, count: group.posts.count)
        }
    }

    static func sidebarTags<S: Sequence>(_ posts: S) -> [TaxonomyCountItem] where S.Element == Post {
        tagGroups(posts).map { group in
            TaxonomyCountItem(term: group.term, count: group.posts.count)
        }
    }
}
