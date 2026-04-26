import Foundation
import Raptor

struct ChromeSectionTitle: HTML {
    let text: String

    var body: some HTML {
        Text(text)
            .style(ChromeSectionTitleStyle())
            .data("chrome-section-title", text.lowercased())
    }
}
