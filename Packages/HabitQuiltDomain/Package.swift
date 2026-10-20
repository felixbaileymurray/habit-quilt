// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HabitQuiltDomain",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "HabitQuiltDomain",
            targets: ["HabitQuiltDomain"]
        ),
    ],
    targets: [
        .target(
            name: "HabitQuiltDomain"
        ),
        .testTarget(
            name: "HabitQuiltDomainTests",
            dependencies: ["HabitQuiltDomain"]
        ),
    ]
)
