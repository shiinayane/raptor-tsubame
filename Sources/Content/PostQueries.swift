import Foundation

enum PostQueries {
    static func publishedPosts(in content: [SiteContentDescriptor]) -> [SiteContentDescriptor] {
        content
            .filter { $0.kind == .post && $0.isPublished }
            .sorted {
                switch ($0.date, $1.date) {
                case let (lhs?, rhs?):
                    if lhs != rhs {
                        return lhs > rhs
                    }
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    break
                }

                return $0.sourceURL.lastPathComponent < $1.sourceURL.lastPathComponent
            }
    }

    static func pageCount(
        forPublishedPostsIn content: [SiteContentDescriptor],
        pageSize: Int
    ) -> Int {
        precondition(pageSize > 0, "Page size must be greater than zero.")

        let count = publishedPosts(in: content).count
        return max(1, Int(ceil(Double(count) / Double(pageSize))))
    }
}
