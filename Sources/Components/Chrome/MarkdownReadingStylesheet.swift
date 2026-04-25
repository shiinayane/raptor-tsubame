import Raptor

struct MarkdownReadingStylesheet: HTML {
    var body: Never { fatalError() }

    func render() -> Markup {
        #"<link href="/css/markdown-reading.css" rel="stylesheet" />"#.render()
    }
}
