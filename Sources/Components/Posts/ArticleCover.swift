import Foundation
import Raptor

struct ArticleCover: HTML {
    let post: Post

    var body: some HTML {
        if let image = post.image {
            Section {
                Image(image, description: post.imageDescription)
                    .resizable()
                    .imageFit(.cover)
                    .style(ArticleCoverImageStyle())
                    .data("article-cover-image", "true")
            }
            .style(ArticleCoverStyle())
            .data("article-cover", "true")
            .data("article-cover-source", image)
        }
    }
}
