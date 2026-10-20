// swift-tools-version: 5.9
import PackageDescription

/// Stub package owned by a sibling worker. App links against public surface only.
/// TODO(domain): replace stubs with day/preserve/quilt-layout/doodle-JSON implementations.
let package = Package(
    name: "HabitQuiltDomain",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "HabitQuiltDomain", targets: ["HabitQuiltDomain"]),
    ],
    targets: [
        .target(name: "HabitQuiltDomain"),
        .testTarget(
            name: "HabitQuiltDomainTests",
            dependencies: ["HabitQuiltDomain"]
        ),
    ]
)
