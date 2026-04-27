import Foundation
@testable import RaptorTsubame

struct TestPublishHarness: Sendable {
    let rootDirectory: URL
    let buildDirectoryPath: String
    let buildDirectory: URL
    let cacheFingerprint: String

    init() throws {
        self.rootDirectory = packageRoot()
        self.cacheFingerprint = try Self.cacheFingerprint(rootDirectory: rootDirectory)
        self.buildDirectoryPath = ".build/raptor-tsubame-test-sites/published-\(cacheFingerprint)"
        self.buildDirectory = rootDirectory.appending(path: buildDirectoryPath)
    }

    func publish() async throws {
        if isReusableBuildDirectory {
            return
        }

        cleanup()
        var site = ExampleSite(rootDirectory: rootDirectory)
        try await site.publish(buildDirectoryPath: buildDirectoryPath)
        try cacheFingerprint.write(to: cacheMarkerURL, atomically: true, encoding: .utf8)
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

    static func cacheFingerprint(rootDirectory: URL) throws -> String {
        var hash = StableHash()

        for file in try cacheInputFiles(rootDirectory: rootDirectory) {
            let relativePath = file.path.replacingOccurrences(of: rootDirectory.path, with: "")
            let data = try Data(contentsOf: file)
            hash.update("path:\(relativePath.count):\(relativePath)\n")
            hash.update("size:\(data.count)\n")
            hash.update(data)
        }

        return hash.hexDigest
    }

    private var cacheMarkerURL: URL {
        buildDirectory.appending(path: ".raptor-tsubame-cache")
    }

    private var isReusableBuildDirectory: Bool {
        let indexURL = buildDirectory.appending(path: "index.html")
        guard FileManager.default.fileExists(atPath: indexURL.path) else {
            return false
        }

        let marker = try? String(contentsOf: cacheMarkerURL, encoding: .utf8)
        return marker == cacheFingerprint
    }

    private static func cacheInputFiles(rootDirectory: URL) throws -> [URL] {
        let localInputs = [
            rootDirectory.appending(path: "Package.swift"),
            rootDirectory.appending(path: "Package.resolved"),
            rootDirectory.appending(path: "Sources"),
            rootDirectory.appending(path: "Posts"),
            rootDirectory.appending(path: "Resources")
        ]
        let raptorSources = rootDirectory
            .deletingLastPathComponent()
            .appending(path: "raptor/Sources")

        return try (localInputs + [raptorSources])
            .flatMap(regularFiles)
            .sorted { $0.path < $1.path }
    }

    private static func regularFiles(in url: URL) throws -> [URL] {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return []
        }

        if !isDirectory.boolValue {
            return [url]
        }

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var files: [URL] = []
        for case let file as URL in enumerator {
            let values = try file.resourceValues(forKeys: [.isRegularFileKey])
            if values.isRegularFile == true {
                files.append(file)
            }
        }
        return files
    }
}

private struct StableHash {
    private var value: UInt64 = 0xcbf29ce484222325

    var hexDigest: String {
        String(format: "%016llx", value)
    }

    mutating func update(_ string: String) {
        update(Data(string.utf8))
    }

    mutating func update(_ data: Data) {
        for byte in data {
            value ^= UInt64(byte)
            value &*= 0x100000001b3
        }
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
