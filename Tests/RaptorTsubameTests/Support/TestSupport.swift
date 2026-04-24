import Foundation
@testable import RaptorTsubame

struct TestPublishHarness: Sendable {
    let rootDirectory: URL
    let buildDirectoryPath: String
    let buildDirectory: URL

    init() throws {
        self.rootDirectory = packageRoot()
        self.buildDirectoryPath = ".build/raptor-tsubame-test-sites/\(UUID().uuidString)"
        self.buildDirectory = rootDirectory.appending(path: buildDirectoryPath)

        cleanup()
    }

    func publish() async throws {
        var site = ExampleSite(rootDirectory: rootDirectory)
        try await site.publish(buildDirectoryPath: buildDirectoryPath)
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

func publishedSite() async throws -> TestPublishHarness {
    try await PublishedSiteCache.shared.harness()
}

private actor PublishedSiteCache {
    static let shared = PublishedSiteCache()

    private var harnessTask: Task<TestPublishHarness, Error>?

    func harness() async throws -> TestPublishHarness {
        if let harnessTask {
            return try await harnessTask.value
        }

        let harnessTask = Task {
            let harness = try TestPublishHarness()
            try await harness.publish()
            return harness
        }

        self.harnessTask = harnessTask
        return try await harnessTask.value
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
