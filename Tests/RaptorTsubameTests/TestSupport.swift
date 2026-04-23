import Foundation
@testable import RaptorTsubame

struct TestPublishHarness {
    let rootDirectory: URL
    let buildDirectory: URL

    init() throws {
        self.rootDirectory = packageRoot()
        self.buildDirectory = rootDirectory
            .appending(path: ".build")
            .appending(path: "raptor-tsubame-test-site")

        cleanup()
    }

    func publish() async throws {
        var site = ExampleSite()
        try await site.publish(buildDirectoryPath: ".build/raptor-tsubame-test-site")
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

func packageRoot(from file: StaticString = #filePath) -> URL {
    var directory = URL(filePath: "\(file)").deletingLastPathComponent()

    while directory.path != "/" {
        if FileManager.default.fileExists(atPath: directory.appending(path: "Package.swift").path) {
            return directory
        }
        directory.deleteLastPathComponent()
    }

    fatalError("Unable to locate package root.")
}

func withCurrentDirectory<T>(_ directory: URL, _ operation: () async throws -> T) async throws -> T {
    let previousDirectory = URL(filePath: FileManager.default.currentDirectoryPath)
    guard FileManager.default.changeCurrentDirectoryPath(directory.path) else {
        fatalError("Unable to change current directory to \(directory.path)")
    }

    defer {
        _ = FileManager.default.changeCurrentDirectoryPath(previousDirectory.path)
    }

    return try await operation()
}

func makeTemporaryDirectory() throws -> URL {
    let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}
