import Foundation
import Testing

@Suite("SitePublishingTests", .serialized)
struct SitePublishingTests {
    @Test("publishes the first-pass IA routes")
    func publishesFirstPassRoutes() async throws {
        try await TestSupport.publishStarterSite()

        #expect(TestSupport.buildFileExists(at: "index.html"))
        #expect(TestSupport.buildFileExists(at: "2/index.html"))
        #expect(TestSupport.buildFileExists(at: "archive/index.html"))
        #expect(TestSupport.buildFileExists(at: "about/index.html"))
        #expect(TestSupport.buildFileExists(at: "posts/welcome-to-tsubame/index.html"))
    }
}
