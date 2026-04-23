import Foundation
import Raptor

struct PaginationControls: HTML {
    let currentPage: Int
    let totalPages: Int

    var body: some HTML {
        if totalPages <= 1 {
            EmptyHTML()
        } else {
            HStack(spacing: 12) {
                if let newerPath {
                    Link("Newer", destination: newerPath)
                }

                Spacer()
                Text { "Page \(currentPage) of \(totalPages)" }
                Spacer()

                if let olderPath {
                    Link("Older", destination: olderPath)
                }
            }
        }
    }

    private var newerPath: String? {
        guard currentPage > 1 else { return nil }
        return currentPage == 2 ? "/" : "/\(currentPage - 1)"
    }

    private var olderPath: String? {
        guard currentPage < totalPages else { return nil }
        return "/\(currentPage + 1)"
    }
}
