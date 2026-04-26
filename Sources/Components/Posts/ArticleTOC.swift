import Foundation
import Raptor

struct ArticleTOC: HTML {
    let outline: ArticleOutline

    var body: some HTML {
        if outline.shouldRender {
            Tag("nav") {
                Text("Contents")
                    .font(.title5)
                    .style(ArticleTocTitleStyle())
                    .data("article-toc-title", "true")

                Tag("ol") {
                    ForEach(outline.items) { item in
                        Tag("li") {
                            Link(destination: "#\(item.id)") {
                                escapedHTML(item.title)
                            }
                            .style(ArticleTocLinkStyle(level: item.level))
                            .data("article-toc-link", "true")
                        }
                        .style(ArticleTocItemStyle(level: item.level))
                        .data("article-toc-item", "true")
                        .data("article-toc-level", "h\(item.level.rawValue)")
                    }
                }
                .style(ArticleTocListStyle())
                .data("article-toc-list", "true")
            }
            .style(ArticleTocStyle())
            .data("article-toc", "true")
            .attribute("aria-label", "Contents")
        } else {
            EmptyHTML()
        }
    }
}

private func escapedHTML(_ text: String) -> String {
    text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}
