import Testing
@testable import RaptorTsubame

@Suite("Pagination controls")
struct PaginationControlsTests {
    @Test("computes newer and older paths using a provided page path function")
    func computesNewerOlderPaths() {
        let model = PaginationControls.Model(
            currentPage: 2,
            totalPages: 3,
            pathForPage: { page in "/p/\(page)/" }
        )

        #expect(model.newerPath == "/p/1/")
        #expect(model.olderPath == "/p/3/")
    }
}

