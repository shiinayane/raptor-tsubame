import Foundation
import Raptor

struct PaginationControls: HTML {
    struct Model {
        let currentPage: Int
        let totalPages: Int
        let pathForPage: (Int) -> String

        var newerPath: String? {
            guard currentPage > 1 else { return nil }
            return pathForPage(currentPage - 1)
        }

        var olderPath: String? {
            guard currentPage < totalPages else { return nil }
            return pathForPage(currentPage + 1)
        }

        var pageLabel: String {
            "Page \(currentPage) of \(totalPages)"
        }
    }

    let model: Model

    init(
        currentPage: Int,
        totalPages: Int,
        pathForPage: @escaping (Int) -> String = SiteRoutes.homePage
    ) {
        self.model = Model(
            currentPage: currentPage,
            totalPages: totalPages,
            pathForPage: pathForPage
        )
    }

    var body: some HTML {
        if model.totalPages <= 1 {
            EmptyHTML()
        } else {
            HStack(spacing: 12) {
                if let newerPath = model.newerPath {
                    ChromeButtonLink(
                        "Newer",
                        destination: newerPath,
                        markerName: "pagination-link",
                        markerValue: "newer"
                    )
                }

                Spacer()
                Text { model.pageLabel }
                    .style(ChromeMutedTextStyle())
                    .data("pagination-page", "true")
                Spacer()

                if let olderPath = model.olderPath {
                    ChromeButtonLink(
                        "Older",
                        destination: olderPath,
                        markerName: "pagination-link",
                        markerValue: "older"
                    )
                }
            }
            .data("pagination", "true")
        }
    }
}
