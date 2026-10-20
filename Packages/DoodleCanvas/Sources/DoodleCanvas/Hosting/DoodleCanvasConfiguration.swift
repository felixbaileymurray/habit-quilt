import Foundation

/// Host configuration for the SwiftUI canvas. Dot-grid is UI-only.
public struct DoodleCanvasConfiguration: Hashable, Sendable {
    public var showsDotGrid: Bool
    public var isInteractive: Bool

    public init(showsDotGrid: Bool = false, isInteractive: Bool = true) {
        self.showsDotGrid = showsDotGrid
        self.isInteractive = isInteractive
    }
}
