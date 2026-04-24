import Foundation
import Raptor

struct TaxonomyIndexItem: HTML {
    let name: String
    let path: String
    let count: Int

    var body: some HTML {
        Link("\(name) (\(count))", destination: path)
    }
}
