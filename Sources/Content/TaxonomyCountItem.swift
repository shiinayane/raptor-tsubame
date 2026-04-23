import Foundation

struct TaxonomyCountItem: Identifiable, Sendable, Equatable {
    let term: TaxonomyTerm
    let count: Int

    var id: String { term.id }
    var name: String { term.name }
    var path: String { term.path }
}
