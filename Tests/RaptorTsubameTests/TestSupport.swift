import Foundation
@testable import Raptor
@testable import RaptorTsubame

struct TestPublishHarness {
    let buildDirectory: URL

    init() throws {
        let root = URL(filePath: FileManager.default.currentDirectoryPath)
        self.buildDirectory = root
            .appending(path: ".build")
            .appending(path: "raptor-tsubame-test-site")

        cleanup()
    }

    func publish() async throws {
        var publisher = try SitePublisher(
            for: ExampleSite(),
            with: [],
            buildContext: BuildContext(),
            rootDirectory: URL(filePath: FileManager.default.currentDirectoryPath),
            buildDirectory: buildDirectory
        )

        try await publisher.publish()
    }

    func fileExists(_ relativePath: String) -> Bool {
        FileManager.default.fileExists(atPath: buildDirectory.appending(path: relativePath).path)
    }

    func contents(of relativePath: String) throws -> String {
        try String(contentsOf: buildDirectory.appending(path: relativePath), encoding: .utf8)
    }

    func cleanup() {
        try? FileManager.default.removeItem(at: buildDirectory)
    }
}
