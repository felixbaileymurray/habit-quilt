// swift-tools-version: 5.9
import PackageDescription

/// Stub package owned by a sibling worker. Custom vector canvas (not PencilKit).
/// TODO(canvas): implement pen/pencil/fill, riso inks, undo/redo, thumbnail render.
let package = Package(
    name: "DoodleCanvas",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DoodleCanvas", targets: ["DoodleCanvas"]),
    ],
    targets: [
        .target(name: "DoodleCanvas"),
        .testTarget(
            name: "DoodleCanvasTests",
            dependencies: ["DoodleCanvas"]
        ),
    ]
)
