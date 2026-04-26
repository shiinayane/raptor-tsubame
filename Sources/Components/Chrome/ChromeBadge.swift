import Foundation
import Raptor

struct ChromeBadge: HTML {
    let text: String

    var body: some HTML {
        Text(text)
            .style(ChromeBadgeStyle())
            .data("chrome-badge", "true")
    }
}
