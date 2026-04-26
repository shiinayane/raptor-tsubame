import Foundation
import Raptor

struct PageFooter: HTML {
    let siteName: String
    let year: Int

    init(siteName: String, year: Int) {
        self.siteName = siteName
        self.year = year
    }

    var body: some HTML {
        Tag("div") {
            Text("Copyright \(year) \(siteName). All Rights Reserved.")
                .style(ChromeMutedTextStyle())
                .data("footer-copyright", "true")

            Tag("div") {
                footerLink("RSS", destination: "/feed.rss", marker: "rss", label: "RSS feed")
                footerLink("Sitemap", destination: "/sitemap.xml", marker: "sitemap", label: "Sitemap")
                footerLink("Raptor", destination: "https://raptor.build", marker: "raptor", label: "Raptor static site generator")
            }
            .style(PageFooterLinksStyle())
        }
        .style(PageFooterStyle())
        .data("site-footer", "true")
    }

    private func footerLink(
        _ text: String,
        destination: String,
        marker: String,
        label: String
    ) -> some InlineContent {
        Link(text, destination: destination)
            .style(PageFooterLinkStyle())
            .attribute("aria-label", label)
            .data("footer-link", marker)
    }
}
