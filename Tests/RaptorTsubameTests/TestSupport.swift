import Foundation
@testable import Raptor
@testable import RaptorTsubame

enum TestSupport {
    static let packageRootURL: URL = try! URL.packageDirectory(from: #filePath)
    static let buildDirectoryName = "Build"
    static let buildDirectoryURL = packageRootURL.appending(path: buildDirectoryName)

    static func buildFileExists(at relativePath: String) -> Bool {
        let fileURL = buildDirectoryURL.appending(path: relativePath)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    static func buildFileContents(at relativePath: String) throws -> String {
        let fileURL = buildDirectoryURL.appending(path: relativePath)
        return try String(contentsOf: fileURL, encoding: .utf8)
    }

    static func resetBuildDirectory() throws {
        try? FileManager.default.removeItem(at: buildDirectoryURL)
    }

    static func publishStarterSite() async throws {
        try resetBuildDirectory()

        var publisher = try SitePublisher(
            for: ExampleSite(),
            with: [],
            buildContext: BuildContext(),
            rootDirectory: packageRootURL,
            buildDirectory: buildDirectoryURL
        )

        try await publisher.publish()
    }
}
