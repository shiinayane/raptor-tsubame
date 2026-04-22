// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RaptorTsubame",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(
            url: "https://github.com/raptor-build/raptor.git",
            from: "0.1.2"
        )
    ],
    targets: [
        .executableTarget(
            name: "RaptorTsubame",
            dependencies: [
                .product(name: "Raptor", package: "Raptor")
            ],
            // Can be removed for single-language sites
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "RaptorTsubameTests",
            dependencies: [
                "RaptorTsubame",
                .product(name: "Raptor", package: "Raptor")
            ],
            path: "Tests/RaptorTsubameTests"
        )
    ]
)
