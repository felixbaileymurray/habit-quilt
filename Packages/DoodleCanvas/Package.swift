// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DoodleCanvas",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "DoodleCanvas",
            targets: ["DoodleCanvas"]
        ),
    ],
    targets: [
        .target(
            name: "DoodleCanvas",
            path: "Sources/DoodleCanvas"
        ),
        .testTarget(
            name: "DoodleCanvasTests",
            dependencies: ["DoodleCanvas"],
            path: "Tests/DoodleCanvasTests",
            resources: [
                .copy("Fixtures"),
            ]
        ),
    ]
)
