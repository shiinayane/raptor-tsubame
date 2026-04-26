import Foundation
import Raptor

struct ChromeIconBox: HTML {
    let label: String

    var body: some HTML {
        Text(label)
            .style(ChromeIconBoxStyle())
            .attribute("aria-hidden", "true")
            .data("chrome-icon-box", "true")
    }
}
