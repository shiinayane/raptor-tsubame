import Foundation
import Raptor

struct ChromeSurface<Content: HTML>: HTML {
    let marker: String?
    let content: () -> Content

    init(marker: String? = nil, @HTMLBuilder content: @escaping () -> Content) {
        self.marker = marker
        self.content = content
    }

    var body: some HTML {
        if let marker {
            Tag("div") { content() }
                .style(ChromeSurfaceStyle())
                .data(marker, "true")
        } else {
            Tag("div") { content() }
                .style(ChromeSurfaceStyle())
        }
    }
}
