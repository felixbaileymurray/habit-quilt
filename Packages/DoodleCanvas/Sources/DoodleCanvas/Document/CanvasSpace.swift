import Foundation

/// Fixed square canvas in normalized units. Rendering scales to the screen.
public enum CanvasSpace: Sendable {
    public static let size: Double = 1024
    public static let minCoordinate: Double = 0
    public static let maxCoordinate: Double = size

    /// Clamp a normalized point into canvas bounds.
    public static func clamp(_ point: DoodlePoint) -> DoodlePoint {
        DoodlePoint(
            x: min(max(point.x, minCoordinate), maxCoordinate),
            y: min(max(point.y, minCoordinate), maxCoordinate),
            pressure: min(max(point.pressure, 0), 1),
            tMs: max(point.tMs, 0)
        )
    }
}

/// One sample along a stroke in normalized canvas space.
public struct DoodlePoint: Codable, Hashable, Sendable {
    public var x: Double
    public var y: Double
    /// 0…1. Finger strokes may use a constant; Pencil uses real pressure.
    public var pressure: Double
    /// Milliseconds from stroke start.
    public var tMs: Double

    public init(x: Double, y: Double, pressure: Double = 0.5, tMs: Double = 0) {
        self.x = x
        self.y = y
        self.pressure = pressure
        self.tMs = tMs
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        x = try container.decode(Double.self)
        y = try container.decode(Double.self)
        pressure = container.isAtEnd ? 0.5 : try container.decode(Double.self)
        tMs = container.isAtEnd ? 0 : try container.decode(Double.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
        try container.encode(pressure)
        try container.encode(tMs)
    }
}
